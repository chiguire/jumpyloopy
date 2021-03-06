package entities;

import analysis.FFT;
import analysis.SpectrumProvider;
import analysis.ThresholdFunction;
import components.BeatManagerGameHUD;
import components.BeatManagerVisualizer;
import data.GameInfo.SongSignature;
import entities.Level.LevelStartEvent;
import haxe.PosInfos;
import haxe.crypto.Crc32;
import haxe.crypto.Md5;
import haxe.ds.Vector;
import haxe.io.Bytes;
import luxe.Audio.AudioHandle;
import luxe.Audio.AudioState;
import luxe.Entity;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.options.EntityOptions;
import luxe.resource.Resource.AudioResource;
import luxe.tween.Actuate;
import phoenix.Batcher;
import snow.api.Promise;
import snow.api.buffers.Int16Array;
import snow.api.buffers.Uint8Array;
import systools.Dialogs;

/**
 * ...
 * @author ...
 */
typedef BeatEvent =
{
	var interval : Float;
	var falling: Bool;
};

typedef BeatManagerOptions =
{
	> EntityOptions,
	var batcher : Batcher; // viewport
};

typedef BeatManagerDataReadState =
{
	var data_offset : Int;
	var num_loops : Int;
};

enum BMUpdateState
{
	Idle;
	PreBeat;
	InBeat;
}
 
class BeatManager extends Entity
{
	/// game play constants
	public static var jump_interval = 60 / 200; // 200 bpm
	public var play_audio_loop = true;
	var pitch_shake = 1.0; // used for player damage indication
	
	//var beat_manager_debug_visual : BeatManagerVisualizer;
	var beat_manager_game_hud : BeatManagerGameHUD;
	
	private var music: AudioResource;
	private var music_handle: luxe.Audio.AudioHandle;
	
	/// helpers
	var audio_data_len = 0;
	var audio_data : Uint8Array;
	var audio_data_for_analysis : Vector<Float>;
	
	public var audio_time  (default, null) = 0.0;
	public var audio_duration (default, null) = 0.0;
	
	/// constants
	static public var instant_interval = 1024;
	static public var num_samples_one_second = 44100;
	static var energy_ratio = 1.3; // the ratio between energie1024 energie44100, for the detection of Peak Energy
	
	// size of the pulse train for the convolution ( in a pack of 1024 ( 430 = 10sec ) )
	// ?somehow we are using 108 which is roughly 2.5 sec here?
	static var pulse_train_size = 108; 
	
	/// analysis
	public var num_instant_interval = 0;
	public var energy1024 : Vector<Float>; 	// instant energy
	public var energy44100 : Vector<Float>; // local energy
	public var energy_peak: Vector<Float>;
	
	
	//public var tempo = 0;
	//public var T_occ_max = 0;
	//public var T_occ_avg = 0.0;
	
	public var conv : Vector<Float>;
	
	// chunks 
	var max_instant_intervals_per_chunk = 43 * 15; // 15 sec per chunk
	public var tempo_blocks : Vector<Int>;
	public var T_occ_max_blocks : Vector<Int>;
	public var T_occ_avg_blocks : Vector<Float>;
	
	public var beat : Vector<Float>;
	public var beat_pos(default, null) : Array<Int>;
	public var song_id(default, null) : SongSignature;
	public var song_name(default, null) : String;
		
	/// renderer
	public var batcher: Batcher;
	
	// event id, stored so we can unlisten
	var game_event_id : Array<String>;
	var audio_handler : AudioHandle -> Void;
	
	/// uint hash for seed
	public var audio_seed (default, null) = 0; 
	
	public function new(?_options:BeatManagerOptions) 
	{
		super(_options);
		
		if (_options.batcher != null)
		{
			batcher = _options.batcher;
		}
		else
		{
			batcher = Luxe.renderer.batcher;
		}
		
		/// create a visualizer, don't attached this yet
		//beat_manager_debug_visual = new BeatManagerVisualizer({name:"beat_manager_debug_visual"});
		beat_manager_game_hud = new BeatManagerGameHUD({name:"beat_manager_game_hud"});
	}
	
	public function attach_visual()
	{
		//var comp = get("beat_manager_debug_visual");
		//if (comp == null) add(beat_manager_debug_visual);
		
		var comp1 = get("beat_manager_game_hud");
		if (comp1 == null) add(beat_manager_game_hud);
	}
	
	public function detach_visual()
	{
		remove("beat_manager_debug_visual");
		remove("beat_manager_game_hud");
	}
	
	public function enter_game_state()
	{
		pitch_shake = 1.0;
		cooldown_counter = 0;
		curr_beat_idx = -1;
		curr_update_state = BMUpdateState.Idle;
		
		audio_time = 0.0;
		audio_duration = music.source.duration();
		
		attach_visual();
		
		// events
		game_event_id = new Array<String>();
		game_event_id.push(Luxe.events.listen("Level.Start", on_level_start ));
		game_event_id.push(Luxe.events.listen("game.pause", on_game_pause ));
		game_event_id.push(Luxe.events.listen("game.unpause", on_game_unpause ));
		game_event_id.push(Luxe.events.listen("player_damage", on_player_damage ));
	}
	
	public function leave_game_state()
	{
		cooldown_counter = 0;
		curr_beat_idx = -1;
		curr_update_state = BMUpdateState.Idle;
		
		Luxe.audio.stop(music_handle);
		
		detach_visual();
		
		// events
		for (i in 0...game_event_id.length)
		{
			var res = Luxe.events.unlisten(game_event_id[i]);
		}
		
		if (audio_handler != null)
		{
			var res = Luxe.audio.off(ae_end, audio_handler);
			//trace(res);
		}
	}
	
	var request_next_beat = false;
	var cooldown_counter = 0.0;
	var next_beat_time = 0.0;
	var curr_beat_idx = -1;
	
	var curr_update_state = BMUpdateState.Idle;
	
	var prebeat_counter = 0.0;
	
	override function update(dt:Float)
	{		
		if (music != null && Luxe.audio.state_of(music_handle) == AudioState.as_playing)
		{
			audio_time = Luxe.audio.position_of(music_handle);
			audio_duration = music.source.duration();
			
			// update display
			//beat_manager_debug_visual.update_display(audio_time);
			beat_manager_game_hud.update_display(audio_time);
			
			// we are in arcade mode, the game will be finished when the song is finished
			var time_left = audio_duration - audio_time;
			var fadeout_interval = 5.0;
			if ( play_audio_loop == false && time_left < fadeout_interval )
			{
				var vol = time_left / fadeout_interval;
				Luxe.audio.volume(music_handle, vol);
			}
			
			switch(curr_update_state)
			{
				case BMUpdateState.Idle :
					{
						if (cooldown_counter <= 0.0)
						{
							request_next_beat = true;
							cooldown_counter = 0;
						}
						else
						{
							cooldown_counter -= dt;
						}
						
						if (search_next_beat(audio_time) == true)
						{
							//trace("jump");
							curr_update_state = BMUpdateState.PreBeat;
							prebeat_counter = jump_interval * 0.25;
							Luxe.events.fire("bm_prebeat_event", {}, false );
						}
					}
					
				case BMUpdateState.PreBeat :
					{
						if (prebeat_counter <= 0.0)
						{
							curr_update_state = BMUpdateState.InBeat;
							prebeat_counter = 0;
						}
						else
						{
							prebeat_counter -= dt;
						}
						
					}
				case BMUpdateState.InBeat :
					{
						cooldown_counter = jump_interval;
						beat_manager_game_hud.on_move_event(jump_interval);
						Luxe.events.fire("player_move_event", { interval: jump_interval, falling: false }, false );
						
						curr_update_state = BMUpdateState.Idle;
					}
			}
		}
	}
	
	public function search_next_beat( audio_time : Float ) : Bool
	{
		// search for the closest beat
		if (request_next_beat)
		{
			// handle looping condition
			if (curr_beat_idx+1 >= beat_pos.length)
			{
				curr_beat_idx = -1;
			}
			
			var beg_idx = Std.int(Math.max(curr_beat_idx, 0));
			//trace(beg_idx);
			for ( i in beg_idx...beat_pos.length )
			{
				var beat_time = beat_pos[i] * 1024.0 / 44100.0;
				var activate_prebeat = Math.abs(audio_time - beat_time) < jump_interval * 0.5;
				
				if (activate_prebeat && i!=curr_beat_idx)
				{
					request_next_beat = false;
					curr_beat_idx = i;
					
					return true;
				}
			}	
		}
		
		return false;
	}
	
	public function on_player_damage(e)
	{
		//pitch = Luxe.audio.pitch_of(music_handle);
		//trace(pitch);
		
		// make some random noise
		var tween = Actuate.tween(this, 0.1, {pitch_shake: 0.75}).reflect().repeat(3);
		tween.onUpdate( function(){
			Luxe.audio.pitch(music_handle, pitch_shake); 
		});
		// reset pitch on complete
		tween.onComplete( function(){
			pitch_shake = 1.0;
			Luxe.audio.pitch(music_handle, pitch_shake); 
		});
	}
	
	var music_volume = 0.0;
	public function on_game_state_ending()
	{
		trace("game end");
		request_next_beat = false;
		cooldown_counter = 9999.0;
		curr_update_state = BMUpdateState.Idle;
		curr_beat_idx = -1;
		
		var org_volume = Luxe.audio.volume_of(music_handle);
		music_volume = org_volume;
		var tween = Actuate.tween(this, 3.0, {music_volume:0.0});
		tween.onUpdate( function(){
			Luxe.audio.volume(music_handle, music_volume); 
		});
	}
	
	public function on_player_respawn_begin()
	{
		request_next_beat = false;
		cooldown_counter = 9999.0;
		curr_update_state = BMUpdateState.Idle;
		curr_beat_idx = -1;
	}
	
	public function on_player_respawn_end()
	{
		request_next_beat = false;
		cooldown_counter = 3.0;
		curr_update_state = BMUpdateState.Idle;
		curr_beat_idx = -1;
	}
	
	public function on_game_pause(e)
	{
		Luxe.audio.pause(music_handle);
		request_next_beat = false;
		cooldown_counter = 3.0;
		curr_update_state = BMUpdateState.Idle;
	}
	
	public function on_game_unpause(e)
	{
		Luxe.audio.unpause(music_handle);
	}
	
	function handle_pause()
	{
		
	}
	
	function on_level_start( e )
	{
		if (play_audio_loop)
		{
			music_handle = Luxe.audio.loop(music.source);
		}
		else
		{				
			music_handle = Luxe.audio.play(music.source);
			
			audio_handler = function(handle : AudioHandle) {
				trace("audio is finished, move to the ending state");
				Luxe.events.fire("audio_track_finished");
			};
			
			Luxe.audio.on(ae_end, audio_handler);
		}
	}
	
	@:generic
	public static function get_data<T>( container:Vector<T>, i:Int ) : T
	{
		return container[ i % container.length ];
	}
	
	public function load_song( audio_id: String )
	{
		//var audio_name = "assets/music/Warchild_Music_Prototype.ogg";
		//var audio_name = "assets/music/Warchild_SimpleDrums.ogg";
		//audio_id = "assets/music/160711_snapper4298_90-bpm-funky-break.ogg";
		song_name = audio_id.substr(audio_id.lastIndexOf("\\") + 1);
		
		// we need to reload it if it is already been loaded as a stream
		var res = Luxe.resources.audio(audio_id);
		if (res != null && res.asset.audio.is_stream == true)
		{
			Luxe.resources.destroy(audio_id, true);
		}
		
		// reload the whole file, for analysis
		var load = snow.api.Promise.all([
            Luxe.resources.load_audio(audio_id)
        ]);
		
		load.then(function(_) {
			
			music = Luxe.resources.audio(audio_id);
			music_handle = Luxe.audio.play(music.source, 1.0, true);
			Luxe.audio.stop(music_handle);
			
			trace("Format: " + music.source.data.format);
			trace("Channels: " + music.source.data.channels);
			trace("Rate: " + music.source.data.rate);
			trace("Length: " + music.source.data.length);
			trace("Duration: " + music.source.duration());
			trace(music.source.data);
			
			audio_time = 0.0;
			audio_duration = 0.0;
			
			// audio format test
			var test_fmt = (music.source.data.channels == 2) && (music.source.data.rate == 44100);
			if (!test_fmt)
			{
				Dialogs.message("Error", "Unsupported Audio Format, the game only supported OGG with 2 Channels and 44100Hz SampleRate", true);
				Luxe.events.fire("BeatManager.AudioLoadingFailed", {}, false );
				return;
			}
			
			Luxe.events.fire("BeatManager.AudioAnalysisStart", {}, false );
			
			audio_time = 0.0;
			audio_duration = music.source.duration();
			
			process_audio();
			process_audio_fft();
			
			// create a seed for random
			var md5str = Md5.encode(beat_pos.toString());
			song_id = md5str;
			var md5bytes = Bytes.ofString(md5str);
			audio_seed = Crc32.make(md5bytes);
			//trace("audio_seed " + md5str);
			
			Luxe.events.fire("BeatManager.AudioLoaded", {}, false );
		});
	}
	
	public function process_audio()
	{
		// Get Data
		var music_instance = music.source.instance(music_handle);
		
		var l = music.source.data.length;
		audio_data = new Uint8Array(l);
		var audio_data_query_result = new Array<Int>();
		music_instance.data_get(audio_data, 0, l, audio_data_query_result);
		
		//trace(audio_data);
		
		// the case of 16 bit per sample (the raw data is in Integer 16 bit format, be careful!)
		var audio_data16 = Int16Array.fromBuffer(audio_data.buffer, 0, audio_data.buffer.length);
		//trace(audio_data16);
		
		// assuming that we are loading 2 channels audio
		audio_data_len = Std.int(audio_data16.length / 2);
		
		audio_data_for_analysis = new Vector<Float>(audio_data_len);
		for ( i in 0...audio_data_len )
		{
			var data_left_channel = audio_data16[i * 2];
			var data_right_channel = audio_data16[i * 2 + 1];
			var val = (data_left_channel + data_right_channel)/2;
			audio_data_for_analysis[i] = val;
		}
		//trace(audio_data16_left);
		
		num_instant_interval = Std.int(audio_data_len / instant_interval);
		
		trace(num_instant_interval);
		
		//for(i in 0...audio_data_len) trace(audio_data[i]);
		//trace(audio_data_query_result);
		
		// initialize inttermidiate buffers
		energy1024 = new Vector<Float>(num_instant_interval);
		energy44100 = new Vector<Float>(num_instant_interval);
		
		// calculate instant energy every 1024 samples, stored in the buffer
		for ( i in 0...num_instant_interval)
		{
			var e = energy(audio_data_for_analysis, i * instant_interval, 4096); // 4096? why not using 1024
			energy1024[i] = e;
		}
		//trace(energy1024);
		
		// calculate local average energy
		calculate_avg_local_energy();
		// ratio energie1024 / energie44100
		calculate_peak_energy();
		
		conv = new Vector<Float>(num_instant_interval);
		beat = new Vector<Float>(num_instant_interval);
		
		var num_chunks = Math.ceil(num_instant_interval / max_instant_intervals_per_chunk);
		
		tempo_blocks = new Vector<Int>(num_chunks);
		T_occ_max_blocks = new Vector<Int>(num_chunks);
		T_occ_avg_blocks = new Vector<Float>(num_chunks);
		
		for ( i in 0...num_chunks)
		{
			// calculate BPM
			var begin = i * max_instant_intervals_per_chunk;
			var end = Std.int(Math.min(((i + 1) * max_instant_intervals_per_chunk) - 1, num_instant_interval));
			calculate_tempo(begin, end, i);
			// calculate Beat Line
			calculate_beat_line(begin, end, i);	
		}
		//trace(tempo_blocks);

		// store beat's position in a better format
		//calculate_beat_pos();
	}
	
	
	/// helpers
	function energy(data:Vector<Float>, offset:UInt, window:UInt): Float
	{
		var res = 0.0;
		var end = Std.int(Math.min(offset + window, audio_data_len));
		for (i in offset...end)
		{
			res += data[i] * data[i] / window; 
		}
		
		return res;
	}
	
	function calculate_avg_local_energy()
	{
		var sum = 0.0;
		// calculation of the first second
		// 43 came from 44100/1024
		var num_objects = 43 * 5; 
		for ( i in 0...num_objects )
		{
			sum += energy1024[i];
		}
		energy44100[0] = sum / num_objects;
		
		// optimization, here we keep the sum and shift one step at the time
		// so we can reduce amount of unnecessary computation
		for ( i in 1...num_instant_interval )
		{
			// [Note] I feel like this part of calculation will cause an array out of bounds at the end
			// maybe the correct thing to do here is wrap the i index around
			// esp. when the music is looping
			var next_idx = (i + num_objects - 1) % energy1024.length;
			var prev_idx = i - 1;
			
			// practically, what we do here is replaced the first item with the next item
			// yielding the new sum for the next window
			sum += energy1024[next_idx] - energy1024[prev_idx];
			// then calculate this local average
			energy44100[i] = sum / num_objects;
		}
		
		//trace(energy44100);
	}
	
	function calculate_peak_energy()
	{
		// 21 came from (44100/1024)/2
		// means, we compared where i (instant energy) is in the center pos of the window (local energy)
		energy_peak = new Vector<Float>(num_instant_interval);
		var lookup_offset = 21 * 5;
		for ( i in 0...num_instant_interval )
		{
			var local_avg_index = ((i - lookup_offset) + energy44100.length) % energy44100.length; // loop the lookup
			
			// -21 To center the energie1024 on the second energie44100
			if ( energy1024[i] > energy_ratio * energy44100[local_avg_index] )
			{
				energy_peak[i] = 1.0;
			}
			else
			{
				energy_peak[i] = 0.0;
			}
		}
		
		//trace(energy_peak);
	}
	
	function calculate_tempo(begin:Int, end:Int, chunk_id:Int)
	{
		// calculate time interval between peaks
		var T = new Array<Float>();
		var i_prev = 0;
		
		for ( i in begin+1...end )
		{
			if ( energy_peak[i] == 1 && energy_peak[i - 1] == 0)
			{
				var di = i - i_prev;
				// [AIK] this number 5? , i think 5 is a madeup number, just to reduce the chance to have noisy peaks
				// could try experiment with this
				if ( di > 5) 
				{
					T.push(di);
					i_prev = i;
				}
			}
		}
		
		// counting the occurence for each interval (up to 2 sec == 86 instant interval) 
		var T_occurence = new Vector<Int>(86);
		for (i in 0...T_occurence.length) T_occurence[i] = 0;
		
		for ( i in 0...T.length)
		{
			var idx = Std.int(T[i]);
			if (idx < 86) T_occurence[idx] = T_occurence[idx] + 1;  
		}
		//trace(T_occurence);
		
		// finding a maximum occurance
		var T_occ_max = 0;
		var occ_max = 0;
		for (i in 0...T_occurence.length)
		{
			if (T_occurence[i] >= occ_max)
			{
				T_occ_max = i;
				occ_max = T_occurence[i];
			}
		}
		
		// We average max + his neighbor Max for more accuracy
		var neighbor_left 	= T_occ_max - 1;
		var neighbor_right 	= T_occ_max + 1; //? risking out of bound here?
		
		var T_occ_closest_neighbor = T_occurence[neighbor_right] > T_occurence[neighbor_left] ? neighbor_right : neighbor_left;
		
		var occ_closest_neighbor = T_occurence[T_occ_closest_neighbor];
		
		var div = occ_max + occ_closest_neighbor;
		var T_occ_avg = (T_occ_max * occ_max + T_occ_closest_neighbor * occ_closest_neighbor) / div;
		
		// output the tempo
		var tempo = Std.int(60.0 / (T_occ_avg * (1024.0 / 44100.0)));
		
		T_occ_max_blocks[chunk_id] = T_occ_max;
		T_occ_avg_blocks[chunk_id] = T_occ_avg;
		tempo_blocks[chunk_id] = tempo;
	}
	
	function normalize(signal:Vector<Float>, max_att:Float)
	{
		for (i in 0...signal.length)
		{
			signal[i] = signal[i] / max_att;
		}
	}
	
	function search_max(signal:Vector<Float>, beg:Int, radius:Int) : Int
	{
		var max = 0.0;
		var max_idx = 0;
		
		var lower_bound = Std.int(Math.max( beg - radius, 0 ));
		var upper_bound = Std.int(Math.min( beg + radius, signal.length - 1 ));
		for ( i in lower_bound...upper_bound )
		{
			var val = signal[i];
			if (val > max)
			{
				max = val;
				max_idx = i;
			}
		}
		
		return max_idx;
	}
	
	/// calculating beat line,  
	function calculate_beat_line(begin:Int, end:Int, chunk_id:Int) 
	{
		// create pulse train
		var pulse_train = new Vector<Float>(pulse_train_size);
		var T_occ_avg = T_occ_avg_blocks[chunk_id];
		var space : Float = T_occ_avg;
		
		for (i in 0...pulse_train_size)
		{
			if (space >= T_occ_avg)
			{
				pulse_train[i] = 1.0;
				space -= T_occ_avg;
			}
			else
			{
				pulse_train[i] = 0.0;
			}
			space += 1.0;
		}
		
		//trace(pulse_train);
				
		// convolution with instant energy of the music
		var max_att = 0.0; 	// maximum attitude
		var max_val = 0.0;
		var max_val_idx = 0; 
		for (i in begin...end)
		{
			// for each pulse train
			for (j in 0...pulse_train.length)
			{
				var id = (i + j) % energy1024.length;
				conv[i] = conv[i] + energy1024[i + j] * pulse_train[j];
			}
			
			// also calculate maximum attitude, using in normalization
			var att = Math.abs(conv[i]);
			if (att > max_att) { max_att = att; }
			
			// Search the peak of conv
			// find max as well
			var val = conv[i];
			if ( val > max_val ) 
			{
				max_val = val;
				max_val_idx = i;
			}
		}
		
		normalize(conv, max_att);
		
        // Max ( this is mostly a beat ( not all the time ... ) )
		beat[max_val_idx] = 1.0;
		
		// process to the right
		var search_radius = 2;
		var T_occ_max = T_occ_max_blocks[chunk_id];
		var right_idx = max_val_idx + T_occ_max;
		while ( right_idx < end && conv[right_idx] > 0.0 )
		{
			// find local max
			var max_conv_val_loc = search_max(conv, right_idx, search_radius);
			beat[max_conv_val_loc] = 1.0;
			
			right_idx = max_conv_val_loc + T_occ_max; 
		}
		// process to the left
		var left_idx = max_val_idx - T_occ_max;
		while ( left_idx >= 0 && conv[left_idx] > 0.0 )
		{
			// find local max
			var max_conv_val_loc = search_max(conv, left_idx, search_radius);
			beat[max_conv_val_loc] = 1.0;
			
			left_idx = max_conv_val_loc - T_occ_max; 
		}
		
		//trace(beat);
	}
	
	function calculate_beat_pos()
	{
		beat_pos = new Array<Int>();
		for ( i in 0...beat.length )
		{
			if (beat[i] > 0.0) beat_pos.push(i);
		}
		
		//trace(beat_pos);
	}
	
	function get_beat_pos():Array<Int> 
	{
		return beat_pos;
	}
	
	/// analysis 2
	public function get_samples( samples:Vector<Float>, offset:Int ) : BeatManagerDataReadState
	{
		if ( offset + samples.length <= audio_data_for_analysis.length )
		{
			Vector.blit(audio_data_for_analysis, offset, samples, 0, samples.length);
		}
		else
		{
			for ( i in 0...samples.length )
			{
				// wrap around
				var id = (offset + i) % audio_data_for_analysis.length;
				samples[i] = audio_data_for_analysis[id];
			}
		}
		
		// return next_offset (wrap around)
		return { data_offset: (offset + samples.length) % audio_data_for_analysis.length, num_loops: Std.int((offset + samples.length) / audio_data_for_analysis.length) };
	}
	
	
	/// fft analysis
	public static var hop_size = 1024;// 512;
	public static var history_size = 50 * 15;
	public static var multipliers = [ 4.0, 2.0, 2.0 ];
	
	public static var bands = [ { low:100, high:500 } ];// , 4000, 10000, 10000, 16000 ];
	//public static var bands = [ 500, 1500, 4000, 10000, 10000, 16000 ];
	
	function reset_audio_fft_params()
	{
		multipliers[0] = 4.0;
		bands[0] = { low:100, high:500 };
	}
	
	public function process_audio_fft()
	{
		trace(bands);
		trace(multipliers);
		
		var spectrum_provider = new SpectrumProvider(this, 1024, hop_size, true);
		var spectrum = spectrum_provider.next_spectrum();
		var prev_spectrum = new Vector<Float>(spectrum.length);
		
		var spectral_flux = new Array<Array<Float>>();
		for ( i in 0...bands.length )
		{
			spectral_flux.push(new Array<Float>());
		}
		
		do
		{
			var i = 0;
			while ( i < bands.length )
			{
				var start_freq = spectrum_provider.fft.freq_to_index( bands[i].low );
				var end_freq = spectrum_provider.fft.freq_to_index( bands[i].high );
				
				var flux = 0.0;
				for ( j in start_freq...end_freq + 1 )
				{
					var val = (spectrum[j] - prev_spectrum[j]);
					val = (val + Math.abs(val)) / 2;
					flux += val;
				}
				spectral_flux[i].push(flux);
				
				i += 2;
			}
			
			Vector.blit( spectrum, 0, prev_spectrum, 0, spectrum.length );
			
			spectrum = spectrum_provider.next_spectrum();
		}
		while (spectrum != null);
		
		for ( i in 0...spectral_flux.length )
		{
			trace(spectral_flux[i].length);
		}
		
		//trace(spectral_flux);
		
		var thresholds = new Array<Array<Float>>();
		for ( i in 0...bands.length )
		{
			var threshold = new ThresholdFunction( history_size, multipliers[i] ).calculate( spectral_flux[i] );
			thresholds.push( threshold );
		}

		var arry_size = spectral_flux[0].length;
		var a_spectral_flux = spectral_flux[0];
		var threshold = thresholds[0];
		var pruned_spectral_flux = new Vector<Float>(arry_size);
		// onset detection
		for( i in 0...arry_size)
		{
			pruned_spectral_flux[i] = 0.0;
			if ( threshold[i] <= a_spectral_flux[i] )
			{
				pruned_spectral_flux[i] = a_spectral_flux[i] - threshold[i];
			}
		}
		
		var peaks_filter = 10; // hard capped for now, 200 bpm is the fastest beat we want to keep
		var counter = 0;
		for ( i in 2...beat.length  )
		{
			beat[i] = 0.0;
			
			if ( pruned_spectral_flux[i] < pruned_spectral_flux[i-1] && pruned_spectral_flux[i-2] == 0)
			{
				if (counter > peaks_filter)
				{
					beat[i] = 1;
					counter = 0;
				}
			}
			counter++;
		}
		
		calculate_beat_pos();
		
		// once we are finished, reset these parameters
		reset_audio_fft_params();
	}
}
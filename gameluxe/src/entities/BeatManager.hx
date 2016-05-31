package entities;

import haxe.PosInfos;
import haxe.ds.Vector;
import luxe.Audio.AudioHandle;
import luxe.Entity;
import luxe.options.EntityOptions;
import luxe.resource.Resource.AudioResource;
import snow.api.buffers.Int16Array;
import snow.api.buffers.Uint8Array;

/**
 * ...
 * @author ...
 */
class BeatManager extends Entity
{
	private var music: AudioResource;
	private var music_handle: luxe.Audio.AudioHandle;
	
	/// helpers
	var audio_data_len = 0;
	var audio_data : Uint8Array;
	
	/// constants
	var instant_interval = 1024;
	static var energy_ratio = 1.3; // the ratio between energie1024 energie44100, for the detection of Peak Energy
	
	// size of the pulse train for the convolution ( in a pack of 1024 ( 430 = 10sec ) )
	// ?somehow we are using 108 which is roughly 2.5 sec here?
	static var pulse_train_size = 108; 
	
	/// analysis
	var num_instant_interval = 0;
	var energy1024 : Array<Float>; 	// instant energy
	var energy44100 : Array<Float>; // local energy
	var energy_peak: Array<Float>;
	var tempo = 0;
	var T_occ_max = 0;
	var T_occ_avg = 0.0;
	var beat : Vector<Float>;
	
	var beat_pos(get, null) : Array<Int>;
	
	public function new(?_options:EntityOptions) 
	{
		super(_options);
		
	}
	
	override function update(dt:Float)
	{
		var audio_time = Luxe.audio.position_of(music_handle);
		// search for the closest beat
		var curr_beat_time = 0.0;
		var request_next_beat = false;
		if (audio_time - curr_beat_time > 0.016)
		{
			request_next_beat = true;
		}
		
		
		if (request_next_beat)
		{
			for ( i in 0...beat_pos.length )
			{
				var beat_time = beat_pos[i] * 1024.0 / 44100.0;
				if (audio_time - beat_time < 0.016)
				{
					request_next_beat = false;
					trace("beat " + beat_pos[i]);
					curr_beat_time = beat_time;
					break;
				}
			}	
		}
	}
	
	public function load_song()
	{
		var load = snow.api.Promise.all([
            Luxe.resources.load_audio("assets/music/317365_frankum_tecno-pop-base-and-leads.ogg")
        ]);
		
		load.then(function(_) {

            //go away
            //box.color.tween(2, {a:0});
			music = Luxe.resources.audio("assets/music/317365_frankum_tecno-pop-base-and-leads.ogg");
			music_handle = Luxe.audio.loop(music.source);
			
			trace("Format: " + music.source.data.format);
			trace("Channels: " + music.source.data.channels);
			trace("Rate: " + music.source.data.rate);
			trace("Length: " + music.source.data.length);
			trace("Duration: " + music.source.duration());
			
			trace(music.source.data);
			
	 		//var s = "";
			//for (i in 0...1024)
			//{
			//	s += Std.string(music.source.data.samples[i]) +",";
			//}
			//log(s);
			
			//Luxe.showConsole(true);
			
			process_audio();
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
		
		trace(audio_data);
		
		// the case of 16 bit per sample (the raw data is in Integer 16 bit format, be careful!)
		var audio_data16 = Int16Array.fromBuffer(audio_data.buffer, 0, audio_data.buffer.length);
		trace(audio_data16);
		var audio_data16_left = new Array<Int>();
		for ( i in 0...Std.int(audio_data16.length/2) )
		{
			audio_data16_left.push(audio_data16[i * 2]);
		}
		//trace(audio_data16_left);
		
		audio_data_len = audio_data16_left.length;
		num_instant_interval = Std.int(audio_data_len / instant_interval);
		
		trace(num_instant_interval);
		
		//for(i in 0...audio_data_len) trace(audio_data[i]);
		//trace(audio_data_query_result);
		
		// initialize inttermidiate buffers
		energy1024 = new Array<Float>();
		energy44100 = new Array<Float>();
		
		// calculate instant energy every 1024 samples, stored in the buffer
		for ( i in 0...num_instant_interval)
		{
			var e = energy(audio_data16_left, i * instant_interval, 4096); // 4096? why not using 1024
			energy1024.push(e);
		}
		//trace(energy1024);
		
		// calculate local average energy
		calculate_avg_local_energy();
		// ratio energie1024 / energie44100
		calculate_peak_energy();
		
		// calculate BPM
		calculate_tempo();
		
		// calculate Beat Line
		calculate_beat_line();
		calculate_beat_pos();
	}
	
	
	/// helpers
	function energy(data:Array<Int>, offset:UInt, window:UInt): Float
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
		var num_objects = 43; 
		for ( i in 0...num_objects )
		{
			sum += energy1024[i];
		}
		energy44100.push( sum / num_objects);
		
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
			energy44100.push(sum / num_objects);
		}
		
		//trace(energy44100);
	}
	
	function calculate_peak_energy()
	{
		// 21 came from (44100/1024)/2
		// means, we compared where i (instant energy) is in the center pos of the window (local energy)
		energy_peak = new Array<Float>();
		var lookup_offset = 21;
		for ( i in 0...num_instant_interval )
		{
			var local_avg_index = ((i - lookup_offset) + energy44100.length) % energy44100.length; // loop the lookup
			
			// -21 To center the energie1024 on the second energie44100
			if ( energy1024[i] > energy_ratio * energy44100[local_avg_index] )
			{
				energy_peak.push(1.0);
			}
			else
			{
				energy_peak.push(0.0);
			}
		}
		
		//trace(energy_peak);
	}
	
	function calculate_tempo()
	{
		// calculate time interval between peaks
		var T = new Array<Float>();
		var i_prev = 0;
		
		for ( i in 1...num_instant_interval )
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
		T_occ_max = 0;
		var occ_max = 0;
		for (i in 0...T_occurence.length)
		{
			if (T_occurence[i] > occ_max)
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
		T_occ_avg = (T_occ_max * occ_max + T_occ_closest_neighbor * occ_closest_neighbor) / div;
		
		// output the tempo
		tempo = Std.int(60.0 / (T_occ_avg * (1024.0 / 44100.0)));
		trace(tempo);
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
	function calculate_beat_line() 
	{
		// create pulse train
		var pulse_train = new Vector<Float>(pulse_train_size);
		var space = T_occ_avg;
		
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
				
		// convolution with instant energy of the music
		var conv = new Vector<Float>(num_instant_interval);
		var max_att = 0.0; 	// maximum attitude
		var max_val = 0.0;
		var max_val_idx = 0; 
		for (i in 0...(num_instant_interval - pulse_train.length))
		{
			// for each pulse train
			for (j in 0...pulse_train.length)
			{
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
		beat = new Vector<Float>(num_instant_interval);
		beat[max_val_idx] = 1.0;
		
		// process to the right
		var search_radius = 2;
		var right_idx = max_val_idx + T_occ_max;
		while ( right_idx < num_instant_interval && conv[right_idx] > 0.0 )
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
		
		trace(beat_pos);
	}
	
	function get_beat_pos():Array<Int> 
	{
		return beat_pos;
	}
}
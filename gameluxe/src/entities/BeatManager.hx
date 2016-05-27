package entities;

import haxe.PosInfos;
import luxe.Audio.AudioHandle;
import luxe.Entity;
import luxe.options.EntityOptions;
import luxe.resource.Resource.AudioResource;
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
	
	/// analysis
	var energy1024 : Array<Float>; 	// instant energy
	var energy44100 : Array<Float>; // local energy
	var energy_peak: Array<Float>;
	
	public function new(?_options:EntityOptions) 
	{
		super(_options);
		
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
			
			audio_data_len = music.source.data.length;
			
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
		
		trace(music_instance);
		
		audio_data = new Uint8Array(audio_data_len);
		var audio_data_query_result = new Array<Int>();
		music_instance.data_get(audio_data, 0, audio_data_len, audio_data_query_result);
		
		// initialize inttermidiate buffers
		energy1024 = new Array<Float>();
		energy44100 = new Array<Float>();
		
		// calculate instant energy every 1024 samples, stored in the buffer
		for ( i in 0...Std.int(audio_data_len / instant_interval))
		{
			var e = energy(audio_data, i * instant_interval, 4096); // 4096? why not using 1024
			energy1024.push(e);
		}
		//trace(energy1024.length);
		
		// calculate local average energy
		calculate_avg_local_energy();
	}
	
	/// helpers
	function energy(data:Uint8Array, offset:UInt, window:UInt): Float
	{
		var res = 0.0;
		var end = Std.int(Math.min(offset + window, audio_data_len));
		for (i in offset...end)
		{
			res += audio_data[i] * audio_data[i] / window; 
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
		for ( i in 1...Std.int(audio_data_len / 1024) )
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
		
		//trace(energy44100.length);
	}
	
	function calculate_peak_energy()
	{
		
	}
}
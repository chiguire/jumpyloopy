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
	var 
	
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
		
		// calculate instant energy
		
	}
	
	/// helpers
	function energy(data:Uint8Array, offset:UInt, window:UInt): Int
	{
		var res = 0.0;
		var end = Std.int(Math.min(offset + window, audio_data_len));
		for (i in offset...end)
		{
			res += audio_data[i] * audio_data[i] / window; 
		}
		
		return Std.int(res);
	}
}
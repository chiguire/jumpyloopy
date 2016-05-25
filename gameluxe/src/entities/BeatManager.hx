package entities;

import haxe.PosInfos;
import luxe.Audio.AudioHandle;
import luxe.Entity;
import luxe.options.EntityOptions;
import luxe.resource.Resource.AudioResource;

/**
 * ...
 * @author ...
 */
class BeatManager extends Entity
{
	private var music: AudioResource;
	private var music_handle: luxe.Audio.AudioHandle;
	
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
			
	 		//var s = "";
			//for (i in 0...1024)
			//{
			//	s += Std.string(music.source.data.samples[i]) +",";
			//}
			//log(s);
			
			//Luxe.showConsole(true);
		});
	}
}
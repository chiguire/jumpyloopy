package gamestates;

import data.GameInfo;
import luxe.Audio.AudioState;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.Actuate;
import mint.Button;
import snow.types.Types.AudioHandle;

/**
 * ...
 * @author Aik
 */
class LevelSelectState extends State
{
	var game_info : GameInfo;
	
	var parcel : Parcel;
	
	/// deferred state transition
	var change_to = "";
	
	/// music preview
	var music_handle : AudioHandle;
	var music_volume = 0.0;

	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function onleave<T>(_value:T)
	{
		Luxe.audio.stop(music_handle);
		Luxe.resources.destroy("assets/music/Warchild_Music_Prototype.ogg", true);
		
		Main.canvas.destroy_children();		
		parcel = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering level select");
		
		// load parcels
		parcel = new Parcel();
		parcel.from_json(Luxe.resources.json("assets/data/level_select_parcel.json").asset.json);
		
		var progress = new ParcelProgress({
            parcel      : parcel,
            background  : new Color(1,1,1,0.85),
            oncomplete  : on_loaded
        });
		
		parcel.load();
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
	}
	
	function create_button( desc: Dynamic) : Button
	{
		var button = MenuState.create_button( desc );
		
		button.onmouseenter.listen(
			function(e, c)
			{
				if (Luxe.audio.state_of(music_handle) == AudioState.as_playing)
				{
					return;
				}
				
				var audio_name = desc.track;
		
				var load = snow.api.Promise.all([
					Luxe.resources.load_audio(audio_name, {is_stream:true})
				]);
		
				load.then(function(_)
				{
					var music = Luxe.resources.audio(audio_name);
					music_handle = Luxe.audio.play(music.source, music_volume, false);
					
					Actuate.tween(this, 0.5, {music_volume:1.0});
				});
			});
			
		button.onmouseleave.listen( function(e, c)
		{
			Actuate.tween(this, 0.5, {music_volume:0.0})
				.onComplete(function() {Luxe.audio.stop(music_handle);});
		});
		
		return button;
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/level_select.json");
		var layout_data = json_resource.asset.json;
		
		var button0 = create_button( layout_data.level_0 );
		button0.onmouseup.listen(
			function(e,c) 
			{
				change_to = "GameState";
			});
		
		var button1 = create_button( layout_data.level_1 );
		button1.onmouseup.listen(
			function(e,c) 
			{
				change_to = "GameState";
			});
		
		var button2 = MenuState.create_button( layout_data.level_x );
		button2.onmouseup.listen(
			function(e,c) 
			{
				change_to = "GameState";
			}
		);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (change_to != "")
		{
			machine.set(change_to);
			change_to = "";
		}
		
		// fade music in/out if we need to
		if (music_handle != null)
		{
			Luxe.audio.volume(music_handle, music_volume);
		}
	}
}
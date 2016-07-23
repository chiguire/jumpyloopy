package gamestates;

import data.GameInfo;
import entities.BeatManager;
import gamestates.GameState.GameStateOnEnterData;
import luxe.Audio.AudioState;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Scene;
import luxe.Sprite;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.Actuate;
import mint.Button;
import mint.Label;
import mint.render.luxe.Panel;
import mint.types.Types.TextAlign;
import snow.types.Types.AudioHandle;
import ui.MintImageButton;

#if (cpp || neko)
import systools.Dialogs;
#end

/**
 * ...
 * @author Aik
 */
class LevelSelectState extends State
{
	var game_info : GameInfo;
	
	var parcel : Parcel;
	var scene : Scene;
	
	/// deferred state transition
	var change_state_signal = false;
	var next_state = "";
	var game_state_on_enter_data : GameStateOnEnterData;
	
	/// music preview
	var music_handle : AudioHandle;
	var music_volume = 0.0;
	
	/// user mode
	var audio_fn = "";
	var audio_fft_params_id = "";
	
	/// panel text
	var desc_sprite : Sprite;

	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		
		Luxe.events.listen("BeatManager.AudioLoaded", on_audio_analysis_completed );
	}
	
	override function onleave<T>(_value:T)
	{
		change_state_signal = false;
		next_state = "";
		
		Actuate.reset();
		Luxe.audio.stop(music_handle);
		
		Main.canvas.destroy_children();		
		
		scene.empty();
		scene.destroy();
		scene = null;
		parcel = null;
		
		// Audio 
		Main.simple_fe_audio_end();
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering level select");
		
		// load parcels
		Main.load_parcel(parcel, "assets/data/level_select_parcel.json", on_loaded);
		scene = new Scene();
		
		Main.create_background(scene);
		
		var background1 = new Sprite({
			texture: Luxe.resources.texture("assets/image/track_selection.png"),
			pos: new Vector(720, 450),
			size: new Vector(500, 900),
			scene: scene,
		});
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/level_select.json");
		var layout_data = json_resource.asset.json;
		
		//MenuState.create_image(layout_data.background);
		
		var item = new MintImageButton(Main.canvas, "Story", new Vector(470+150, 250), new Vector(205, 52), "assets/image/ui/UI_track_selection_story.png");
		item.onmouseup.listen(function(e,c) {
			Main.beat_manager.load_song("assets/music/Warchild_Music_Prototype.ogg");
			next_state = "StoryIntroState";
		});
		item.onmouseenter.listen(function(e, c) {
			desc_sprite.texture = Luxe.resources.texture("assets/image/ui/UI_track_selection_story_text.png");
			desc_sprite.size.set_xy(401, 127);
			desc_sprite.origin.set_xy(0, 0);
			desc_sprite.pos.set_xy(470+50, 535);
			desc_sprite.visible = true;
		});
		item.onmouseleave.listen(function(e, c) {
		});
		
		
		item = new MintImageButton(Main.canvas, "Arcade", new Vector(470+150, 335), new Vector(204, 44), "assets/image/ui/UI_track_selection_arcade.png");
		item.onmouseup.listen(function(e,c) {
			//change_to = "GameState";
			#if cpp
			var filters: FILEFILTERS = { count: 1
			, descriptions: ["OGG files"]
			, extensions: ["*.ogg"]	
			
			};	
			var result:Array<String> = Dialogs.openFile(
			"Select a file please!"
			, "Please select one or more files, so we can see if this method works"
			, filters
			);
			
			trace(result);
			if (result != null)
			{
				// if we have the audio tweak file
				audio_fn = result[0];
				audio_fft_params_id = StringTools.replace(audio_fn, "ogg", "json");
				
				// reload resource
				var json_data = Luxe.resources.json(audio_fft_params_id);
				if (json_data != null)
				{
					Luxe.resources.destroy(audio_fft_params_id, true);
				}
				
				next_state = "GameState";
				game_state_on_enter_data = { is_story_mode: false, play_audio_loop: false };
				var loaded_cfg = Luxe.resources.load_json(audio_fft_params_id).then( on_audio_cfg_loaded, on_audio_cfg_notfound );
			}
			#end
		});
		item.onmouseenter.listen(function(e, c) {
			desc_sprite.texture = Luxe.resources.texture("assets/image/ui/UI_track_selection_arcade_text.png");
			desc_sprite.size.set_xy(386, 108);
			desc_sprite.origin.set_xy(0, 0);
			desc_sprite.pos.set_xy(470+50, 540);
			desc_sprite.visible = true;
		});
		item.onmouseleave.listen(function(e, c) {
		});
			
						
		item = new MintImageButton(Main.canvas, "Tutorial", new Vector(470+150, 420), new Vector(203, 50), "assets/image/ui/UI_track_selection_infinite.png");
		item.onmouseup.listen(function(e,c) {
			Main.beat_manager.load_song("assets/music/Warchild_SimpleDrums.ogg");
			game_state_on_enter_data = { is_story_mode: false, play_audio_loop: true };
			next_state = "GameState";
		});
		item.onmouseenter.listen(function(e, c) {
			desc_sprite.texture = Luxe.resources.texture("assets/image/ui/UI_track_selection_infinite_text.png");
			desc_sprite.size.set_xy(196, 95);
			desc_sprite.origin.set_xy(0, 0);
			desc_sprite.pos.set_xy(470+153, 547);
			desc_sprite.visible = true;
		});
		item.onmouseleave.listen(function(e, c) {
		});
		
		
		item = new MintImageButton(Main.canvas, "Back", new Vector(470+220, 823), new Vector(62, 38), "assets/image/ui/UI_track_selection_back.png");
		item.onmouseup.listen(function(e, c) {
			next_state = "MenuState";
			change_state_signal = true;
		});
		item.onmouseenter.listen(function(e, c) {
			desc_sprite.visible = false;
		});
		item.onmouseleave.listen(function(e, c) {
		});
		
		
		desc_sprite = new Sprite({
			scene: scene,
		});
		desc_sprite.visible = false;
	}
	
	function on_audio_cfg_loaded(e)
	{
		trace("cfg file loaded");
		
		var json_data = Luxe.resources.json(audio_fft_params_id).asset.json;
		if (json_data != null)
		{		
			BeatManager.bands[0].low = json_data.band[0];
			BeatManager.bands[0].high = json_data.band[1];
			BeatManager.multipliers[0] = json_data.peak[0];
		}
		
		Main.beat_manager.load_song(audio_fn);
		audio_fn = "";
		audio_fft_params_id = "";
	}
	
	function on_audio_cfg_notfound(e)
	{
		trace("cfg file not found");
		
		Main.beat_manager.load_song(audio_fn);
		audio_fn = "";
		audio_fft_params_id = "";
	}
	
	public function on_audio_analysis_completed(e)
	{
		change_state_signal = true;
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (change_state_signal)
		{
			machine.set(next_state, game_state_on_enter_data);
		}
		
		// fade music in/out if we need to
		if (music_handle != null)
		{
			Luxe.audio.volume(music_handle, music_volume);
		}
	}
}
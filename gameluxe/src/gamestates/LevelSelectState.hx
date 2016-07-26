package gamestates;

import data.GameInfo;
import entities.BeatManager;
import gamestates.GameState.GameStateOnEnterData;
import haxe.io.Path;
import luxe.Audio.AudioState;
import luxe.Color;
import luxe.Input.Key;
import luxe.Input.MouseButton;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Scene;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.Actuate;
import mint.Button;
import mint.Label;
import mint.render.luxe.Panel;
import mint.types.Types.TextAlign;
import phoenix.BitmapFont;
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
	
	/// events
	var event_id : Array<String>;
	
	var tut_sprite : Sprite;
	public static function create_tut_sprite( scene : Scene ) : Sprite
	{
		var spr = new Sprite({
			texture: Luxe.resources.texture("assets/image/tutorial_screen.png"),
			pos: new Vector(720, 450),
			size: new Vector(500, 900),
			scene: scene,
			visible: false,
			batcher: Main.batcher_ui,
			depth: 10
		});
		
		return spr;
	}

	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
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
		
		// unlisten
		for (i in 0...event_id.length)
		{
			var res = Luxe.events.unlisten(event_id[i]);
		}
		event_id = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering level select");
		
		event_id = new Array<String>();
		event_id.push(Luxe.events.listen("BeatManager.AudioLoaded", on_audio_analysis_completed ));
		event_id.push(Luxe.events.listen("BeatManager.AudioAnalysisStart", on_audio_analysis_started ));
		event_id.push(Luxe.events.listen("BeatManager.AudioLoadingFailed", on_audio_analysis_failed ));
		
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
		
		tut_sprite = create_tut_sprite(scene);
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/level_select.json");
		var layout_data = json_resource.asset.json;
		
		//MenuState.create_image(layout_data.background);
		
		var item = new MintImageButton(Main.canvas, "Story", new Vector(470+150, 250), new Vector(205, 52), "assets/image/ui/UI_track_selection_story.png");
		item.onmouseup.listen(function(e, c) {
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
			
			var exe_path = Sys.executablePath();
			var exe_dir = Path.directory(exe_path);
			var arcade_dir = exe_dir + "\\assets\\music_arcade";
			var result:Array<String> = Dialogs.openFile(
			"Rise - Arcade Mode Track Selection"
			, "Please select your favorite track, enjoy the beats while rising to teh top"
			, arcade_dir
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
		item.onmouseup.listen(function(e, c) {
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
	
	public function on_audio_analysis_started(e)
	{	
		tut_sprite.visible = true;
	}
	
	public function on_audio_analysis_failed(e)
	{
		tut_sprite.visible = false;
		change_state_signal = false;
	}
	
	public function on_audio_analysis_completed(e)
	{
		Luxe.timer.schedule(2.0, function(){
			
			var click_to_cont = new Text({
				font: Luxe.resources.font(Main.rise_font_id),
				text: "Click to Continue...",
				align: phoenix.BitmapFont.TextAlign.center,
				align_vertical: phoenix.BitmapFont.TextAlign.center,
				point_size: 36,
				pos: new Vector(Main.mid_screen_pos().x, 275),
				scene: scene,
				color: new Color().rgb(0x3f2414),
				outline: 0,
				glow_amount: 0,
				visible: true,
				batcher: Main.batcher_ui,
				depth: 11
			});	
			click_to_cont.color.a = 0;
			
			var fade_in_duration = 2.5;
			var first_delay = 1.0;
			Actuate.tween(click_to_cont.color, fade_in_duration, { a: 1.0 }).delay(first_delay).onComplete(
				function()
				{
					Actuate.tween(click_to_cont.color, 2.6, { a: 0.1 }).repeat( -1).reflect();
				});
			
			change_state_signal = true;
		});
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		var change_state_user = Luxe.input.mousepressed(MouseButton.left) ||
			Luxe.input.mousepressed(MouseButton.right) ||
			Luxe.input.keypressed(Key.space) ||
			Luxe.input.keypressed(Key.escape) ||
			Luxe.input.keypressed(Key.backspace);
		
		if (change_state_signal && change_state_user)
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
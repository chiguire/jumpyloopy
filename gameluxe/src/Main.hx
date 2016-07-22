package;

import data.AchievementManager;
import data.GameInfo;
import data.GameInfo.ScoreList;
import entities.BeatManager;
import entities.CollectableManager;
import gamestates.CreditsState;
import gamestates.GameState;
import gamestates.HighScoreState;
import gamestates.LevelSelectState;
import gamestates.MenuState;
import gamestates.ScoreState;
import gamestates.StoryCompleteState;
import gamestates.StoryEndingState;
import gamestates.StoryIntroState;
import gamestates.SplashState;
import gamestates.ShopState;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.io.Bytes;
import luxe.Audio.AudioHandle;
import luxe.Audio.AudioState;
import luxe.Camera;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Scene;
import luxe.Screen.WindowEvent;
import luxe.Sprite;
import luxe.States;
import haxe.xml.Fast;
import luxe.Rectangle;
import luxe.Input;
import luxe.Vector;
import luxe.resource.Resource.AudioResource;
import luxe.tween.Actuate;
import mint.Canvas;
import mint.focus.Focus;
import mint.layout.margins.Margins;
import mint.render.luxe.LuxeMintRender;
import phoenix.Batcher;
import sys.FileSystem;
import sys.io.File;
import ui.AutoCanvas;

class Main extends luxe.Game 
{
	public static var global_info : GlobalGameInfo;
	public static var user_data : UserDataV1;
	private var game_info : GameInfo;
	private var machine : States;
	
	public static var cheat_code : CheatCode;
		
	public static var WARCHILD_URL = "https://www.warchild.org.uk/";
	
	public static var rise_font_id = "assets/image/font/later_on.fnt";
	public static var letter_font_id = "assets/image/font/jenna_sue.fnt";
	
	public static var letter_id = "assets/data/letter.json";
	
	/// Camera
	public static var batcher_bg : Batcher;
	public static var camera_bg : Camera;
	public static var batcher_ui : Batcher;
	public static var camera_ui : Camera;
	
	/// UI by mint
	public static var canvas : AutoCanvas;
	public static var mint_rendering : LuxeMintRender;
	public static var layout : Margins;
	public static var focus : Focus;
	
	/// Beat Manager
	public static var beat_manager (default, null) : BeatManager;
	
	/// Achievement
	public static var achievement_manager (default, null) : AchievementManager;
	
	/// Frontend audio
	public static var fe_audio_res : AudioResource;
	public static var fe_audio_handle : AudioHandle;
	public static var fe_audio_volume = 0.0;
	
	public static function gameplay_area_size() : Vector
	{
		return new Vector( 500, 900 );
	}
	
	public static function mid_screen_pos() : Vector
	{
		return new Vector(global_info.ref_window_size_x / 2, global_info.ref_window_size_y / 2); 
	}
	
	public static function ref_window_aspect() : Float
	{
		return global_info.ref_window_size_x / global_info.ref_window_size_y;
	}
	
	// load parcel with progress bar
	public static function load_parcel( parcel: Parcel, parcel_id: String, on_complete: Parcel->Void)
	{
		// load parcels
		parcel = new Parcel();
		parcel.from_json(Luxe.resources.json(parcel_id).asset.json);
		
		var progress = new ParcelProgress({
            parcel      : parcel,
            background  : new Color(0,0,0,0.85),
            oncomplete  : on_complete,
			no_visuals 	: true
        });
		
		parcel.load();
	}
	
	// common background sprite
	public static function create_background( scene : Scene, ?background_id : String) : Sprite
	{
		var bg_id = (background_id != null) ? background_id : "assets/image/ui/UI_menus_background.png";
		
		var bg = new Sprite({
			pos: mid_screen_pos(),
			size: new Vector(global_info.ref_window_size_x, global_info.ref_window_size_y),
			name: 'ui_bg',
			scene: scene,
			texture: Luxe.resources.texture(bg_id),
			batcher: Main.batcher_ui,
		});
		return bg;
	}
	
	public static function create_transition_sprite( scene : Scene ) : Sprite
	{
		var s = new Sprite({
			pos: Main.mid_screen_pos(),
			//size : new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y),
			size : new Vector(500, Main.global_info.ref_window_size_y),
			color: new Color(0, 0, 0, 1),
			batcher: Main.batcher_ui,
			scene: scene,
			depth: 99
		});
		
		return s;
	}
	
	public static function simple_fade_in( spr : Sprite, on_complete : Void -> Void )
	{
		spr.visible = true;
		spr.color.a = 0;
		Actuate.tween(spr.color, 3.0, {a:1}).onComplete(function() {	
			on_complete();
		});
	}
	
	public static function simple_fade_out( spr : Sprite, on_complete : Void -> Void )
	{
		spr.visible = true;
		spr.color.a = 1;
		Actuate.tween(spr.color, 3.0, {a:0}).onComplete(function() {
			spr.visible = false;
			on_complete();
		});
	}
	
	public static function simple_fe_audio_begin()
	{
		// audio
		if (fe_audio_handle == null || Luxe.audio.state_of(fe_audio_handle) != AudioState.as_playing)
		{
			fe_audio_res = Luxe.resources.audio("assets/music/Warchild_Menu.ogg");
			fe_audio_handle = Luxe.audio.loop(fe_audio_res.source);
			
			Luxe.audio.volume(fe_audio_handle, 0.0);
			var tween = Actuate.tween(Main, 3.0, {fe_audio_volume: global_info.audio_volume});
			tween.onUpdate( function(){ Luxe.audio.volume(fe_audio_handle, fe_audio_volume); });
			
			trace("fe_audio");
		}
	}
	
	public static function simple_fe_audio_end()
	{
		// audio
		var tween = Actuate.tween(Main, 3.0, {fe_audio_volume: 0.0});
		tween.onUpdate( function(){ Luxe.audio.volume(fe_audio_handle, fe_audio_volume); });
		tween.onComplete( function(){ Luxe.audio.stop(fe_audio_handle); });
	}
	
	override function ready() 
	{
		//app.debug.visible = true;
		// achievement
		achievement_manager = new AchievementManager();
		
		load_user_data();
		
		achievement_manager.unlockables = Main.user_data.unlockables;
		
		// camera
		// create views for all layers
		var viewport_size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		camera_bg = new Camera({name: "camera_bg"});
		camera_bg.size = viewport_size.clone();
		batcher_bg = Luxe.renderer.create_batcher({name: "viewport_bg", layer: -1, camera: camera_bg.view});
		
		Luxe.camera.size = viewport_size.clone();
		
		camera_ui = new Camera({name: "camera_ui"});
		camera_ui.size = viewport_size.clone();
		batcher_ui = Luxe.renderer.create_batcher({name: "viewport_ui", layer: 1, camera: camera_ui.view});
		
		// UI rendering initilization
		mint_rendering = new LuxeMintRender({batcher: batcher_ui, depth:4});
		layout = new Margins();
		
		//var scale = global_info.ref_window_size_x/Luxe.screen.w;
		var auto_canvas = new AutoCanvas(
		{
			name: "canvas",
			rendering: mint_rendering,
			//scale: scale,
			x: 0, y: 0, w: global_info.ref_window_size_x, h:global_info.ref_window_size_y,
			camera : camera_ui
		});
		
		auto_canvas.auto_listen();
		canvas = auto_canvas;
		focus = new Focus(canvas);
		///////////////////////////////////

		// audio/ beat manager
		beat_manager = new BeatManager({batcher : batcher_ui});
		
		var effects_volume = Std.parseFloat(Luxe.io.string_load("effects_volume"));
		game_info = {
			effects_volume: if (Math.isNaN(effects_volume)) 0.8 else effects_volume,
		};
		
		machine = new States({ name: 'appmachine' });
		
		machine.add(new MenuState("MenuState", game_info));
		machine.add(new LevelSelectState("LevelSelect", game_info));
		machine.add(new StoryIntroState("StoryIntroState", game_info));
		machine.add(new StoryEndingState("StoryEndingState", game_info));
		machine.add(new StoryCompleteState("StoryCompleteState", game_info));
		machine.add(new GameState("GameState", game_info));
		machine.add(new ScoreState("ScoreState", game_info));
		machine.add(new HighScoreState("HighScoreState", game_info));
		machine.add(new CreditsState("CreditsState", game_info));
		machine.add(new SplashState("SplashState", game_info));
		machine.add(new ShopState("ShopState", game_info));
		
		var parcel = new Parcel();
		Main.load_parcel(parcel, "assets/data/common_parcel.json", function(p:Parcel){
#if debug
			machine.set("MenuState");
#else
			machine.set("SplashState");
#end
			//Loading here as we need the groups to have been loaded at this point.
			achievement_manager.OnParcelLoaded();
			
		});
	}

	override function config(config:luxe.GameConfig) 
	{
		global_info = 
		{
			ref_window_size_x : config.user.ref_window_size[0] ? config.user.ref_window_size[0] : 1440,
			ref_window_size_y : config.user.ref_window_size[1] ? config.user.ref_window_size[1] : 900,
			window_size_x : config.user.window_size[0] ? config.user.window_size[0] : 1440,
			window_size_y : config.user.window_size[1] ? config.user.window_size[1] : 900,
			fullscreen : false, // current broken in fullscreen mode
			borderless : false,
			platform_lifetime : config.user.platform_lifetime ? config.user.platform_lifetime : 15.0,
			text_color: new Color(0x3f / 255.0, 0x24 / 255.0, 0x14 / 255.0, 1.0), 
			user_storage_filename: "storage.bin",
			audio_volume: config.user.audio_volume ? config.user.audio_volume : 1.0,
		};
		
		config.window.title = 'Rise';
#if (web && sample)
		config.window.width = global_info.ref_window_size_x;// 405;
		config.window.height = global_info.ref_window_size_y;// 720;
#else
		config.window.width = global_info.window_size_x;// 405;
		config.window.height = global_info.window_size_y;// 720;
		config.window.borderless = global_info.borderless;
		config.window.fullscreen = global_info.fullscreen;
		config.window.resizable = false;
#end
	
		// preload all parcel description
		config.preload.jsons.push({id:"assets/data/common_parcel.json"});
		config.preload.jsons.push({id:"assets/data/frontend_parcel.json"});
		config.preload.jsons.push({id:"assets/data/level_select_parcel.json"});
		config.preload.jsons.push({id:"assets/data/story_intro_parcel.json"});
		config.preload.jsons.push({id:"assets/data/game_state_parcel.json"});
		config.preload.jsons.push({id:"assets/data/shop_parcel.json"});
		
		// cheat codes
		cheat_code = {  
			showmethemoney : Lambda.exists(Sys.args(), function(obj) { return obj == "showmethemoney"; }),
		};
		
        return config;

    } //config
	
	override function onwindowresized( e:WindowEvent ) 
	{
        trace('window resized : ${e.x} / ${e.y}');
		//canvas.set_size(e.x, e.y);
    }
	
	public static function load_user_data()
	{
		if (!FileSystem.exists(global_info.user_storage_filename))
		{
			// Initialize data
			var userdata_header : UserDataHeader = { version: 1.0 };
			
			// Example data
			user_data = {unlockables: Main.achievement_manager.unlockables };
			user_data.user_name = "";
			user_data.score_list = new ScoreList();
			
			var score_run_a : Array<ScoreRun> = [
				{
					name: "AAA",
					score: 10000,
					distance: 100,
					time: 0,
				},
				{
					name: "AAA",
					score: 9000,
					distance: 90,
					time: 0,
				},
				{
					name: "AAA",
					score: 8000,
					distance: 80,
					time: 0,
				},
				{
					name: "AAA",
					score: 7000,
					distance: 70,
					time: 0,
				},
				{
					name: "AAA",
					score: 6000,
					distance: 60,
					time: 0,
				},
			];
			
			user_data.score_list.set("6eba6c00b1971ef68b7897a41ce459d4",
			{
				name: "Training",
				scores: score_run_a,
			});
			
			user_data.score_list.set("e1c230c608ea62436abde2ee6d412e8d",
			{
				name: "Story",
				scores: score_run_a,
			});
			
			var serializer = new Serializer();
			serializer.serialize(userdata_header);
			serializer.serialize(user_data);
			
			var bytes_data = Bytes.ofString(serializer.toString());
				
			File.saveBytes(global_info.user_storage_filename, bytes_data);
		}
		
		var fin = File.read(global_info.user_storage_filename);
		var bytes_data = fin.readAll();
		
		var unserializer = new Unserializer(bytes_data.toString());
		var user_data_header = unserializer.unserialize();
		user_data = unserializer.unserialize();
	}
	
	public static function save_user_data()
	{
		var serializer = new Serializer();
		
		var userdata_header : UserDataHeader = { version: 1.0 };
		serializer.serialize(userdata_header);
		serializer.serialize(user_data);
		
		var bytes_data = Bytes.ofString(serializer.toString());
			
		File.saveBytes(global_info.user_storage_filename, bytes_data);
	}
	
	public static function submit_score(score:ScoreRun)
	{
		var song_id = score.song_id;
		score.song_id = null;
		
		if (!user_data.score_list.exists(song_id))
		{
			user_data.score_list.set(song_id, {
				name: song_id,
				scores: [
					{
						name: "AAA",
						score: 10000,
						distance: 100,
						time: 0,
					},
					{
						name: "AAA",
						score: 9000,
						distance: 90,
						time: 0,
					},
					{
						name: "AAA",
						score: 8000,
						distance: 80,
						time: 0,
					},
					{
						name: "AAA",
						score: 7000,
						distance: 70,
						time: 0,
					},
					{
						name: "AAA",
						score: 6000,
						distance: 60,
						time: 0,
					},
				],
			});
		}
		var arr : Array<ScoreRun> = user_data.score_list.get(song_id).scores;
		
		var found = -1;
		for (i in 0...arr.length)
		{
			if (score.score > arr[i].score)
			{
				found = i;
				break;
			}
		}
		
		if (found == -1)
		{
			return;
		}
		
		arr.insert(found, score);
		arr.pop();
		
		user_data.score_list.get(song_id).scores = arr;
		
		save_user_data();
	}
}

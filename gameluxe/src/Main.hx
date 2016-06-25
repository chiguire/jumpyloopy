package;

import data.GameInfo;
import data.GameInfo.ScoreList;
import entities.BeatManager;
import gamestates.CreditsState;
import gamestates.GameState;
import gamestates.LevelSelectState;
import gamestates.MenuState;
import gamestates.ScoreState;
import luxe.Camera;
import luxe.Screen.WindowEvent;
import luxe.States;
import haxe.xml.Fast;
import luxe.Rectangle;
import luxe.Input;
import luxe.Vector;
import mint.Canvas;
import mint.focus.Focus;
import mint.layout.margins.Margins;
import mint.render.luxe.LuxeMintRender;
import phoenix.Batcher;
import ui.AutoCanvas;

class Main extends luxe.Game 
{
	public static var global_info : GlobalGameInfo;
	
	private var game_info : GameInfo;
	private var machine : States;
		
	public static var WARCHILD_URL = "https://www.warchild.org.uk/";
	
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
	
	public static function ref_window_aspect() : Float
	{
		return global_info.ref_window_size_x / global_info.ref_window_size_y;
	}
	
	override function ready() 
	{
		//app.debug.visible = true;
		
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
		//beat_manager = new BeatManager({batcher : batcher_ui});
		
		var music_volume = Std.parseFloat(Luxe.io.string_load("music_volume"));
		var effects_volume = Std.parseFloat(Luxe.io.string_load("effects_volume"));
		game_info = {
			spritesheet_elements: create_spritesheet_elements(),
			score_list: create_score_list(),
			music_volume: if (Math.isNaN(music_volume)) 0.5 else music_volume,
			effects_volume: if (Math.isNaN(effects_volume)) 0.8 else effects_volume,
		};
		
		machine = new States({ name: 'appmachine' });
		
		machine.add(new MenuState("MenuState", game_info));
		machine.add(new LevelSelectState("LevelSelect", game_info));
		machine.add(new GameState("GameState", game_info));
		machine.add(new ScoreState("ScoreState", game_info));
		machine.add(new CreditsState("CreditsState", game_info));
		
		machine.set("MenuState");
	}

	override function config(config:luxe.GameConfig) 
	{
		global_info = 
		{
			ref_window_size_x : config.user.ref_window_size[0] ? config.user.ref_window_size[0] : 1440,
			ref_window_size_y : config.user.ref_window_size[1] ? config.user.ref_window_size[1] : 900,
			window_size_x : config.user.window_size[0] ? config.user.window_size[0] : 1440,
			window_size_y : config.user.window_size[1] ? config.user.window_size[1] : 900,
			fullscreen : false,
			borderless : true
		};
		
#if (web && sample)
		config.window.width = global_info.ref_window_size_x;// 405;
		config.window.height = global_info.ref_window_size_y;// 720;
#else
		config.window.width = global_info.window_size_x;// 405;
		config.window.height = global_info.window_size_y;// 720;
		config.window.borderless = true;
#end
		
		config.preload.jsons.push({id:"assets/data/frontend_parcel.json"});
		config.preload.jsons.push({id:"assets/data/level_select_parcel.json"});
		config.preload.jsons.push({id:"assets/animation/animation_jumper.json"});

		// move to parcel
		config.preload.textures.push({id:"assets/image/bg/sky_01_tiling.png"});
		config.preload.textures.push({id:"assets/image/bg/space_01_transition.png"});
		config.preload.textures.push({id:"assets/image/bg/space_02_tiling.png"});
		
        config.preload.textures.push({id:'assets/image/spritesheet_jumper.png'});
        config.preload.texts.push({id:'assets/image/spritesheet_jumper.xml'});

        return config;

    } //config
	
	private function create_spritesheet_elements()
	{
		var spritesheet_txt : String = Luxe.resources.text('assets/image/spritesheet_jumper.xml').asset.text;
		var spritesheet_xml = new Fast(Xml.parse(spritesheet_txt).firstElement());
		var result = new SpritesheetElements();
		for (xml in spritesheet_xml.nodes.SubTexture)
		{
			result.set(xml.att.name, new Rectangle(
				Std.parseFloat(xml.att.x), Std.parseFloat(xml.att.y),
				Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height)));
		}
		
		return result;
	}
	
	private function create_score_list()
	{
		var values_array : Array<String> = Luxe.io.string_load("scores").split(",");
		var score_list : ScoreList = new ScoreList();
		
		var i = 0;
		var name : String = "";
		
		for (s in values_array)
		{
			if (i == 0)
			{
				name = s;
			}
			else
			{
				var score = Std.parseInt(s);
				
				score_list.push({name: name, score: score});
			}
			
			i = (i + 1) % 2;
		}
		
		return score_list;
	}
	
	override function onwindowresized( e:WindowEvent ) 
	{
        trace('window resized : ${e.x} / ${e.y}');
		//canvas.set_size(e.x, e.y);
    }
}

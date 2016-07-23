package;

import luxe.Camera;
import luxe.Color;
import luxe.Game;
import luxe.GameConfig;
import luxe.Input;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Sprite;
import ui.MintButton;

import mint.Canvas;
import mint.focus.Focus;
import mint.layout.margins.Margins;
import mint.render.luxe.LuxeMintRender;

import ui.AutoCanvas;

class Main extends luxe.Game 
{
	public static var font_id = "launcher_assets/font/later_on.fnt";
	
	/// UI by mint
	public static var canvas : AutoCanvas;
	public static var mint_rendering : LuxeMintRender;
	public static var layout : Margins;
	public static var focus : Focus;
	
	// simple parcel
	var parcel : Parcel;
	
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
	
	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
	}

	override function update(dt:Float) 
	{
	}
	
	override function ready() 
	{								
		// UI rendering initilization
		mint_rendering = new LuxeMintRender({depth:4});
		layout = new Margins();
		
		//var scale = global_info.ref_window_size_x/Luxe.screen.w;
		var auto_canvas = new AutoCanvas(
		{
			name: "canvas",
			rendering: mint_rendering,
			x: 0, y: 0, w: app.game_config.window.width, h: app.game_config.window.height,
			camera : Luxe.camera,
		});
		
		auto_canvas.auto_listen();
		canvas = auto_canvas;
		focus = new Focus(canvas);
		///////////////////////////////////
		
		// create scene
		load_parcel(parcel, "launcher_assets/data/common_parcel.json", on_loaded);
	}
	
	public function on_loaded(p:Parcel)
	{
		create_scene();
	}
	
	override function config(config:luxe.GameConfig) 
	{	
		config.window.title = 'Rise - Launcher';

		config.window.width = 320;
		config.window.height = 320;
		config.window.borderless = false;
		config.window.fullscreen = false;
		config.window.resizable = false;
	
		// preload all parcel description
		config.preload.jsons.push({id:"launcher_assets/data/common_parcel.json"});
		
        return config;

    } //config
	
	
	public function create_scene()
	{
		var bg = new Sprite({
			pos: Luxe.screen.mid,
			size: Luxe.screen.size,
			texture: Luxe.resources.texture("launcher_assets/image/UI_Game_Pause_paper.png"),
		});
		bg.transform.scale.set_xy(1.2, 1.2);
		
		var logo = new Sprite({
			pos: Luxe.screen.mid,
			texture: Luxe.resources.texture("launcher_assets/image/rise_logo.png"),
		});
		logo.pos.y = 80;
		logo.transform.scale.set_xy(0.15, 0.15);
		
		var botton_size_x = 150;
		var botton_size_y = 42;
		var x = Luxe.screen.mid.x - botton_size_x * 0.5;
		
		var text_arry = ["Tiny 768x480", "Small 1024x640", "Normal 1440x900", "Large 1920x1200"];
		var cmd_args = ["win_tiny", "win_small", "win_normal", "win_large"];
		
		var os = Sys.systemName();
		var app = "rise.exe";
		var workingdir = Sys.getCwd();
		
		for (i in 0...4)
		{
			new MintButton({
				parent: canvas,
				x: x, y: 128 + (botton_size_y + 0) * i, w: botton_size_x, h: botton_size_y,
				text: text_arry[i],
				options: {},//color_hover: new Color().rgb(0xf6007b) },
				text_size: 24,
				onclick: function(e, c) { 
					var result = systools.win.Tools.createProcess( 
						app			// app. path
						, cmd_args[i]	// app. args
						, workingdir	// app. working directory
						, false		// do not hide the window
						, false		// do not wait for the application to terminate
					); Luxe.shutdown(); },
			});
		}
		
	}
}

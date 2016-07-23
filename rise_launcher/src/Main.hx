package;

import luxe.Camera;
import luxe.Color;
import luxe.Game;
import luxe.GameConfig;
import luxe.Input;
import ui.MintButton;

import mint.Canvas;
import mint.focus.Focus;
import mint.layout.margins.Margins;
import mint.render.luxe.LuxeMintRender;

import ui.AutoCanvas;

class Main extends luxe.Game 
{
	/// UI by mint
	public static var canvas : AutoCanvas;
	public static var mint_rendering : LuxeMintRender;
	public static var layout : Margins;
	public static var focus : Focus;
	
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
		create_scene();
	}
	
	override function config(config:luxe.GameConfig) 
	{		
		config.window.title = 'Rise';

		config.window.width = 320;
		config.window.height = 320;
		config.window.borderless = false;
		config.window.fullscreen = false;
		config.window.resizable = false;
	
		// preload all parcel description
		config.preload.jsons.push({id:"assets/data/common_parcel.json"});
		
        return config;

    } //config
	
	
	public function create_scene()
	{
		var botton_size_x = 200;
		var botton_size_y = 32;
		var x = Luxe.screen.mid.x - botton_size_x * 0.5;
		
		var text_arry = ["Small 1024x640", "Normal 1440x900", "Large 1920x1200"];
		
		for (i in 0...3)
		{
			new MintButton({
				parent: canvas,
				x: x, y: 128 + (botton_size_y + 16) * i, w: botton_size_x, h: botton_size_y,
				text: text_arry[i],
				options: { },//color_hover: new Color().rgb(0xf6007b) },
				text_size: 16,
				onclick: function(e,c) {trace('mint button! ${Luxe.time}' );}
			});
		}
		
	}
}

package gamestates;

import analysis.FFT;
import data.GameInfo;
import haxe.Json;
import luxe.Camera;
import luxe.Input.MouseEvent;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Scene;
import luxe.Screen;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.Game;
import luxe.Text;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
import ui.Button;
	
/**
 * ...
 * @author 
 */
class MenuState extends State
{
	private var game_info : GameInfo;
	
	private var scene : Scene;
	private var title_text : Text;
	private var play_button : Button;
	private var scores_button : Button;
	private var credits_button : Button;
	
	var frontend_parcel : Parcel;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		scene = null;
		title_text = null;
		play_button = null;
		scores_button = null;
		credits_button = null;
	}
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
	}
	
	override function onleave<T>(_value:T)
	{
		trace("Exiting menu");
		
		play_button.destroy();
		scores_button.destroy();
		credits_button.destroy();
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
		
		play_button = null;
		scores_button = null;
		credits_button = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering menu");
		
		// load parcels
		frontend_parcel = new Parcel();
		frontend_parcel.from_json(Luxe.resources.json("assets/data/frontend_parcel.json").asset.json);
		
		var progress = new ParcelProgress({
            parcel      : frontend_parcel,
            background  : new Color(1,1,1,0.85),
            oncomplete  : on_loaded
        });
		
		frontend_parcel.load();
				
		scene = new Scene("MenuScene");
		//Luxe.camera.size_mode = luxe.SizeMode.contain;
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		//FFT.test_fft();
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/frontend.json");
		var layout_data = json_resource.asset.json;
		//trace(layout_data);
		
		var canvas = Main.canvas;
		
		title_text = new Text({
			text: "Jumpyloopy (please change this)",
			point_size: 48,
			color: Color.random(),
			scene: scene,
		});
		title_text.pos.set_xy(Main.global_info.ref_window_size_x / 2 - title_text.geom.text_width /2, 10);
		
		new mint.Button({
            parent: canvas,
            name: 'button1',
            x: 10, y: 52, w: 100, h: 100,
            text: 'mint',
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } },
            onclick: function(e,c) {trace('mint button! ${Luxe.time}' );}
        });
		
		var warchild_tex_id = "assets/image/war-child-logo-home.png";
		var warchild_tex = Luxe.resources.texture(warchild_tex_id); 
		var warchild_img = new mint.Image({
                parent: canvas, name: "warchild_img",
                x:layout_data.warchild_img.pos_x, y:layout_data.warchild_img.pos_y, w:warchild_tex.width, h:warchild_tex.height,
                path: warchild_tex_id,
				mouse_input: true
            });
		warchild_img.onmouseup.listen(
			function(e,c) 
			{
				trace('mint img button! ${Luxe.time}' );
				Sys.command("start", [Main.WARCHILD_URL]);
			}
		);
		
		play_button = new Button({
			name: "Play",
			pos: new Vector(layout_data.play_button.pos_x, layout_data.play_button.pos_y),
			text: {
				text: "Play",
				point_size: 12
			},
			scene: scene,
		});
		
		scores_button = new Button({
			name: "Scores",
			pos: new Vector(layout_data.score_button.pos_x, layout_data.score_button.pos_y),
			text: {
				text: "Scores",
				point_size: 12,
			},
			scene: scene,
		});
		
		credits_button = new Button({
			name: "Credits",
			pos: new Vector(layout_data.credits_button.pos_x, layout_data.credits_button.pos_y),
			text: {
				text: "Credits",
				point_size: 12,
			},
			scene: scene,
		});
		
		/*
		new Sprite(
		{
			pos: new Vector( 1440/2, 400 ),
			size: new Vector( 1420, 200 ),
			scene: scene,
		});
		*/
		
		scores_button.events.listen('button.clicked', function (e:ButtonEvent)
		{
			//machine.set("ScoreState");
			
			sdl.SDL.setWindowSize(Luxe.snow.runtime.window, 1024, Std.int(1024 * 1.0 / Main.ref_window_aspect()));
		});
		
		credits_button.events.listen('button.clicked', function (e:ButtonEvent)
		{
			//machine.set("CreditsState");
			// Luxe.snow.io.url_open(Main.WARCHILD_URL); //no implementation in Snow for native, Damn
			Sys.command("start", [Main.WARCHILD_URL]);
		});
		
		play_button.events.listen('button.clicked', function (e:ButtonEvent)
		{
			machine.set("GameState");
		});
		
		
	}
}
package gamestates;

import analysis.FFT;
import data.GameInfo;
import haxe.Json;
import luxe.Camera;
import luxe.Input.MouseEvent;
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
	
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		scene = null;
		title_text = null;
		play_button = null;
		scores_button = null;
		credits_button = null;
		
		// load resources
		Luxe.resources.load_json("assets/data/frontend.json").then(on_layout_loaded);
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
				
		scene = new Scene("MenuScene");
		//Luxe.camera.size_mode = luxe.SizeMode.contain;
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		title_text = new Text({
			text: "Jumpyloopy (please change this)",
			point_size: 48,
			color: Color.random(),
			scene: scene,
		});
		title_text.pos.set_xy(Main.global_info.ref_window_size_x / 2 - title_text.geom.text_width /2, 10);
		
		//FFT.test_fft();
	}
	
	function on_layout_loaded()
	{
		var layout_data = Luxe.resources.json("assets/data/frontend.json").asset.json;
		trace(layout_data);
		
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
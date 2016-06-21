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
import mint.Control;
import mint.Button;
	
/**
 * ...
 * @author 
 */
class MenuState extends State
{
	private var game_info : GameInfo;
	
	private var scene : Scene;
	private var title_text : Text;
	
	var frontend_parcel : Parcel;
	
	var change_to = "";
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		scene = null;
		title_text = null;
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
		
		Main.canvas.destroy_children();
		
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
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
	
	function create_button( button_data : Dynamic ) : Button
	{
		var canvas = Main.canvas;
		
		var button = new mint.Button({
            parent: canvas,
            name: 'button',
            text: button_data.text,
			w: button_data.width, h: button_data.height,
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } },
            onclick: function(e, c) { change_to = "LevelSelect"; }
        });
		button.set_pos(button_data.pos_x - button.w / 2, button_data.pos_y - button.h / 2);
		
		return button;
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
		
		var button1 = create_button( layout_data.play_button );
		button1.onmouseup.listen(
			function(e,c) 
			{
				change_to = "LevelSelect";
			}
		);
		
		var button2 = create_button( layout_data.score_button );
		button2.onmouseup.listen(
			function(e,c) 
			{
				change_to = "ScoreState";
				//sdl.SDL.setWindowSize(Luxe.snow.runtime.window, 1024, Std.int(1024 * 1.0 / Main.ref_window_aspect()));
			}
		);
		
		var button3 = create_button( layout_data.credits_button );
		button3.onmouseup.listen(
			function(e,c) 
			{
				change_to = "CreditsState";
			}
		);
		
		var warchild_tex_id = "assets/image/war-child-logo-home.png";
		var warchild_tex = Luxe.resources.texture(warchild_tex_id); 
		var warchild_img = new mint.Image({
                parent: canvas, name: "warchild_img",
                x:layout_data.warchild_img.pos_x - warchild_tex.width/2, y:layout_data.warchild_img.pos_y - warchild_tex.height/2, w:warchild_tex.width, h:warchild_tex.height,
                path: warchild_tex_id,
				mouse_input: true
            });
		
		warchild_img.onmouseup.listen(
			function(e,c) 
			{
				trace('mint img button! ${Luxe.time}' );
				//Sys.command("start", [Main.WARCHILD_URL]);
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
	}
}
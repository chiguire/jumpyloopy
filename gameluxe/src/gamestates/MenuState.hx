package gamestates;

import analysis.FFT;
import data.GameInfo;
import entities.Background;
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
import mint.Image;
import ui.MintImageButton;
	
/**
 * ...
 * @author 
 */
class MenuState extends State
{
	private var game_info : GameInfo;
	
	private var scene : Scene;
	private var title_text : Text;
	
	var parcel : Parcel;
	
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
	
	override function onleave<T>(_value:T)
	{
		trace("Exiting menu");
		
		Main.canvas.destroy_children();
		
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
		
		parcel = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering menu");
		
		// load parcels
		Main.load_parcel(parcel, "assets/data/frontend_parcel.json", on_loaded);
				
		scene = new Scene("MenuScene");
		//Luxe.camera.size_mode = luxe.SizeMode.contain;
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		// Background Layer
		Main.create_background(scene);
		
		var background1 = new Sprite({
			texture: Luxe.resources.texture('assets/image/frontend_bg.png'),
			pos: new Vector(720, 450),
			size: new Vector(500, 900),
			scene: scene,
		});
		
		// Audio 
		Main.simple_fe_audio_begin();
	}
	
	public static function create_image( data : Dynamic ) : Image
	{
		var canvas = Main.canvas;
		
		var tex_id = data.texture;
		var tex = Luxe.resources.texture(tex_id);
		
		var width = data.width ? data.width : tex.width;
		var height = data.height ? data.height : tex.height;
		
		var img = new mint.Image({
                parent: canvas, name: "img",
                x:data.pos_x - width/2, y:data.pos_y - height/2, w:width, h:height,
                path: tex_id,
            });
		
		return img;
	}
	
	public static function create_button( button_data : Dynamic ) : Button
	{
		var canvas = Main.canvas;
		
		var button = new mint.Button({
            parent: canvas,
            name: 'button',
            text: button_data.text,
			w: button_data.width, h: button_data.height,
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } }
        });
		button.set_pos(button_data.pos_x - button.w / 2, button_data.pos_y - button.h / 2);
		
		return button;
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/frontend.json");
		var layout_data = json_resource.asset.json;
		//trace(layout_data);
		
		// UI layer
		var canvas = Main.canvas;
		
		var button = new MintImageButton(canvas, "Play", new Vector(618, 365), new Vector(205, 54), "assets/image/ui/UI_titlescreen_play.png");
		button.onmouseup.listen(function(e, c) {
			change_to = "LevelSelect";
		});
		
		button = new MintImageButton(canvas, "Score", new Vector(618, 485), new Vector(206, 46), "assets/image/ui/UI_titlescreen_score.png");
		button.onmouseup.listen(function(e, c) {
			change_to = "HighScoreState";
		});
		
		button = new MintImageButton(canvas, "Credits", new Vector(618, 530), new Vector(207, 47), "assets/image/ui/UI_titlescreen_credits.png");
		button.onmouseup.listen(function(e, c) {
			change_to = "CreditsState";
		});
		
		button = new MintImageButton(canvas, "Unlockables", new Vector(618, 425), new Vector(207, 56), "assets/image/ui/UI_titlescreen_unlockables.png");
		button.onmouseup.listen(function(e, c) {
			change_to = "ShopState";
		});
		
		var warchild_tex_id = "assets/image/war-child-logo-home.png";
		var warchild_tex = Luxe.resources.texture(warchild_tex_id); 
		var warchild_img = new mint.Image({
                parent: canvas, name: "warchild_img",
                x:layout_data.warchild_img.pos_x - warchild_tex.width/2, y:layout_data.warchild_img.pos_y - warchild_tex.height/2, w:warchild_tex.width, h:warchild_tex.height,
                path: warchild_tex_id,
				mouse_input: true
            });
			
		warchild_img.onmouseenter.listen(
			function(e,c) 
			{
				var renderer = cast(warchild_img.renderer, mint.render.luxe.Image);
				var hsl = renderer.visual.color.toColorHSL();
				hsl.l *= 1.5;
				renderer.visual.color.fromColorHSL(hsl);
			}
		);
		
		warchild_img.onmouseleave.listen(
			function(e,c) 
			{
				var renderer = cast(warchild_img.renderer, mint.render.luxe.Image);
				var hsl = renderer.visual.color.toColorHSL();
				hsl.l /= 1.5;
				renderer.visual.color.fromColorHSL(hsl);
			}
		);
		
		warchild_img.onmouseup.listen(
			function(e,c) 
			{
				//trace('mint img button! ${Luxe.time}' );
				Sys.command("start", [Main.WARCHILD_URL]);
			}
		);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (Luxe.input.keypressed(Key.escape))
		{
			Luxe.shutdown();
		}
		
		if (change_to != "")
		{
			machine.set(change_to);
			change_to = "";
		}
	}
}
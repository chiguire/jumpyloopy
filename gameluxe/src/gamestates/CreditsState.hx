package gamestates;

import data.GameInfo;
import luxe.Sprite;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Scene;
import luxe.Input;
import luxe.Vector;
import luxe.Color;
import ui.MintImageButton;

/**
 * ...
 * @author 
 */
class CreditsState extends State
{
	private var game_info : GameInfo;

	private var scene : Scene;
	private var credits_image : Sprite;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			machine.set("MenuState");
	}
	
	override function onleave<T>(_value:T)
	{
		trace("Exiting Credits");
		
		credits_image.destroy();
		scene.empty();
		scene.destroy();
		scene = null;
		credits_image = null;
		
		Main.canvas.destroy_children();	
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering Credits");
		
		scene = new Scene("CreditsScene");
		
		Main.create_background(scene);
		
		var data : Dynamic = { pos_x: 720, pos_y: 450 };
		
		credits_image = new Sprite({
			name: 'CreditsSprite',
			texture: Luxe.resources.texture('assets/image/ui/credits.png'),
			pos: new Vector(data.pos_x, data.pos_y),
			scene: scene,
		});
		
		//Back Button	
		var back_button : MintImageButton = new MintImageButton(Main.canvas, "Back", new Vector(470+220, 853), new Vector(62, 38), "assets/image/ui/UI_track_selection_back.png");
	}
	
	override function update(dt:Float) 
	{
		var go_to_menu =
			Luxe.input.mousepressed(MouseButton.left) ||
			Luxe.input.mousepressed(MouseButton.right) ||
			Luxe.input.keypressed(Key.space) ||
			Luxe.input.keypressed(Key.escape) ||
			Luxe.input.keypressed(Key.backspace);
			
		if (go_to_menu)
		{
			machine.set("MenuState");
		}
	}
	
}
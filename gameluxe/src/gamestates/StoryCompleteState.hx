package gamestates;

import data.GameInfo;
import luxe.Color;
import luxe.Input.Key;
import luxe.Input.MouseButton;
import luxe.Parcel;
import luxe.Scene;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.Actuate;

/**
 * ...
 * @author Aik
 */
class StoryCompleteState extends State
{
	private var game_info : GameInfo;
	private var scene : Scene;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
	}
	
	override function onleave<T>(_value:T)
	{
		Actuate.reset();	
		
		scene.empty();
		scene.destroy();
		scene = null;
	}
	
	override function onenter<T>(_value:T)
	{		
		scene = new Scene();
		
		Main.create_background(scene);
		
		var background = new Sprite({
			texture: Luxe.resources.texture("assets/image/Ending_screen.png"),
			pos: Main.mid_screen_pos(),
			size: new Vector(500,900),
			scene: scene,
			batcher: Main.batcher_ui,
		});
	}
	
	override function update(dt:Float) 
	{
		var change_state = Luxe.input.mousepressed(MouseButton.left) ||
			Luxe.input.mousepressed(MouseButton.right) ||
			Luxe.input.keypressed(Key.space) ||
			Luxe.input.keypressed(Key.escape) ||
			Luxe.input.keypressed(Key.backspace);
			
		if(change_state)
		{
			machine.set("MenuState");
		}
	}
}
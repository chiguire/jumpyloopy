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
		
		var click_to_cont = new Text({
				font: Luxe.resources.font(Main.rise_font_id),
				text: "Click to Continue...",
				align: TextAlign.center,
				align_vertical: TextAlign.center,
				point_size: 36,
				pos: new Vector(Main.mid_screen_pos().x, 50),
				scene: scene,
				color: new Color().rgb(0x3f2414),
				outline: 0,
				glow_amount: 0,
				visible: true,
				batcher: Main.batcher_ui,
			});	
		click_to_cont.color.a = 0;
		
		var fade_in_duration = 1.5;
		var first_delay = 1.0;
		Actuate.tween(click_to_cont.color, fade_in_duration, { a: 1.0 }).delay(first_delay + first_delay * 11).onComplete(
			function()
			{
				Actuate.tween(click_to_cont.color, 2.6, { a: 0.1 }).repeat( -1).reflect();
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
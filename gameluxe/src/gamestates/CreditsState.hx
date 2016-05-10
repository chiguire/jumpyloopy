package gamestates;

import data.GameInfo;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Scene;
import luxe.Text;
import luxe.Input;
import luxe.Vector;
import luxe.Color;

/**
 * ...
 * @author 
 */
class CreditsState extends State
{
	private var game_info : GameInfo;

	private var scene : Scene;
	private var title_text : Text;
	private var play_text : Text;
	private var scores_text : Text;
	private var return_text : Text;
	
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
		
		return_text.destroy();
		scores_text.destroy();
		play_text.destroy();
		title_text.destroy();
		scene.destroy();
		scene = null;
		title_text = null;
		play_text = null;
		scores_text = null;
		return_text = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering Credits");
		
		scene = new Scene("CreditsScene");
		
		title_text = new Text({
			text: "Credits",
			point_size: 48,
			pos: new Vector(10, 10),
			color: Color.random(),
			scene: scene,
		});
		
		play_text = new Text({
			text: "Very awesome people",
			point_size: 18,
			pos: new Vector(10, 85),
			color: new Color(255, 255, 255),
			scene: scene,
		});
		
		scores_text = new Text({
			text: "CA",
			point_size: 18,
			pos: new Vector(10, 110),
			color: new Color(255, 255, 255),
			scene: scene,
		});
		
		return_text = new Text({
			text: "Return to Menu",
			point_size: 18,
			pos: new Vector(10, 135),
			color: new Color(255, 255, 255),
			scene: scene,
		});
	}
	
	override function onmousedown(event:MouseEvent)
	{
		if (return_text.point_inside(event.pos))
		{
			machine.set("MenuState");
		}
	}
}
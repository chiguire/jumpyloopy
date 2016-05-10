package gamestates;

import data.GameInfo;
import luxe.Input.MouseEvent;
import luxe.Scene;
import luxe.Vector;
import luxe.Color;
import luxe.Game;
import luxe.Text;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
	
/**
 * ...
 * @author 
 */
class MenuState extends State
{
	private var game_info : GameInfo;
	
	private var scene : Scene;
	private var title_text : Text;
	private var play_text : Text;
	private var scores_text : Text;
	private var credits_text : Text;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		scene = null;
		title_text = null;
		play_text = null;
		scores_text = null;
		credits_text = null;
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
		
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
		play_text = null;
		scores_text = null;
		credits_text = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering menu");
		
		scene = new Scene("MenuScene");
		
		title_text = new Text({
			text: "Jumpyloopy (please change this)",
			point_size: 48,
			pos: new Vector(10, 10),
			color: Color.random(),
			scene: scene,
		});
		
		play_text = new Text({
			text: "Play",
			point_size: 18,
			pos: new Vector(10, 85),
			color: new Color(255, 255, 255),
			scene: scene,
		});
		
		scores_text = new Text({
			text: "Scores",
			point_size: 18,
			pos: new Vector(10, 110),
			color: new Color(255, 255, 255),
			scene: scene,
		});
		
		credits_text = new Text({
			text: "Credits",
			point_size: 18,
			pos: new Vector(10, 135),
			color: new Color(255, 255, 255),
			scene: scene,
		});
	}
	
	override function onmousedown(event:MouseEvent)
	{
		if (play_text.point_inside(event.pos))
		{
			machine.set("GameState");
		}
		else if (scores_text.point_inside(event.pos))
		{
			machine.set("ScoreState");
		}
		else if (credits_text.point_inside(event.pos))
		{
			machine.set("CreditsState");
		}
	}
}
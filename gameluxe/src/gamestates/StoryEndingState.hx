package gamestates;

import data.GameInfo;
import luxe.Color;
import luxe.Scene;
import luxe.Text;
import luxe.options.StateOptions;
import luxe.States.State;

/**
 * ...
 * @author Aik
 */
class StoryEndingState extends State
{
	private var game_info : GameInfo;
	private var scene : Scene;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function onleave<T>(_value:T)
	{
		scene.empty();
		scene.destroy();
		scene = null;
	}
	
	override function onenter<T>(_value:T)
	{
		scene = new Scene();
		
		new Text({
			font: Luxe.resources.font(Main.letter_font_id),
			text: "Ending State Sentence\nDear Love",
			point_size: 48,
			pos: Main.mid_screen_pos(),
			scene: scene,
			color: new Color(1, 1, 1, 1),
			outline: 0,
			glow_amount: 0,
		});	
	}
}
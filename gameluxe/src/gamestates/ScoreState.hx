package gamestates;

import data.GameInfo;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;

/**
 * ...
 * @author 
 */
class ScoreState extends State
{
	private var game_info : GameInfo;
	
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
		trace("Menu 1 left with value " + _value);
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Menu 1 enter with value " + _value);
	}
	
}
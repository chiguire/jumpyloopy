package gamestates;

import data.GameInfo;
import luxe.options.StateOptions;
import luxe.States.State;

/**
 * ...
 * @author Aik
 */
class LevelSelectState extends State
{
	var game_info : GameInfo;

	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function onleave<T>(_value:T)
	{
		
	}
	
	override function onenter<T>(_value:T)
	{
		
	}
}
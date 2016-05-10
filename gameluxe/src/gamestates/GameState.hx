package gamestates;

import data.GameInfo;
import entities.Avatar;
import luxe.Input.Key;
import luxe.options.StateOptions;
import luxe.States.State;

/**
 * ...
 * @author 
 */
class GameState extends State
{
	private var game_info : GameInfo;
	
	var player_avatar : Avatar;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	
	override function init()
	{
		
	}
	
	override function onleave<T>(d:T)
	{
		//trace("Menu 1 left with value " + _value);
	}
	
	override function onenter<T>(d:T)
	{
		//trace("Menu 1 enter with value " + _value);
		player_avatar = new Avatar();
		
		
		// bind new input
		Luxe.input.bind_key("jump", Key.space);
	}
	
}
package gamestates;

import data.GameInfo;
import luxe.Input;
import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.options.StateOptions;
import luxe.States.State;

/**
 * ...
 * @author Simon
 */
class ShopState extends State
{
	private var game_info : GameInfo;
	
	var change_to : String;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (change_to != "")
		{
			machine.set(change_to);
			change_to = "";
		}
	}
	
	override public function onkeyup(event:KeyEvent) 
	{
		if(event.keycode == Key.escape)
			change_to = "MenuState";
	}
	
	override function onenter<T>(d:T)
	{
		super.onenter(d);
		trace("Entering Shop");
	}
	
	override public function onleave<T>(d:T) 
	{
		super.onleave(d);
		trace("Leaving Shop. Come again!");
	}
}
package data;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class AchievementManager
{
	public var total_coins : Int;
	public var current_coins : Int;
	public var unlocked_items : Array<String>;
	public var current_character_name : String;
	public var collected_fragments : Vector<Bool>;
	public var finished_story_mode = false;
	public var unlocked_backgrounds = new Array<String>();
	
	public function new() 
	{
		collected_fragments = new Vector<Bool>(10);
#if debug
			//Debugging stuff;
			current_coins = 2000;
#end
		//Default unlockables.
		unlocked_items = new Array();
		unlocked_items.push("Aviator");
		current_character_name = "Aviator";
	}
	
	public function update_collected_fragments( fragment_states : Array<Bool> )
	{
		for ( i in 0...collected_fragments.length )
		{
			collected_fragments[i] = (collected_fragments[i] == false) ? fragment_states[i] : collected_fragments[i];
		}
	}
	
	public function is_item_unlocked(name : String) : Bool
	{
		for (i in 0 ... unlocked_items.length)
		{
			if (unlocked_items[i] == name)
				return true;
		}
		
		return false;
	}
	
	public function is_background_unlocked( s :String ) : Bool
	{
		return Lambda.exists(unlocked_backgrounds, function(obj) { return obj == s; });
	}
	
	public function unlock_background( s: String )
	{
		if (is_background_unlocked(s) == false)
		{
			unlocked_backgrounds.push(s);
		}
	}
}
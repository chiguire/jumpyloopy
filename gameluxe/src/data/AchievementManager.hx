package data;
import haxe.ds.Vector;
import luxe.importers.bitmapfont.BitmapFontData.Character;

/**
 * ...
 * @author 
 */
class AchievementManager
{
	public var total_coins : Int;
	public var current_coins : Int;
	
	public var collected_fragments : Vector<Bool>;
	public var finished_story_mode = false;
	
	public var character_groups : Array<CharacterGroup>;
	public var background_groups : Array<BackgroundGroup>;
	
	public var selected_character : String;
	public var selected_background : String;
	
	public var unlocked_backgrounds = new Array<String>();
	public var unlocked_characters = new Array<String>();
	
	public function new() 
	{
		collected_fragments = new Vector<Bool>(10);
#if debug
		//Debugging stuff;
		current_coins = 2000;
#end
		//Default unlockables.

		unlocked_characters.push("Aviator");
		selected_character = "Aviator";
		
		unlocked_backgrounds.push("paper");
	}
	
	public function update_collected_fragments( fragment_states : Array<Bool> )
	{
		for ( i in 0...collected_fragments.length )
		{
			collected_fragments[i] = (collected_fragments[i] == false) ? fragment_states[i] : collected_fragments[i];
		}
	}
	
	public function is_character_unlocked( s :String ) : Bool
	{
		return Lambda.exists(unlocked_characters, function(obj) { return obj == s; });
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
	
	public function unlock_character( s: String )
	{
		if (is_character_unlocked(s) == false)
		{
			unlocked_characters.push(s);
		}
	}
	
	public function select_character( s: String )
	{
		if (is_character_unlocked(s) == true)
		{
			selected_character = s;
		}
	}
	
	public function select_background( s: String)
	{
		if (is_background_unlocked(s) == true)
		{
			selected_background = s;
		}
	}
}
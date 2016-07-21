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
	public var completed_story_mode = false;
	
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
		selected_background = "paper";
	}
	
	public function OnParcelLoaded()
	{
		//Load unlockables data
		load_background_groups();
		load_character_data();
	}
	
	public function update_completed_story_mode( story_mode_end : Bool )
	{
		if (completed_story_mode == true) return;
		
		completed_story_mode = story_mode_end;
		for (i in 0...collected_fragments.length)
		{
			if (collected_fragments[i] == false)
			{
				completed_story_mode = false;
			}
		}
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
	
	private function load_background_groups()
	{
		var json = Luxe.resources.json("assets/data/background_groups.json").asset.json;
		
		background_groups = new Array<BackgroundGroup>();
		var groups : Array<Dynamic> = json.groups;
		for (i in 0...groups.length)
		{
			trace(groups[i]);
			var group = new BackgroundGroup();
			group.load_group(groups[i]);
			background_groups.push(group);
		}
	}
	
	private function load_character_data()
	{
		var json_resource = Luxe.resources.json("assets/data/character_groups.json");
		var data : Array<Dynamic> = json_resource.asset.json.characters;
		
		character_groups = new Array<CharacterGroup>();
		
		for (i in 0...data.length)
		{
			var n = data[i];
			character_groups.push(new CharacterGroup(n.name, n.tex_path, n.game_texture, n.cost));
		}
	}
}
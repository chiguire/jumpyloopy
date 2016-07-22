package data;
import data.GameInfo.Unlockables;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class AchievementManager
{
	public var unlockables : Unlockables;
	
	public var character_groups : Array<CharacterGroup>;
	public var background_groups : Array<BackgroundGroup>;
	
	public function new() 
	{
		//Default unlockables.
		unlockables = {
			total_coins : 0,
			current_coins : 0,
			completed_story_mode : false,
			collected_fragments : new Array<Bool>(),
			unlocked_characters : ["Aviator"],
			selected_character : "Aviator",
			unlocked_backgrounds : ["paper"],
			selected_background : "paper",
		};
		
		for (i in 0...10)
		{
			unlockables.collected_fragments.push(false);
		}
		
		//for (i in 1...collected_fragments.length) collected_fragments[i] = true;
	}
	
	public function OnParcelLoaded()
	{		
#if debug
		//Debugging stuff;
		unlockables.current_coins += 2500;
#end

		if(Main.cheat_code.showmethemoney) unlockables.current_coins += 2000;
		
		//Load unlockables data
		load_background_groups();
		load_character_data();
	}
	
	public function update_completed_story_mode( story_mode_end : Bool )
	{
		if (unlockables.completed_story_mode == true) return;
		
		unlockables.completed_story_mode = story_mode_end;
		for (i in 0...unlockables.collected_fragments.length)
		{
			if (unlockables.collected_fragments[i] == false)
			{
				unlockables.completed_story_mode = false;
			}
		}
	}
	
	public function update_collected_fragments( fragment_states : Array<Bool> )
	{
		for ( i in 0...unlockables.collected_fragments.length )
		{
			unlockables.collected_fragments[i] = (unlockables.collected_fragments[i] == false) ? fragment_states[i] : unlockables.collected_fragments[i];
		}
	}
	
	public function is_character_unlocked( s :String ) : Bool
	{
		return Lambda.exists(unlockables.unlocked_characters, function(obj) { return obj == s; });
	}
	
	public function is_background_unlocked( s :String ) : Bool
	{
		return Lambda.exists(unlockables.unlocked_backgrounds, function(obj) { return obj == s; });
	}
	
	public function unlock_background( s: String )
	{
		if (is_background_unlocked(s) == false)
		{
			unlockables.unlocked_backgrounds.push(s);
			trace("unlocked bg " + s);
		}
	}
	
	public function unlock_character( s: String )
	{
		if (is_character_unlocked(s) == false)
		{
			unlockables.unlocked_characters.push(s);
		}
	}
	
	public function select_character( s: String )
	{
		if (is_character_unlocked(s) == true)
		{
			unlockables.selected_character = s;
		}
	}
	
	public function select_background( s: String)
	{
		if (is_background_unlocked(s) == true)
		{
			unlockables.selected_background = s;
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
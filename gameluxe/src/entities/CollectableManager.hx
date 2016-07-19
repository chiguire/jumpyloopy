package entities;
import entities.CollectableManager.CollectableGroup;
import gamestates.GameState;
import luxe.Debug;
import luxe.Entity;
import luxe.Scene;
import luxe.Vector;
import luxe.debug.TraceDebugView;
import luxe.utils.Random;

/**
 * ...
 * @author sm
 */
class CollectableManager extends Entity
{
	public var min_rows : Int = 5;
	public var rows_between_groups : Int = 1;
	public var initial_blank_rows : Int = 3;
	public var row_height : Float;
	public var lanes : Array<Float> = new Array();
	
	public var group_templates : Array<CollectableGroupData> = new Array();
	public var existing_groups : Array<CollectableGroup> = new Array();
	
	public var collectable_spawn_random : Random;
	public var rotation_random : Random;
	
	private var group_i = 0;
	private var game_state : GameState;
	
	public var story_coll_index : Int = 0;
	public var story_fragment_spawn_pct : Array<Float> = new Array();
	public var story_fragment_array : Array<Bool> = new Array();
	
	private var trace_string : String;	
	
	public function new(gs : GameState, laneArray : Array<Float>, r_height : Float)
	{	
		//LoadCollectableData('assets/collectable_groups/collectable_groups.json', 1);

		lanes = laneArray;
		row_height = r_height;
		group_i = 0;
		game_state = gs;
		
		rotation_random = new Random(Math.random());
		
		//Set up the story mode fragments here for convenience.
		
		if (gs.is_story_mode)
		{
			var pct_step = 0.075;
			var current_pct = 0.1;
			for (i in 0...10)
			{
				story_fragment_spawn_pct.push(current_pct);
				story_fragment_array.push(false);
				
				current_pct += pct_step;
			}
		}
		trace(story_fragment_array.length);
		
		super({
			scene : game_state.scene
		});
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (group_templates.length < 1)
		{
			trace("No Collectable Templates Loaded");
			return;
		}
		
		if (GameState.player_sprite == null)
		{
			trace("No Player found!");
			return;
		}
		
		//Wait for the first group to be created.
		if (existing_groups.length > 0)
		{	
			//Create - Using Rows.
			var screen_bottom_row = game_state.get_bottom_y();
			var screen_top_row = game_state.get_max_tile();
			
			var top_y_index = existing_groups[existing_groups.length - 1].y_index + existing_groups[existing_groups.length - 1].GetNumRows();
			var bottom_y_index = existing_groups[0].y_index + existing_groups[existing_groups.length - 1].GetNumRows();
			
			var new_trace = "Vals -1:" + screen_bottom_row +" -2:" + screen_top_row +" -3:" + top_y_index +" -4:" + bottom_y_index;
			if (new_trace != trace_string)
			{
				trace_string = new_trace;
			}
			
			if (bottom_y_index < screen_bottom_row)
			{
				trace(trace_string);
				DestoryCollectableGroup(existing_groups[0]);
			}
			
			if (top_y_index < screen_top_row + min_rows)
			{
				trace(trace_string);
				SpawnCollectableGroup(top_y_index + rows_between_groups);
			}
		}
	}
	
	public function CreateFirstGroup()
	{
		SpawnCollectableGroup(initial_blank_rows);
	}
	
	private function  SpawnCollectableGroup(y_index : Int)
	{
		var selected_data : CollectableGroupData;
		
		//For story mode, we want to spawn one of 10 special groups when the player reaches set levels.
		if (game_state.is_story_mode)
		{
			var level_percent = game_state.get_percent_through_level();
			if (level_percent > story_fragment_spawn_pct[story_coll_index])
			{
				trace("Story Mode Reached : " + level_percent);
				story_coll_index++;
				selected_data = SelectNamedGroup("story_" + story_coll_index);
			}
			else
			{
				selected_data = SelectWeightedRandomData();
			}
		}
		else
		{
			selected_data = SelectWeightedRandomData();
		}
		
		if (selected_data != null)
		{
			var new_group = new CollectableGroup(scene, "Group_" + group_i, selected_data, y_index, this);
			
			group_i++;
			existing_groups.push(new_group);
		}
	}
	
	private function DestoryCollectableGroup(group : CollectableGroup)
	{
		existing_groups.remove(group);
		group.RemoveCollectables();
	}
	
	public function LoadCollectableData(group_name : String, seed : Float)
	{
		var resource = Luxe.resources.json(group_name);
		var array : Array<Dynamic> = resource.asset.json.groups;
		
		collectable_spawn_random = new Random(seed);
		
		group_templates = new Array();
		
		for (i in 0...array.length)
		{
			var n = array[i];
			var new_template = new CollectableGroupData(n.name, n.weighting, n.elements);
			group_templates.push(new_template);
			trace("Loaded: " + n);
		}
		
		trace(group_templates.length + " group templates loaded.");
	}
	
	private function SelectWeightedRandomData() : CollectableGroupData
	{
		var total_weighting : Int = 0;
		var selected_value : Int;
		
		for (group in group_templates)
		{
			total_weighting += group.weighting;
		}
		
		if (total_weighting > 0)
		{
			selected_value = collectable_spawn_random.int(1, total_weighting);
			
			for (group in group_templates)
			{
				//trace(group.name + " : weighting= " + group.weighting + " selectedval= " + selected_value);
				if (selected_value <= group.weighting)
					return group;

				selected_value -= group.weighting;
			}
		}
		
		return null;
	}
	
	private function SelectNamedGroup(name : String) : CollectableGroupData
	{
		for (i in group_templates)
		{
			//trace(i.name);
			if (name == i.name)
				return i;
		}
		
		return null;
	}
}

class CollectableGroupData
{
	public var name : String;
	public var weighting : Int;
	public var elements : Array<String> = new Array();
	
	public function new(n : String, w : Int, e: Array<String>)
	{
		name = n;
		weighting = w;
		elements = e;
	}
}

class CollectableGroup
{
	public var name : String;
	public var data : CollectableGroupData;
	public var collectables : Array<Collectable> = new Array();
	public var y_index : Int;
		
	private var c_manager : CollectableManager;
	public function new(scene : Scene, n : String, d : CollectableGroupData, y_ind : Int, p : CollectableManager)
	{
		data = d;
		c_manager = p;
		name = n;
		y_index = y_ind;
		SpawnCollectables(scene);
		
		trace("Created new collectabale group. Data:" + data.name + " Rows:" + GetNumRows() + " index: " + y_index + ". Player_pos:" + GameState.player_sprite.pos);
	}
	
	public function SpawnCollectables(scene : Scene)
	{
		for (y in 0 ... GetNumRows())
		{
			for (x in 0 ... (c_manager.lanes.length - 2))
			{
				//Invert y so we go from bottom to top.
				var i : Int = GetArrayPos(x, GetNumRows() - 1 - y);
				//HACK - iterate lanes by one as 0 is the gutter.
				var pos : Vector = new Vector(
					c_manager.lanes[x+1], 
					GetYPos() + ( (-y * c_manager.row_height) + (c_manager.row_height / 2) + y ) //Adding half a row height offset. Adding y to make it spaced by one.
				);
				
				//0 = An empty space!
				if (data.elements[i] != "0")
				{	
					collectables.push(SelectAndCreateCollectable(
						data.elements[i], 
						scene, 
						data.name + "_" + i + "_" + pos,
						pos
					));
				}
			}
		}
	}
	
	public function RemoveCollectables()
	{
		collectables = collectables.filter(function(c:Collectable) { return !c.destroyed; });
		for (c in collectables)
		{
			c.destroy();
		}
		trace("Destroyed collectable group. Data:" + data.name + " Rows:" + GetNumRows() + " index: " + y_index);
	}
	
	private function SelectAndCreateCollectable(type : String, scene : Scene, name : String, pos : Vector) : Collectable
	{
		var newColl : Collectable;
		//Pick the collectable from the passed in data.
		switch (type) 
		{
			case "c":
				newColl = new Collectable_Coin(c_manager, name, pos);
			case "l":
				newColl = new Collectable_Letter(c_manager, name, pos);
			case "s":
				newColl = new Collectable_Spike(c_manager, name, pos);
			case "f":
				newColl = new Collectable_Fragment(c_manager, name, pos, c_manager.story_coll_index);
			case "h" :
				newColl = new Collectable_Heart(c_manager, name, pos);
			default:
				newColl = new Collectable_Coin(c_manager, name, pos);
		}
		
		return newColl;
	}
	
	private function GetArrayPos(x : Int, y : Int) : Int
	{
		return x + (y * (c_manager.lanes.length - 2));
	}
	
	private function GetYPos()
	{
		return -y_index * c_manager.row_height;
	}
	
	public function GetNumRows()
	{
		//Divide the array by the number of lanes.
		return Math.ceil(data.elements.length / (c_manager.lanes.length - 2));
	}
}
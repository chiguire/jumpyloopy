package entities;
import entities.CollectableManager.CollectableGroup;
import gamestates.GameState;
import luxe.Debug;
import luxe.Entity;
import luxe.Scene;
import luxe.Vector;
import luxe.debug.TraceDebugView;

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
	
	private var group_i = 0;
	private var game_state : GameState;
	
	private var trace_string : String;
	
	//Hacky implementation of fragments.
	public var fragment_array : Array<Int> = [0, 0, 0, 0, 0];	
	
	public function new(gs : GameState, laneArray : Array<Float>, r_height : Float)
	{	
		LoadCollectableData();
		
		lanes = laneArray;
		row_height = r_height;
		group_i = 0;
		game_state = gs;
		super();
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
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
		var selected_data = SelectWeightedRandomData();
		var new_group = new CollectableGroup(scene, "Group_" + group_i, selected_data, y_index, this);
		
		group_i++;
		existing_groups.push(new_group);
		
	}
	
	private function DestoryCollectableGroup(group : CollectableGroup)
	{
		existing_groups.remove(group);
		group.RemoveCollectables();
	}
	
	private function LoadCollectableData()
	{
		var resource = Luxe.resources.json('assets/collectable_groups/collectable_groups.json');
		var array : Array<Dynamic> = resource.asset.json.groups;
		
		group_templates = new Array();
		
		for (n in array)
		{
			var new_template = new CollectableGroupData(n.name, n.weighting, n.elements);
			group_templates.push(new_template);
			trace(n);
		}
		
		trace(group_templates.length + " group templates loaded.");
	}
	
	private function SelectWeightedRandomData() : CollectableGroupData
	{
		var total_weighting : Int = 0;
		var selected_value : Int;
		
		for (i in group_templates)
		{
			total_weighting += i.weighting;
		}
		
		selected_value = Math.ceil(total_weighting * Math.random());
		
		for (i in group_templates)
		{
			trace(i.name + " : weighting= " + i.weighting + " selectedval= " + selected_value);
			if (selected_value <= i.weighting)
				return i;

			selected_value -= i.weighting;
		}
		
		return null;
	}
	
	public function CheckFragmentStatus()
	{
		for (i in fragment_array)
		{
			if (i < 1)
				return;
		}
		
		for (i in fragment_array)
		{
			i -= 1;
		}
		
		Luxe.events.fire("add_multiplier", {val:1});
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
					GetYPos() + ( -y * c_manager.row_height) + (c_manager.row_height / 2) //Adding half a row height offset.
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
			case "f1":
				newColl = new Collectable_Fragment(c_manager, name, pos, 1);
			case "f2":
				newColl = new Collectable_Fragment(c_manager, name, pos, 2);
			case "f3":
				newColl = new Collectable_Fragment(c_manager, name, pos, 3);
			case "f4":
				newColl = new Collectable_Fragment(c_manager, name, pos, 4);
			case "f5":
				newColl = new Collectable_Fragment(c_manager, name, pos, 5);
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
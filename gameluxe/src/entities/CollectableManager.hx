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
	public var unload_group_rows: Int = 5;
	public var rows_between_groups : Int = 1;
	public var initial_blank_rows : Int = 1;
	public var row_height : Float;
	public var lanes : Array<Float> = new Array();
	
	public var group_templates : Array<CollectableGroupData> = new Array();
	public var existing_groups : Array<CollectableGroup> = new Array();

	public function new(laneArray : Array<Float>, r_height : Float)
	{	
		LoadCollectableData();
		
		lanes = laneArray;
		row_height = r_height;
		super();
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		var group : CollectableGroup;	
		var group_y : Float;		
		var distance : Float;
		var test_dist : Float;
		
		if (GameState.player_sprite == null)
		{
			trace("No Player found!");
			return;
		}
		
		//Wait for the first group to be created.
		if (existing_groups.length > 0)
		{	
			//CREATE
			//Get the top of the last element in the array and add its height. check if that - player_y is lower than our min rows.
			group = existing_groups[existing_groups.length - 1];
			group_y = group.y_pos - (group.GetNumRows() * row_height);		
			distance = Math.abs(group_y - GameState.player_sprite.pos.y);
			test_dist = (min_rows * row_height);
			if (distance < test_dist)
			{
				trace("Distance: " + distance + " is < than " + test_dist + "Adding new");
				SpawnCollectableGroup(group_y + (rows_between_groups * row_height));
			}
			
			//DESTROY
			group = existing_groups[0];
			group_y = group.y_pos - (group.GetNumRows() * row_height);		
			distance = Math.abs(GameState.player_sprite.pos.y - group_y);
			test_dist = (unload_group_rows * row_height);
			if (group_y > GameState.player_sprite.pos.y && distance > test_dist)
			{
				trace("Distance: " + distance + " is > than " + test_dist + "Removing");
				DestoryCollectableGroup(existing_groups.pop());
			}
		}
		
		
	}
	
	public function CreateFirstGroup(game_start_y : Float)
	{
		SpawnCollectableGroup(game_start_y - (initial_blank_rows * row_height));
	}
	
	private function  SpawnCollectableGroup(y_pos : Float)
	{
		//for now we load at random.
		var selection = Math.floor(group_templates.length * Math.random());
		var selected_data = group_templates[selection];
		var new_group = new CollectableGroup(scene, selected_data, y_pos, this);

		existing_groups.push(new_group);
		
	}
	
	private function DestoryCollectableGroup(group : CollectableGroup)
	{
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
}

class CollectableGroupData
{
	public var name : String;
	public var weighting : Float;
	public var elements : Array<String> = new Array();
	
	public function new(n : String, w : Float, e: Array<String>)
	{
		name = n;
		weighting = w;
		elements = e;
	}
}

class CollectableGroup
{
	public var y_pos : Float;
	public var data : CollectableGroupData;
	public var collectables : Array<Collectable> = new Array();
		
	private var parent : CollectableManager;
	public function new(scene : Scene, d : CollectableGroupData, y_height : Float, p : CollectableManager)
	{
		data = d;
		y_pos = y_height;
		parent = p;
		
		SpawnCollectables(scene);
		
		trace("Created new collectabale group. Data:" + data.name + " Rows:" + GetNumRows() + " pos: " + y_pos + ". Player_pos:" + GameState.player_sprite.pos);
	}
	
	public function SpawnCollectables(scene : Scene)
	{
		for (y in 0 ... GetNumRows())
		{
			for (x in 0 ... (parent.lanes.length - 2))
			{
				var i : Int = GetArrayPos(x, y);
				//HACK - iterate lanes by one as 0 is the gutter.
				var pos : Vector = new Vector(
					parent.lanes[x+1], 
					y_pos - (y * parent.row_height)
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
		trace("Destroyed collectable group. Data:" + data.name + " Rows:" + GetNumRows() + " pos: " + y_pos);
	}
	
	private function SelectAndCreateCollectable(type : String, scene : Scene, name : String, pos : Vector) : Collectable
	{
		var newColl : Collectable;
		//Pick the collectable from the passed in data.
		switch (type) 
		{
			case "c":
				newColl = new Collectable_Coin(scene, name, pos);
			default:
				newColl = new Collectable_Coin(scene, name, pos);
		}
		
		return newColl;
	}
	
	private function GetArrayPos(x : Int, y : Int) : Int
	{
		return x + (y * (parent.lanes.length - 2));
	}
	
	public function GetNumRows()
	{
		//Divide the array by the number of lanes.
		return Math.ceil(data.elements.length / (parent.lanes.length - 2));
	}
}
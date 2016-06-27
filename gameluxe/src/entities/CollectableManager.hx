package entities;
import analysis.DFT;
import luxe.Entity;

/**
 * ...
 * @author sm
 */
class CollectableManager extends Entity
{

	public function new() 
	{
		var resource = Luxe.resources.json('assets/collectable_groups/collectable_groups.json');
		var array : Array<Dynamic> = resource.asset.json.groups;
		for (n in array)
		{
			trace(n);
		}
		
		super();
	}

}

class CollectableGroup
{
	public var weighting : Float;
	public var elements : Array<Int> = new Array();
	
	public function new(w : Float, e: Array<Int>)
	{
		weighting = w;
		elements = e;
	}
}
package data;

/**
 * ...
 * @author Aik
 */
class BackgroundGroup
{
	public var name : String;
	public var cost : Int;
	public var tex_path : String;
	public var textures : Array<String>;
	public var distances : Array<Float>;
	public var unlockables : Array<String>;
	public var loop : Bool;

	public function new() 
	{
		textures = new Array<String>();
		distances = new Array<Float>();
	}
	
	public function load_group( data:Dynamic )
	{
		//trace(data.textures);
		name = data.name;
		cost = data.cost;
		tex_path = data.tex_path;
		for ( i in 0...data.textures.length )
		{
			textures.push(data.textures[i]);
			distances.push(data.distances[i]);
		}
		
		if (data.unlockables != null)
		{
			unlockables = new Array<String>();
			
			for ( i in 0...data.unlockables.length )
			{
				unlockables.push(data.unlockables[i]);
			}
		}
		//trace(unlockables);
		
		if (data.loop != null) loop = data.loop;
	}
}
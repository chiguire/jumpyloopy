package data;

/**
 * ...
 * @author Aik
 */
class BackgroundGroup
{
	public var name : String;
	public var textures : Array<String>;
	public var distances : Array<Float>;
	public var unlockables : Array<String>;

	public function new() 
	{
		textures = new Array<String>();
		distances = new Array<Float>();
	}
	
	public function load_group( data:Dynamic )
	{
		//trace(data.textures);
		name = data.name;
		
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
		
		trace(unlockables);
	}
}
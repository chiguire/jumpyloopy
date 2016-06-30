package data;

/**
 * ...
 * @author Aik
 */
class BackgroundGroup
{
	//public var tile_textures : Array<String>;
	//public var trans_textures : Array<String>;
	
	public var textures : Array<String>;
	public var distances : Array<Float>;

	public function new() 
	{
		//tile_textures = new Array<String>();
		//trans_textures = new Array<String>();
		textures = new Array<String>();
		distances = new Array<Float>();
	}
	
	public function load_group( data:Dynamic )
	{
		trace(data.textures);
		for ( i in 0...data.textures.length )
		{
			textures.push(data.textures[i]);
			distances.push(data.distances[i]);
		}
	}
}
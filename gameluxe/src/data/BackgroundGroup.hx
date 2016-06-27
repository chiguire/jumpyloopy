package data;

/**
 * ...
 * @author Aik
 */
class BackgroundGroup
{
	public var tile_textures : Array<String>;
	public var trans_textures : Array<String>;
	public var distances : Array<Float>;

	public function new() 
	{
		tile_textures = new Array<String>();
		trans_textures = new Array<String>();
		distances = new Array<Float>();
	}
	
	public function load_group( data:Dynamic )
	{
		trace(data.tile_textures);
		for ( i in 0...data.tile_textures.length )
		{
			tile_textures.push(data.tile_textures[i]);
			trans_textures.push(data.trans_textures[i]);
			distances.push(data.distances[i]);
		}
	}
}
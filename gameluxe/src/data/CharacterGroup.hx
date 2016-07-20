package data;

/**
 * ...
 * @author ...
 */
class CharacterGroup
{
	public var name : String;
	public var game_texture : String;
	public var cost : Int;
	public var tex_path : String;
	
	public function new(n : String, tp : String, t : String, c: Int)
	{
		name = n;
		tex_path = tp;
		game_texture = t;
		cost = c;
	}
}
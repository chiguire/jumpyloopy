package entities;
import entities.Avatar;
import gamestates.GameState;
import luxe.Scene;
import luxe.Vector;

/**
 * ...
 * @author sm
 */
class Collectable_Fragment extends Collectable
{
	public var fragment_index : Int;
	
	public function new(c_manager : CollectableManager, name : String, position : Vector, index : Int) 
	{
		fragment_index = index;
		super(c_manager, name, getSpriteForID(), '', new Vector(40, 40), position);
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		//Add to our parent's fragment array.
		c_manager.fragment_array[fragment_index - 1] += 1;
		
		//If we've filled out an array doing this then we can add multipliers! Yay!
		c_manager.CheckFragmentStatus();
		
		super.onCollisionEnter(player);
	}
	
	function getSpriteForID() : String
	{
		switch(fragment_index)
		{
			case 1: return "assets/image/collectables/letter_chunk_01.png";
			case 2: return "assets/image/collectables/letter_chunk_02.png";
			case 3: return "assets/image/collectables/letter_chunk_03.png";
			case 4: return "assets/image/collectables/letter_chunk_04.png";
			case 5: return "assets/image/collectables/letter_chunk_05.png";
			default: return "";
		}
	}
}
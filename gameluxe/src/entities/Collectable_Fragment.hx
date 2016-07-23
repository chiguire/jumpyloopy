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
		super(c_manager, name, getSpriteForID(), '', getSpriteSizeForID(), position, new Vector(40,40));
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		//Add to our parent's fragment array.
		c_manager.story_fragment_array[fragment_index - 1] = true;
		trace("Fragment Collected : " + fragment_index);
		super.onCollisionEnter(player);
		
		if (Main.achievement_manager.is_fragment_unlocked(fragment_index - 1) == false)
		{
			Luxe.events.fire("activate_report_text", {s : "Unlocked! Story Fragment"});
		}
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
			default: return "assets/image/collectables/letter_chunk_01.png";
		}
	}
	
	function getSpriteSizeForID() : Vector
	{
		switch(fragment_index)
		{
			case 1: return new Vector(40, 50);
			case 2: return new Vector(50, 35);
			case 3: return new Vector(40, 35);
			case 4: return new Vector(45, 43);
			case 5: return new Vector(85, 30);
			default: return new Vector(40, 50);
		}
	}
}
package entities;
import entities.Avatar;
import luxe.Scene;
import luxe.Vector;

/**
 * ...
 * @author sm
 */
class Collectable_Letter extends Collectable
{
	public function new(c_manager : CollectableManager, name : String, position : Vector) 
	{
		super(c_manager, name, "assets/image/collectables/letter_collectible.png", '', new Vector(50, 50), position);
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		var val = 50;
		
		Luxe.events.fire("add_score", {val:val});
		
		super.onCollisionEnter(player);
	}
}
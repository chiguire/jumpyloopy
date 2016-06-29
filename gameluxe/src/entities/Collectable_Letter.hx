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
	public function new(scene : Scene, name : String, position : Vector) 
	{
		super(scene, name, 'assets/image/collectables/collectable_letter.png', '', new Vector(50, 50), position);
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		Luxe.events.fire("add_score", {val:50});
		
		super.onCollisionEnter(player);
	}
}
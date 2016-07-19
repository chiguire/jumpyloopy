package entities;
import entities.Avatar;
import gamestates.GameState;
import luxe.Scene;
import luxe.Vector;

/**
 * ...
 * @author sm
 */
class Collectable_Heart extends Collectable
{
	public function new(c_manager : CollectableManager, name : String, position : Vector )
	{
		super(c_manager, name, "assets/image/collectables/letter_collectible.png", '', new Vector(40, 40), position);
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		Luxe.events.fire("player_heal", {});
		
		super.onCollisionEnter(player);
	}
}
package entities;
import entities.Avatar;
import gamestates.GameState;
import luxe.Scene;
import luxe.Vector;

/**
 * ...
 * @author sm
 */
class Collectable_Coin extends Collectable
{
	public function new(c_manager : CollectableManager, name : String, position : Vector) 
	{
		super(c_manager, name, 'assets/image/coin-sprite-animation-sprite-sheet.png', 'assets/animation/animation_coin.json', new Vector(40, 40), position, new Vector(40, 40));
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		Luxe.events.fire("add_score", {val:25});
		
		super.onCollisionEnter(player);
	}
}
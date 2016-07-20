package entities;
import entities.Avatar;
import luxe.Scene;
import luxe.Vector;

/**
 * ...
 * @author sm
 */
class Collectable_Spike extends Collectable
{
	public function new(c_manager: CollectableManager, name : String, position : Vector) 
	{
		super(c_manager, name, "assets/image/collectables/paper_hole_01.png", '', new Vector(100, 100), position, new Vector(50,50));
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		// A bit of a game breaker, commenting out for now [Aik]
		//Luxe.events.fire("kill_player", {msg:"Massive SPIKES!"});
		
		var val = -50;
		
		Luxe.events.fire("add_score", {val:val});
		
		Luxe.events.fire("player_damage", {});
		
		super.onCollisionEnter(player);
	}
}
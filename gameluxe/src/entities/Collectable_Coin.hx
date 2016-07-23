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
	var type : CollectableType;
	
	public function new(c_manager : CollectableManager, name : String, position : Vector, coin_type : CollectableType) 
	{
		type = coin_type;
		super(c_manager, name, GetCoinSprite(), 'assets/animation/animation_coin.json', new Vector(40, 40), position, new Vector(40, 40));
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		Luxe.events.fire("add_score", {val:GetCoinValue()});
		Main.achievement_manager.unlockables.current_coins += GetCoinValue();
		
		super.onCollisionEnter(player);
	}
	
	function GetCoinSprite()
	{
		switch(type) {
			case CollectableType.GOLD: return 'assets/image/coin_sprite_gold.png';
			case CollectableType.SILVER: return 'assets/image/coin_sprite_silver.png';
			case CollectableType.BRONZE: return 'assets/image/coin_sprite_bronze.png';
		}
	}
	
	function GetCoinValue()
	{
		switch(type) {
			case CollectableType.GOLD: return 5;
			case CollectableType.SILVER: return 3;
			case CollectableType.BRONZE: return 1;
		}
	}
}
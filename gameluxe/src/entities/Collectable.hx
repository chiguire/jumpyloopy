package entities;
import entities.Avatar;
import entities.CollisionShape;
import gamestates.GameState;
import luxe.Scene;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;
import luxe.options.SpriteOptions;
import luxe.tween.Actuate;

/**
 * ...
 * @author ...
 */
class Collectable extends Sprite
{
	public var anim : SpriteAnimation;
	public var collisionShape : CollisionShape;
	
	var c_manager : CollectableManager;
	
	// event id, stored so we can unlisten
	var event_id : Array<String>;
	
	public function new(parent_manager : CollectableManager, name : String, texture_name : String, animation_name : String, size : Vector, position : Vector) 
	{
		c_manager = parent_manager;
		//Sort out the sprite.
		var options : SpriteOptions =
		{
			name: name,
			texture: Luxe.resources.texture(texture_name),
			pos: position,
			size: size,
			scene: c_manager.scene
		};
		
		super(options);
		
		if (animation_name != "")
		{
			//Animations
			anim = new SpriteAnimation({name: "CollectableAnimation"+name });
			add(anim);
			
			var anim_object = Luxe.resources.json(animation_name);
			anim.add_from_json_object(anim_object.asset.json);
			
			anim.animation = "idle";
			anim.play();
		}
		
		//Define collision for the collectable.
		collisionShape = new CollisionShape(this, false);
		GameState.player_sprite.collision.RegisterCollisionEntity(collisionShape);
		
		event_id = new Array<String>();
		event_id.push(events.listen("onCollisionEnter", onCollisionEnter));
		
		destroyed = false;
	}
	
	private function onCollisionEnter(player : Avatar):Void 
	{
		DestroyCollectable();
	}
	
	public function DestroyCollectable()
	{
		GameState.player_sprite.collision.DeregisterCollisionEntity(collisionShape);
		
		destroy();
	}
	
	private function buildPolygon(size : Vector):Array<Vector>
	{
		var a = new Array();
		var halfX = size.x / 2;
		var halfY = size.y / 2;
		
		a.push( new Vector(halfX, halfY));
		a.push( new Vector(halfX, -halfY));
		a.push( new Vector(-halfX, -halfY));
		a.push( new Vector(-halfX, halfY));
		
		return a;
	}
	
	override public function ondestroy() 
	{
		// events
		for (i in 0...event_id.length)
		{
			var res = Luxe.events.unlisten(event_id[i]);
		}
		
		collisionShape.set_destroyed();
		super.ondestroy();
	}
}
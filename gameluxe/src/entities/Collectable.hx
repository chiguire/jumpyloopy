package entities;
import entities.Avatar;
import entities.CollisionShape;
import gamestates.GameState;
import luxe.Scene;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;
import luxe.options.SpriteOptions;

/**
 * ...
 * @author ...
 */
class Collectable extends Sprite
{
	public var anim : SpriteAnimation;
	public var collisionShape : CollisionShape;
	
	public function new(scene : Scene, name : String, texture_name : String, animation_name : String, size : Vector, position : Vector) 
	{
		//Sort out the sprite.
		var options : SpriteOptions =
		{
			name: name,
			texture: Luxe.resources.texture(texture_name),
			pos: position,
			size: size,
			scene: scene
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
		
		events.listen("onCollisionEnter", onCollisionEnter);
		
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
	
	override public function ondestroy() {
		collisionShape.set_destroyed();
		super.ondestroy();
	}
}
package components;
import haxe.ds.Vector;
import luxe.Component;
import luxe.Sprite;
import luxe.collision.Collision;
import luxe.collision.shapes.Polygon;

/**
 * ...
 * @author ...
 */
class CollisionComponent extends Component
{
	public var collisionPoly : Polygon;
	
	private var parentSprite : Sprite;
	private var colliding : Bool;
	
	public function new(sprite : Sprite) 
	{
		//Define collision for the collectable.
		collisionPoly = new Polygon(sprite.pos.x, sprite.pos.y, buildPolygon(sprite.size));
		
		//We use our parent sprite to set the position of the collision each frame.
		parentSprite = sprite;
	}
	
	override public function onfixedupdate(rate:Float) 
	{
		super.onfixedupdate(rate);

		//Keep our collision matching the sprite!
		collisionPoly.position = parentSprite.pos;
	}
	
	public function onCollisionEnter(othert : CollisionComponent):Void 
	{
		//Do stuff here!
		trace("Collided with this thing.")
	}
	
	public function onCollisionExit(othert : CollisionComponent):Void 
	{
		//Do stuff here!
		trace("Collided with this thing.")
	}
	
	public function onCollisionStay(othert : CollisionComponent):Void 
	{
		//Do stuff here!
		trace("Collided with this thing.")
	}
	
	private function buildPolygon(size : Vector):Array
	{
		var a = new Array();
		var halfX = size.x / 2;
		var halfY = size.y / 2;
		
		a.push( halfX, halfY);
		a.push( halfX, -halfY);
		a.push( -halfX, -halfY);
		a.push( -halfX, halfY);
		
		return a;
	}
	
	public function isColliding():Bool
	{
		return colliding;
	}
	
}
package entities;
import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.collision.Collision;
import luxe.collision.shapes.Polygon;

/**
 * ...
 * @author ...
 */
class CollisionShape extends Polygon
{
	public var collisionPoly : Polygon;
	
	private var parentSprite : Sprite;
	private var colliding : Bool;
	
	public function new(sprite : Sprite) 
	{
		var polyArray : Array<Vector> = buildPolygon(sprite.size);
		super(sprite.pos.x, sprite.pos.y, polyArray);
		
		//We use our parent sprite to set the position of the collision each frame.
		parentSprite = sprite;
	}
	
	public function Update(rate:Float) 
	{
		//Keep our collision matching the sprite!
		collisionPoly.position = parentSprite.pos;
	}
	
	public function onCollisionEnter(othert : CollisionShape):Void 
	{
		//Do stuff here!
		trace("Collided with this thing.");
	}
	
	public function onCollisionExit(othert : CollisionShape):Void 
	{
		//Do stuff here!
		trace("Collided with this thing.");
	}
	
	public function onCollisionStay(othert : CollisionShape):Void 
	{
		//Do stuff here!
		trace("Collided with this thing.");
	}
	
	private function buildPolygon(size : Vector):Array<Vector>
	{
		var a : Array<Vector> = new Array();
		var halfX = size.x / 2;
		var halfY = size.y / 2;
		
		a.push( new Vector(halfX, halfY));
		a.push( new Vector(halfX, -halfY));
		a.push( new Vector(-halfX, -halfY));
		a.push( new Vector(-halfX, halfY));
		
		return a;
	}
	
	public function isColliding():Bool
	{
		return colliding;
	}
	
}
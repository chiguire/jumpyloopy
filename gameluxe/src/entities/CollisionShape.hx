package entities;
import luxe.Color;
import luxe.Component;
import luxe.Draw;
import luxe.Sprite;
import luxe.Vector;
import luxe.collision.Collision;
import luxe.collision.shapes.Polygon;
import luxe.options.DrawOptions.DrawPolygonOptions;

/**
 * ...
 * @author ...
 */
class CollisionShape extends Polygon
{
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
		this.position = parentSprite.pos.clone();
		
		var verts = get_transformedVertices();
		Luxe.draw.poly({
			immediate: true,
			solid : false,
			depth : -1,
			colors : [
				new Color().rgb(0xff4b03),
                new Color().rgb(0xff4b03),
                new Color().rgb(0xff4b03),
                new Color().rgb(0x191919)
				],
			points : [
				verts[0],
				verts[1],
				verts[2],
				verts[3]
			]
		});
	}
	
	public function onCollisionEnter(other : CollisionShape):Void 
	{
		parentSprite.events.fire('onCollisionEnter');
		colliding = true;
	}
	
	public function onCollisionExit(other : CollisionShape):Void 
	{
		parentSprite.events.fire('onCollisionExit');
		colliding = false;
	}
	
	public function onCollisionStay(other : CollisionShape):Void 
	{
		parentSprite.events.fire('onCollisionStay');
		colliding = true;
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
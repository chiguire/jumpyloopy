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
	private var updatePosition : Bool;
	private var parentSprite : Sprite;
	private var colliding : Bool;
	public var destroyed (default, null): Bool;
	public var offsetX : Float;
	public var offsetY : Float;
	
	public function new(sprite : Sprite, size: Vector, updatePos : Bool, offset_x : Float = 0, offset_y : Float = 0, 
		pct_x : Float = 1, pct_y : Float = 1) 
	{
		offsetX = offset_x;
		offsetY = offset_y;
		
		var polyArray : Array<Vector> = buildPolygon(size, pct_x, pct_y);
		super(sprite.pos.x + offsetX, sprite.pos.y + offsetY, polyArray);
		
		//We use our parent sprite to set the position of the collision each frame.
		parentSprite = sprite;
		destroyed = false;
		updatePosition = updatePos;
	}
	
	public function Update(rate:Float) 
	{
		if (updatePosition)
		{
			set_x(parentSprite.pos.x + offsetX);
			set_y(parentSprite.pos.y + offsetY);
		}
		
		//Uncomment to see collision positions.
#if debug
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
#end
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
	
	private function buildPolygon(size : Vector, pctX : Float, pctY : Float):Array<Vector>
	{
		var a : Array<Vector> = new Array();
		var halfX = (size.x / 2) * pctX;
		var halfY = (size.y / 2) * pctY;
		
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
	
	public function set_destroyed()
	{
		destroyed = true;
	}
}
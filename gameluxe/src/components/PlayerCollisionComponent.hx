package components;
import analysis.DFT;
import entities.CollisionShape;
import luxe.Component;
import luxe.Sprite;
import luxe.collision.Collision;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;

/**
 * ...
 * @author ...
 */
class PlayerCollisionComponent extends Component
{
	private var initialised : Bool = false;
	private var player_collision : CollisionShape;
	private var collision_shapes : Array<CollisionShape> = new Array();
	
	public function SetupPlayerCollision(playerSprite : Sprite) 
	{
		trace("Setting up player collision.");
		player_collision = new CollisionShape(playerSprite);
		initialised = true;
	}
	
	override public function update(dt:Float) 
	{
		if (!initialised)
		{
			return;
		}
		
		var collided_shapes = new Array();
		
		//Update all our shapes.
		player_collision.Update(dt);
		collided_shapes = collided_shapes.filter(function(o:CollisionShape) { return !o.destroyed; });
		for (s in collision_shapes)
		{
			if (!s.destroyed)
			{
				s.Update(dt);
			}
		}
		
		//Check for player collisions.
		collided_shapes = CollisionShapeWithShapes(player_collision, collision_shapes);
		//trace("num shapes collided = " + collided_shapes.length);
		collided_shapes = collided_shapes.filter(function(o:CollisionShape) { return !o.destroyed; });
		for (cs in collided_shapes)
		{
			if (!cs.destroyed)
			{
				cs.onCollisionEnter(player_collision);
			}
		}
		
		super.update(dt);
	}
	
	public function RegisterCollisionEntity(obj : CollisionShape)
	{
		//trace("Registering collision entity.");
		collision_shapes.push(obj);
	}
	
	public function DeregisterCollisionEntity(obj : CollisionShape)
	{
		//trace("Deregistering collision entity.");
		collision_shapes.remove(obj);
	}
	
	    /** Test a single shape against multiple other shapes.
            When no collision is found, this function returns an empty array, this function will never return null.
            Returns a list of `ShapeCollision` information for each collision found. */
    private function CollisionShapeWithShapes( shape1:CollisionShape, shapes:Array<CollisionShape> ) : Array<CollisionShape> {

        var results = [];

            //:todo: pair wise
        for(other_shape in shapes) {

            var result = Collision.shapeWithShape(shape1, other_shape);
            if(result != null) {
                results.push(other_shape);
            }

        } //for all shapes passed in

        return results;

    } //testShapes
}
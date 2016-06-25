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
	private var playerCollision : CollisionShape;
	private var collision_shapes : Array<CollisionShape> = new Array();
	
	public function SetupPlayerCollision(playerSprite : Sprite) 
	{
		trace("Setting up player collision.");
		playerCollision = new CollisionShape(playerSprite);
	}
	
	override public function onfixedupdate(rate:Float) 
	{
		var collided_shapes = new Array();
		super.onfixedupdate(rate);
		
		//Update all our shapes.
		for (s in collision_shapes)
		{
			s.Update(rate);
		}
		
		//Check for player collisions.
		collided_shapes = CollisionShapeWithShapes(playerCollision, collision_shapes);
	}
	
	public function RegisterCollisionEntity(obj : CollisionShape)
	{
		trace("Registering collision entity.");
		collision_shapes.push(obj);
	}
	
	public function DeregisterCollisionEntity(obj : CollisionShape)
	{
		trace("Deregistering collision entity.");
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
package components;
import luxe.Component;
import luxe.collision.Collision;
import luxe.collision.shapes.Polygon;

/**
 * ...
 * @author ...
 */
class CollisionManagerComponent extends Component
{
	private var playerCollision : CollisionComponent;
	private var collisionEntities :Array<CollisionComponent> = new Array();
	
	public function new(playerSprite : Sprite) 
	{
		playerCollision = new CollisionComponent(playerSprite);
	}
	
	override public function onfixedupdate(rate:Float) 
	{
		super.onfixedupdate(rate);
		
		var openList :Array<CollisionComponent> = new Array();
		var closedList :Array<CollisionComponent> = new Array();
		openList = collisionEntities.copy();

		//Loop through all our collision entities and test if they're colliding, if they are we send messages to them.
		// We're going to assume we only collide with one thing per update loop.
		for (poly : CollisionComponent in collisionEntities)
		{
			//~If we have not collisions
			
			//If we have a collision.
			if (Collision.shapeWithShape(playerCollision, poly) != null)
			{
				if (poly.isColliding())
				{
					poly.onCollisionStay(playerCollision);
				}
				else
				{
					poly.onCollisionEnter(playerCollision);
				}
				
				return;
			}
		}
		
	}
	
	public function RegisterCollisionEntity(obj : CollisionComponent)
	{
		collisionEntities.push(obj);
	}
	
	public function DeregisterCollisionEntity(obj : CollisionComponent)
	{
		collisionEntities.remove(obj);
	}
}
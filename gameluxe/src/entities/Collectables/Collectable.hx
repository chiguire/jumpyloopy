package entities.Collectables;
import entities.Avatar;
import luxe.Scene;
import luxe.Sprite;
import luxe.Vector;

/**
 * ...
 * @author ...
 */
class Collectable extends Sprite
{
	public var collisionPoly : Polygon;
	
	public function new(scene : Scene, name : String, texture_name : String, sprite_name : String, size : Vector, position : Vector) 
	{
		//Sort out the sprite.
		var options : SpriteOptions =
		{
			name: name,
			texture: Luxe.resources.texture(texture_name),
			uv: game_info.spritesheet_elements[sprite_name],
			pos: position,
			size: size,
			scene: scene
		};
		
		super(options);
		
		//Define collision for the collectable.
		collisionPoly = new Polygon(position.x, position.y, buildPolygon(size));
	}
	
	private function onPlayerCollision(player : Avatar):Void {
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
}
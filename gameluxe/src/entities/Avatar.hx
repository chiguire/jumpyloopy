package entities;

import luxe.Vector;
import luxe.options.SpriteOptions;
import luxe.Sprite;

/**
 * ...
 * @author WK
 */
class Avatar extends Sprite
{
	public function new(/*options:SpriteOptions*/) 
	{
		var options:SpriteOptions = {
			name: "avatar",
			pos: Luxe.screen.mid,
			size: new Vector(24, 48),
		};
		
		super(options);
	}
	
	override function update(dt:Float)
	{
		if ( Luxe.input.inputpressed("jump") )
		{
			pos.y -= 5;
		}
	}
}
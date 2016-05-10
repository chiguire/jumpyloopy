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
	public function new(options:SpriteOptions) 
	{		
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
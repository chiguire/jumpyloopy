package entities;

import luxe.Component;
import luxe.Input.MouseEvent;
import luxe.Vector;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.tween.easing.Bounce;

/**
 * ...
 * @author WK
 */
class TrajectoryMovement extends Component
{
	override function init()
	{
		
	}
	
	override function update(dt:Float)
	{
		
	}
	
	override function onmousedown(event:MouseEvent)
	{
		Actuate.tween(pos, 1.0, {x:event.pos.x});
		Actuate.tween(pos, 1.0, {y:event.pos.y}).ease(luxe.tween.easing.Bounce.easeIn);
		trace(event.pos);
	}
}
 
class Avatar extends Sprite
{
	public function new(options:SpriteOptions) 
	{		
		super(options);
		
		add( new TrajectoryMovement( { name:"TrajectoryMovement" } ));
	}
	
	override function update(dt:Float)
	{
		
	}
}
package entities;

import luxe.Component;
import luxe.Input.MouseEvent;
import luxe.Timer;
import luxe.Vector;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.tween.MotionPath;
import luxe.tween.easing.Bounce;

/**
 * ...
 * @author WK
 */
class TrajectoryMovement extends Component
{
	var timer:snow.api.Timer;
	
	var nextPos:Vector;
	override function init()
	{
		timer = Luxe.timer.schedule(2.5, doJump, true);
		
		nextPos = pos;
	}
	
	override function update(dt:Float)
	{
		
	}
	
	override function onmousedown(event:MouseEvent)
	{
		//Actuate.tween(pos, 1.0, {x:event.pos.x});
		//Actuate.tween(pos, 1.0, {y:event.pos.y}).ease(luxe.tween.easing.Bounce.easeIn);
		trace(event.pos);
		
		nextPos = event.pos.clone();
	}
	
	function doJump()
	{
		if (!nextPos.equals(pos))
		{
			Actuate.tween(pos, 1.25, {x:nextPos.x});
			Actuate.tween(pos, 1.25, {y:nextPos.y}).ease(luxe.tween.easing.Bounce.easeIn);
		}
		else
		{
			var motionPath = new MotionPath();
			motionPath.line(pos.x, pos.y);
			motionPath.line(pos.x, pos.y - 50);
			motionPath.line(pos.x, pos.y);
		
			Actuate.motionPath(pos, 1.25, {x:motionPath.x, y:motionPath.y}).ease(luxe.tween.easing.Bounce.easeIn);
		}
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
package entities;

import entities.Level.LevelInitEvent;
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
	public var nextPos = new Vector();
	
	override function init()
	{
		
	}
	
	override function update(dt:Float)
	{
		
	}
	
	override function onmousedown(event:MouseEvent)
	{
		//Actuate.tween(pos, 1.0, {x:event.pos.x});
		//Actuate.tween(pos, 1.0, {y:event.pos.y}).ease(luxe.tween.easing.Bounce.easeIn);
		//trace(event.pos);
		
		//nextPos = event.pos.clone();
	}
	
	public function doJump()
	{
		if (!nextPos.equals(pos))
		{
			Actuate.tween(pos, 1.25, {x:nextPos.x});
			Actuate.tween(pos, 1.25, { y:nextPos.y } ).ease(luxe.tween.easing.Bounce.easeIn);
		}
		else
		{
			var motionPath = new MotionPath();
			motionPath.line(pos.x, pos.y);
			motionPath.line(pos.x, pos.y - cast(entity, Avatar).jump_height * 1.25);
			motionPath.line(pos.x, pos.y);
		
			Actuate.motionPath(pos, 1.25, {x:motionPath.x, y:motionPath.y}).ease(luxe.tween.easing.Bounce.easeIn);
		}
	}
}
 
class Avatar extends Sprite
{
	/// components
	var trajectory_movement : TrajectoryMovement;
	
	public var jump_height : Float;
	
	public function new(options:SpriteOptions) 
	{		
		super(options);
		
		// components
		trajectory_movement = new TrajectoryMovement( { name:"TrajectoryMovement" } );
		add(trajectory_movement);
		
		// events
		Luxe.events.listen("Level.Init", OnLevelInit );
		Luxe.events.listen("player_move_event", OnPlayerMove );
	}
	
	override function update(dt:Float)
	{
		
	}
	
	function OnLevelInit( e:LevelInitEvent )
	{
		pos.set_xy(e.pos.x, e.pos.y - size.y / 2);
		trajectory_movement.nextPos.set_xy(pos.x, pos.y);
		jump_height = e.beat_height;
	}
	
	function OnPlayerMove(e)
	{
		trajectory_movement.nextPos.y -= jump_height;
		trajectory_movement.doJump();
	}
}
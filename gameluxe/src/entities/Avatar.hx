package entities;

import components.GameCameraComponent;
import entities.BeatManager.BeatEvent;
import entities.Level.LevelStartEvent;
import luxe.Component;
import luxe.Input.MouseEvent;
import luxe.Timer;
import luxe.Vector;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.tween.MotionPath;
import luxe.tween.easing.Cubic;

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
	
	public function doJump(e:BeatEvent)
	{
		var T = e.interval;
		
		if (!nextPos.equals(pos))
		{
			Actuate.tween(pos, T, {x:nextPos.x});
			Actuate.tween(pos, T, { y:nextPos.y } ).ease(luxe.tween.easing.Cubic.easeIn);		}
		else
		{
			var motionPath = new MotionPath();
			motionPath.line(pos.x, pos.y);
			motionPath.line(pos.x, pos.y - cast(entity, Avatar).jump_height * 1.25);
			motionPath.line(pos.x, pos.y);
		
			Actuate.motionPath(pos, T, {x:motionPath.x, y:motionPath.y}).ease(luxe.tween.easing.Cubic.easeIn);		}
	}
}
 
class Avatar extends Sprite
{
	/// components
	public var trajectory_movement : TrajectoryMovement;
	var gamecamera : GameCameraComponent;
	
	public var starting_x : Float;
	public var jump_height : Float;
	public var current_lane : Int;
	
	public function new(starting_x : Float, options:SpriteOptions) 
	{		
		super(options);
		
		this.starting_x = starting_x;
		
		// components
		gamecamera = new GameCameraComponent({name: "GameCamera"});
		trajectory_movement = new TrajectoryMovement( { name:"TrajectoryMovement" } );
		add(gamecamera);
		add(trajectory_movement);
		
		// events
		Luxe.events.listen("Level.Start", OnLevelStart );
		Luxe.events.listen("player_move_event", OnPlayerMove );
	}
	
	override function update(dt:Float)
	{
		
	}
	
	function OnLevelStart( e:LevelStartEvent )
	{
		visible = true;
		pos.set_xy(starting_x /*e.pos.x*/, e.pos.y - size.y / 2);
		trajectory_movement.nextPos.set_xy(pos.x, pos.y);
		jump_height = e.beat_height;
	}
	
	function OnPlayerMove( e:BeatEvent )
	{
		//trajectory_movement.nextPos.y -= jump_height;
		trajectory_movement.doJump(e);
	}
}
package entities;

import components.GameCameraComponent;
import entities.BeatManager.BeatEvent;
import entities.Level.LevelStartEvent;
import luxe.Component;
import luxe.Input.MouseEvent;
import luxe.Timer;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;
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
	public var height : Float;
	
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
		
		var dst_y = nextPos.y - height / 2; // pos.y - cast(entity, Avatar).jump_height;
		var apex_y = pos.y - cast(entity, Avatar).jump_height * 1.25;
		
		if (!nextPos.equals(pos))
		{
			var motionPath = new MotionPath();
			var half_x = pos.x + (nextPos.x - pos.x) / 2.0;
			var full_x = pos.x + (nextPos.x - pos.x);
			
			motionPath.bezier(half_x, apex_y, pos.x, apex_y);
			motionPath.bezier(full_x, dst_y, full_x, apex_y);
			Actuate.motionPath(pos, 0.6, {x:motionPath.x, y:motionPath.y}).ease(luxe.tween.easing.Cubic.easeInOut);

		}
		else
		{
			var motionPath = new MotionPath();
			motionPath.bezier(pos.x, apex_y, pos.x, apex_y);
			motionPath.bezier(pos.x, pos.y, pos.x, apex_y);
			Actuate.motionPath(pos, 0.6, {x:motionPath.x, y:motionPath.y}).ease(luxe.tween.easing.Cubic.easeInOut);
		}
	}
}
 
class Avatar extends Sprite
{
	/// components
	public var trajectory_movement : TrajectoryMovement;
	public var anim : SpriteAnimation;
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
		anim = new SpriteAnimation({name: "PlayerSpriteAnimation" });
		
		add(gamecamera);
		add(trajectory_movement);
		add(anim);
		
		var anim_object = Luxe.resources.json('assets/animation/animation_jumper.json');
		anim.add_from_json_object(anim_object.asset.json);
		
		anim.animation = "idle";
		anim.play();
		
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
		gamecamera.set_x(starting_x);
		pos.set_xy(starting_x /*e.pos.x*/, e.pos.y - size.y / 2);
		trajectory_movement.nextPos.set_xy(pos.x, pos.y);
		trajectory_movement.height = size.y / 2.0;
		jump_height = e.beat_height;
		
		//Set default animation
		//anim.animation = 'idle';
		//anim.play();
	}
	
	function OnPlayerMove( e:BeatEvent )
	{
		//trajectory_movement.nextPos.y -= jump_height;
		trajectory_movement.doJump(e);
	}
}
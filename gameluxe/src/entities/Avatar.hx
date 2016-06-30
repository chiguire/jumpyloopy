package entities;

import components.GameCameraComponent;
import components.PlayerCollisionComponent;
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
import luxe.tween.actuators.GenericActuator.IGenericActuator;
import luxe.tween.easing.Cubic;

/**
 * ...
 * @author WK
 */
class TrajectoryMovement extends Component
{
	public var nextPos = new Vector();
	public var oldNextPos = new Vector();
	
	var tweening : Bool = false;

	private var parentAvatar : Avatar;	public var height : Float;	
	override function init()
	{
		parentAvatar = cast(entity, Avatar);
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
		var T = Math.max(e.interval, 0.4);
		
		if (tweening)
		{
			tweening = false;
			pos.set_xy(oldNextPos.x, oldNextPos.y);
		}
		
		var dst_y = nextPos.y;// - height / 2; // pos.y - parentAvatar.jump_height;
		var apex_y = pos.y - parentAvatar.jump_height * 1.25;		
		if (!nextPos.equals(pos))
		{
			var motionPath = new MotionPath();
			var half_x = pos.x + (nextPos.x - pos.x) / 2.0;
			var full_x = pos.x + (nextPos.x - pos.x);
			
			motionPath.bezier(half_x, apex_y, pos.x, apex_y);
			motionPath.bezier(full_x, dst_y, full_x, apex_y);
			Actuate.motionPath(pos, T, {x:motionPath.x, y:motionPath.y})
				.onComplete(function(){parentAvatar.OnPlayerLand(); tweening = false; })
				.ease(luxe.tween.easing.Cubic.easeInOut);
		}
		else
		{
			var motionPath = new MotionPath();
			motionPath.bezier(pos.x, apex_y, pos.x, apex_y);
			motionPath.bezier(pos.x, pos.y, pos.x, apex_y);
			Actuate.motionPath(pos, T, {x:motionPath.x, y:motionPath.y})
				.onComplete(function(){ parentAvatar.OnPlayerLand(); tweening = false; })
				.ease(luxe.tween.easing.Cubic.easeInOut);		
		}
		
		oldNextPos = nextPos;
		tweening = true;
	}
	
}
 
class Avatar extends Sprite
{
	/// components
	public var trajectory_movement : TrajectoryMovement;
	public var anim : SpriteAnimation;
	public var collision : PlayerCollisionComponent;
	var gamecamera : GameCameraComponent;
	
	public var starting_x : Float;
	public var jump_height : Float;
	public var current_lane : Int;
	
	private var debug_animations = false;
	
	// event id, stored so we can unlisten
	var event_id : Array<String>;
	
	public function new(starting_x : Float, options:SpriteOptions) 
	{		
		super(options);
		
		this.starting_x = starting_x;
		transform.origin = new Vector(size.x / 2, size.y);
		
		// components
		gamecamera = new GameCameraComponent({name: "GameCamera"});
		trajectory_movement = new TrajectoryMovement( { name:"TrajectoryMovement" } );
		anim = new SpriteAnimation({name: "PlayerSpriteAnimation" });
		collision = new PlayerCollisionComponent({name: "PlayerCollision"});
		
		add(gamecamera);
		add(trajectory_movement);
		add(anim);
		add(collision);
		
		var anim_object = Luxe.resources.json('assets/animation/animation_jumper.json');
		anim.add_from_json_object(anim_object.asset.json);

		// events
		event_id = new Array<String>();
		event_id.push(Luxe.events.listen("Level.Start", OnLevelStart ));
		event_id.push(Luxe.events.listen("player_move_event", OnPlayerMove ));
		
		//trace(event_id);
	}
	
	override public function ondestroy() 
	{
		// events
		for (i in 0...event_id.length)
		{
			var res = Luxe.events.unlisten(event_id[i]);
		}
		
		super.ondestroy();
	}
	
	override function update(dt:Float)
	{
		
	}
	
	public function respawn( p:Vector)
	{
		visible = true;
		
		pos.set_xy(p.x, p.y);
		trajectory_movement.nextPos.set_xy(pos.x, pos.y);
		
		Actuate.stop(pos);
	}
	
	function OnLevelStart( e:LevelStartEvent )
	{		
		visible = true;
		gamecamera.set_x(starting_x);
		
		pos.set_xy(starting_x /*e.pos.x*/, e.pos.y);
		trajectory_movement.nextPos.set_xy(pos.x, pos.y);
		trajectory_movement.height = size.y / 2.0;
		jump_height = e.beat_height;
		
		InitialiseAnimations();
		
		//Register player collision.
		collision.SetupPlayerCollision(this);
	}
	
	function OnPlayerMove( e:BeatEvent )
	{
		//trajectory_movement.nextPos.y -= jump_height;
		trajectory_movement.doJump(e);
		
		if(debug_animations)
			trace("player_jump");
			
		anim.animation = 'jump';
		anim.play();
	}
	
	public function OnPlayerLand()
	{
		if(debug_animations)
			trace("player_landed");
		
		anim.animation = 'land';
		anim.play();
	}
	
	function InitialiseAnimations()
	{
		//Set default animation
		anim.animation = 'idle';
		anim.play();
		
		//Setup events.
		events.listen('landed', function(e){
			if(debug_animations)
				trace("player_finished landing");
			
            anim.animation = 'idle';
			anim.play();
        });
		
		events.listen('landed_left', function(e){
			if(debug_animations)
				trace("player_finished landing left");
			
            anim.animation = 'idle_left';
			anim.play();
        });
		
		events.listen('landed_right', function(e){
			if(debug_animations)
				trace("player_finished landing right");
				
            anim.animation = 'idle_right';
			anim.play();
        });
	}
}
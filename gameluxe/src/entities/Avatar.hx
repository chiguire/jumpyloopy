package entities;

import components.GameCameraComponent;
import components.PlayerCollisionComponent;
import components.VisualFlashingComponent;
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
		var T = Math.min(e.interval, 0.4);
		
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
	public var gamecamera : GameCameraComponent;
	var visual_flashing_comp: VisualFlashingComponent;
	
	public var starting_x : Float;
	public var starting_y  = 0.0;
	public var jump_height : Float;
	public var current_lane : Int;
	
	private var debug_animations = false;
	
	// some player stat during the game
	public var travelled_distance  (default, null) = 0.0;
	public var num_lives = 3;
	
	// respawn (start with true, so the gameplay logic won't effect the Avatar until OnLevelStart)
	public var respawning (default, null) = true;
	
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
		visual_flashing_comp = new VisualFlashingComponent({name: "VisualFlashingComponent"});
		
		add(gamecamera);
		add(trajectory_movement);
		add(anim);
		add(collision);
		add(visual_flashing_comp);
		
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
		travelled_distance = -(pos.y - starting_y);
	}
	
	public function respawn_begin( p:Vector)
	{
		respawning = true;
		visible = true;
		
		// start tweening from bottom of the scene
		pos.set_xy(p.x, p.y + Main.global_info.ref_window_size_y);
		trajectory_movement.nextPos.set_xy(pos.x, pos.y);
		
		// stop the current tweening, and start a new one
		Actuate.stop(pos);
		Actuate.tween(pos, 3.0, { y:p.y }).onComplete(respawn_end);
		
		// start flashing
		visual_flashing_comp.activate();
	}
	
	public function respawn_end()
	{
		respawning = false;
		trajectory_movement.nextPos.set_xy(pos.x, pos.y);
		
		// stop flashing
		visual_flashing_comp.deactivate();
		
		Luxe.events.fire("player_respawn_end");
	}
	
	function OnLevelStart( e:LevelStartEvent )
	{
		travelled_distance = 0;
		
		// reset respawn flag, so it will trigger the gameplay
		respawning = false;
		
		visible = true;
		gamecamera.set_x(starting_x);
		
		starting_y = e.pos.y;
		pos.set_xy(starting_x /*e.pos.x*/, starting_y);
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
package entities;

import components.VisualFlashingComponent;
import data.GameInfo;
import luxe.Camera;
import luxe.Scene;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

/**
 * ...
 * @author aik
 */
typedef PlatformOptions = 
{
	> SpriteOptions,
	var game_info : GameInfo;
	var n : Int;
	var type : PlatformType;
}

typedef PlatformTimeoutEvent = 
{
	var pos : Vector;
}
 
class Platform extends Sprite
{
	static public var max_size (default, null) : Vector = new Vector(164, 123);

	public var anim : SpriteAnimation;
	
	public var type (default,null): PlatformType;
	public var touches : Float = 0.0;
	public var initialTouches = 0.0; // Change this to increase or reduce the duration of the platforms. Set to -1 for eternal platforms.
	public var eternal : Bool = false;
	public var stepped_on_by_player : Bool = false;
	
	var visual_flashing_comp : VisualFlashingComponent;
	
	public function new(options : PlatformOptions) 
	{
		options.name = 'Platform'+options.n;
		
		super(options);
		
		initialTouches = Main.global_info.platform_lifetime;
		
		visual_flashing_comp = new VisualFlashingComponent();
		add(visual_flashing_comp);
		
		set_type(options.type, true);
		//scale.set_xy(0.5, 0.5);
	}
	
	public function set_type(t:PlatformType, skip_animation_to_end:Bool)
	{
		visual_flashing_comp.deactivate();
		visible = (t != NONE);
		touches = initialTouches;
		
		var tex = Luxe.resources.texture(select_platform_texture(t));
		if (tex != null)
		{
			texture = tex;
			size.set_xy(max_size.x, max_size.y);
		}
		
		if (anim != null)
		{
			remove("PlatformAnimation" + name);
		}
		
		var animation_name = select_platform_animation(t);
		if (animation_name != "")
		{
			//Animations
			anim = new SpriteAnimation({name: "PlatformAnimation"+name });
			add(anim);
			
			var anim_object = Luxe.resources.json(animation_name);
			anim.add_from_json_object(anim_object.asset.json);
			
			anim.animation = if (skip_animation_to_end) "skip" else "play";
			anim.play();
		}
		return type = t;
	}
	
	private static function select_platform_texture(t : PlatformType) : String
	{
		return switch (t)
		{
			case LEFT:      'assets/image/platforms/platform_left01_anim.png';
			case RIGHT:     'assets/image/platforms/platform_right01_anim.png';
			case CENTER(n): 'assets/image/platforms/platform_straight0${n}_anim.png';
			default:        '';
		};
	}
	
	private static function select_platform_animation(t : PlatformType) : String
	{
		return switch (t)
		{
			case LEFT:      'assets/animation/animation_platform_6.json';
			case RIGHT:     'assets/animation/animation_platform_6.json';
			case CENTER(1): 'assets/animation/animation_platform_6.json';
			case CENTER(2): 'assets/animation/animation_platform_5.json';
			default:        '';
		};
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (type == NONE || eternal || touches == -1)
		{
			return;
		}
		
		touches -= dt;
		
		if (touches <= 1.5 && !visual_flashing_comp.is_activated())
		{
			trace(touches);
			visual_flashing_comp.activate();
		}
		
		if (touches <= 0)
		{
			//trace(type);
			//Luxe.events.fire("platform_time_out", {pos: pos});
			type = NONE;
			stepped_on_by_player = false;
		}
	}
	
	public static function get_random_center_type()
	{
		return Std.int(Math.random() * 2) + 1;
	}
}
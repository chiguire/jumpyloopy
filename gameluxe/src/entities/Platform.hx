package entities;

import data.GameInfo;
import luxe.Camera;
import luxe.Scene;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.Vector;

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
 
class Platform extends Sprite
{
	public var type (default, set) : PlatformType;
	
	public function new(options : PlatformOptions) 
	{
		options.name = 'Platform'+options.n;
		/*
		var options : SpriteOptions =
		{
			name: 'Platform${n}',
			//texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			//uv: game_info.spritesheet_elements['ground_grass_small.png'],
			pos: Luxe.screen.mid,
			//size: new Vector(game_info.spritesheet_elements['ground_grass_small.png'].w, game_info.spritesheet_elements['ground_grass_small.png'].h),
			
			scene: scene,
		};
		*/
		//trace(options.name);
		super(options);
		
		this.type = options.type;
		//scale.set_xy(0.5, 0.5);
	}
	
	public function set_type(t:PlatformType)
	{
		/*
		rotation_z = switch (t)
		{
			case NONE: 0;
			case LEFT: -45;
			case RIGHT: 45;
			case CENTER: 0;
		};
		*/
		visible = (t != NONE);
		
		var tex = Luxe.resources.texture(select_platform_texture(t));
		if (tex != null)
		{
			texture = tex;
			size.y = texture.height;
		}
		return type = t;
	}
	
	private function select_platform_texture(t : PlatformType) : String
	{
		if (t == PlatformType.LEFT)
			return 'assets/image/platforms/platform_left01.png';
		else if (t == PlatformType.RIGHT)
			return 'assets/image/platforms/platform_right01.png';
		else if (Math.random() > 0.5)
			return 'assets/image/platforms/platform_straight01.png';

		return 'assets/image/platforms/platform_straight02.png';
	}
}
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
class Platform extends Sprite
{
	public var type (default, set) : PlatformType;
	
	public function new(scene:Scene, game_info:GameInfo, n : Int, type:PlatformType) 
	{
		var options : SpriteOptions =
		{
			name: 'Platform${n}',
			texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			uv: game_info.spritesheet_elements['ground_grass_small.png'],
			pos: Luxe.screen.mid,
			size: new Vector(game_info.spritesheet_elements['ground_grass_small.png'].w, game_info.spritesheet_elements['ground_grass_small.png'].h),
			scene: scene,
		};
		
		super(options);
		
		this.type = type;
		scale.set_xy(0.5, 0.5);
	}
	
	public function set_type(t:PlatformType)
	{
		rotation_z = switch (t)
		{
			case NONE: 0;
			case LEFT: -45;
			case RIGHT: 45;
			case CENTER: 0;
		};
		visible = (t != NONE);
		return type = t;
	}
	
	private function select_platform_texture(t : PlatformType) : String
	{
		if (t == PlatformType.LEFT)
			return 'assets/image/platforms/platform_left01.png';
		if (t == PlatformType.RIGHT)
			return 'assets/image/platforms/platform_right01.png';
		if (Math.random() > 0.5)
			return 'assets/image/platforms/platform_straight01.png';

		return 'assets/image/platforms/platform_straight02.png';
	}
}
package components;

import luxe.Component;
import luxe.options.ComponentOptions;

/**
 * ...
 * @author ...
 */
class GameCameraComponent extends Component
{
	private var _x : Float;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
		_x = 0;
	}
	
	public function set_x(value:Float)
	{
		_x = value;
	}
	
	override function update(dt:Float)
	{
		var offsetx = Luxe.screen.size.x / 2;
		var offsety = Luxe.screen.size.y / 2;
		Luxe.camera.pos.set_xy( _x - offsetx, pos.y - offsety );
	}
}
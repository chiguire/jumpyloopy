package components;

import luxe.Component;
import luxe.options.ComponentOptions;

/**
 * ...
 * @author ...
 */
class GameCameraComponent extends Component
{
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
		
	}
	
	override function update(dt:Float)
	{
		var offsetx = Luxe.screen.size.x / 2;
		var offsety = Luxe.screen.size.y / 2;
		Luxe.camera.pos.set_xy( pos.x - offsetx, pos.y - offsety );
	}
}
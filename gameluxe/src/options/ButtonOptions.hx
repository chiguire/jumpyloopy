package options;

import luxe.Color;
import luxe.options.EntityOptions;
import luxe.options.GeometryOptions.RectangleGeometryOptions;
import luxe.options.TextOptions;

/**
 * ...
 * @author 
 */
typedef ButtonOptions =
{
	> EntityOptions,
	var text : TextOptions;
	@:optional var color_out : Color;
	@:optional var color_over : Color;
	@:optional var color_click : Color;
	@:optional var background_out : Color;
	@:optional var background_over : Color;
	@:optional var background_click : Color;
};
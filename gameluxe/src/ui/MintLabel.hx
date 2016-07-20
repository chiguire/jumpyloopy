package ui;

import luxe.Color;
import mint.Label;
import mint.Label.LabelOptions;

/**
 * ...
 * @author Aik
 */
typedef MintLabelOptions =
{
	> LabelOptions,
	
	color : Color,
}
 
class MintLabel extends Label
{
	public function new(_options:MintLabelOptions) 
	{
		super(_options);
		
		var renderer = cast(renderer, mint.render.luxe.Label);
		var font = Luxe.resources.font(Main.rise_font_id);
		renderer.text.font = font;
		renderer.text.color = _options.color;
	}
}
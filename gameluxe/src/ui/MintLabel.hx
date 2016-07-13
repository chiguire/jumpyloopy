package ui;

import mint.Label;
import mint.Label.LabelOptions;

/**
 * ...
 * @author Aik
 */
typedef MintLabelOptions =
{
	> LabelOptions,
}
 
class MintLabel extends Label
{
	public function new(_options:MintLabelOptions) 
	{
		super(_options);
		
		var renderer = cast(label.renderer, mint.render.luxe.Label);
		var font = Luxe.resources.font(Main.rise_font_id);
		renderer.text.font = font;
	}
}
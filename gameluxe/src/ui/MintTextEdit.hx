package ui;

import luxe.Color;
import mint.TextEdit;
import mint.TextEdit.TextEditOptions;

/**
 * ...
 * @author Aik
 */
class MintTextEdit extends TextEdit
{
	public function new(_options:TextEditOptions) 
	{
		var color = new Color(0.5, 0.5, 0.5, 0.25);
		var color_cursor = new Color(0.5, 0.5, 0.5, 0.5);
		_options.options = {color: color, color_hover: color, color_cursor: color_cursor };
		
		super(_options);
		
		var txtedit_renderer = cast(renderer, mint.render.luxe.TextEdit);
		
		var label_renderer = cast(label.renderer, mint.render.luxe.Label);
		var font = Luxe.resources.font(Main.rise_font_id);
		label_renderer.text.font = font;
		label_renderer.text.color = Main.global_info.text_color;
	}
	
}
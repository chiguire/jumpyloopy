package ui;

import mint.Panel;
import mint.Label;
import mint.render.luxe.Panel;
import mint.types.Types.TextAlign;

/**
 * ...
 * @author Aik
 */
typedef MintLabelPanelOption =
{
	var x : Float;
	var y : Float;
	var w : Float;
	var h : Float;
	var text : String;
	@:optional var text_size : Int;
}
 
class MintLabelPanel
{
	var panel : mint.Panel;
	var label : Label;
	
	public function new( options: MintLabelPanelOption) 
	{
		// description panel
		panel = new mint.Panel({
			parent: Main.canvas,
			name: 'panel',
			mouse_input: false,
			x: options.x, y: options.y, w: options.w, h: options.h,
		});
		cast(panel.renderer, mint.render.luxe.Panel).color.a = 0.5;
		
		label = new Label({
			parent: panel, name: 'label',
			mouse_input:false, x:0, y:0, w:panel.w, h:panel.h, text_size: options.text_size,
			align: TextAlign.center, align_vertical: TextAlign.center,
			text: options.text
		});
	}
	
	public function set_text( text: String )
	{
		label.text = text;
	}
}
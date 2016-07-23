package ui;

import luxe.Color;
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
	@:optional var text_color : Color;
	@:optional var panel_visible : Bool;
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
		var panel_renderer = cast(panel.renderer, mint.render.luxe.Panel);
		panel_renderer.color.a = 0.5;
		if (options.panel_visible != null) panel_renderer.visual.visible = options.panel_visible;
		
		label = new Label({
			parent: panel, name: 'label',
			mouse_input:false, x:0, y:0, w:panel.w, h:panel.h, text_size: options.text_size != null ? options.text_size : 24,
			align: TextAlign.center, align_vertical: TextAlign.center,
			text: options.text
		});
		
		var renderer = cast(label.renderer, mint.render.luxe.Label);
		var font = Luxe.resources.font(Main.rise_font_id);
		
		renderer.text.font = font;
		if (options.text_color != null) renderer.text.color = options.text_color;  
	}
	
	public function set_text( text: String )
	{
		label.text = text;
	}
	
	public function set_visible( v: Bool )
	{
		var renderer = cast(label.renderer, mint.render.luxe.Label);
		renderer.text.visible = v;
		
		var panel_renderer = cast(panel.renderer, mint.render.luxe.Panel);
		panel_renderer.visual.visible = v;
	}
	
	public function set_alpha( a : Float )
	{
		var renderer = cast(label.renderer, mint.render.luxe.Label);
		renderer.text.color.a = a;
		
		var panel_renderer = cast(panel.renderer, mint.render.luxe.Panel);
		panel_renderer.visual.color.a = Math.min(a, 0.5);
	}
}
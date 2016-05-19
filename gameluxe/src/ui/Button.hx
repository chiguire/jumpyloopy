package ui;

import haxe.PosInfos;
import luxe.Color;
import luxe.Scene;
import luxe.Vector;
import luxe.Entity;
import luxe.Input.MouseEvent;
import luxe.Rectangle;
import luxe.Text;
import luxe.options.EntityOptions;
import options.ButtonOptions;
import phoenix.geometry.RectangleGeometry;

typedef ButtonEvent = {
	button : Button,
};

/**
 * ...
 * @author 
 */
class Button extends Entity
{	
	private var button_opts : ButtonOptions;

	private var rectangle : RectangleGeometry;
	
	private var text : Text;
	
	private var _rect : Rectangle;
	
	private static var default_color_out        : Color = new Color(210/255.0, 210/255.0, 210/255.0);
	private static var default_color_over       : Color = new Color(230/255.0, 230/255.0, 255/255.0);
	private static var default_color_click      : Color = new Color(255/255.0, 255/255.0, 255/255.0);
	private static var default_background_out   : Color = new Color(127/255.0, 127/255.0, 127/255.0);
	private static var default_background_over  : Color = new Color(150/255.0, 150/255.0, 255/255.0);
	private static var default_background_click : Color = new Color(180/255.0, 180/255.0, 180/255.0);
	
	private static var button_border : Float = 10;
	private static var button_border_x : Float = button_border;
	private static var button_border_y : Float = button_border;
	private static var over_scale : Float = 0.05;
	
	private var clicked_inside : Bool;
	
	public function new(_options:ButtonOptions) 
	{
		super(_options);
		
		button_opts = _options;
		
		text = new Text({
			pos: new Vector(_options.pos.x + button_border_x, _options.pos.y + button_border_y),
			depth: 0,
			text: _options.text.text,
			color: if (_options.color_out != null) _options.color_out else default_color_out,
			font: _options.text.font,
			point_size: _options.text.point_size,
			line_spacing: _options.text.line_spacing,
			letter_spacing: _options.text.letter_spacing,
			scene: _options.scene,
		});
		
		_rect = new Rectangle(_options.pos.x, _options.pos.y, button_border_x*2 + text.geom.text_width, button_border_y*2 + text.geom.text_height);
		trace(_rect);
		
		rectangle = Luxe.draw.rectangle({
			depth: -1,
			rect: _rect,
			color: if (_options.background_out != null) _options.background_over else default_background_out,
			scene: _options.scene,
		});
		
		clicked_inside = false;
	}
	
	public override function ondestroy()
	{
		_scene.empty();
		_scene.destroy();
		button_opts = null;
		text = null;
		rectangle = null;
		_rect = null;
		_scene = null;
		
		super.ondestroy();
	}
	
	public override function onmousemove(event:MouseEvent)
	{
		if (!clicked_inside)
		{
			if (_rect.point_inside(event.pos))
			{
				rectangle.color = if (button_opts.background_over != null) button_opts.background_over else default_background_over;
				text.geom.color = if (button_opts.color_over != null) button_opts.color_over else default_color_over;
				rectangle.set_xywh(button_opts.pos.x - (over_scale / 2) * (text.geom.text_width + button_border_x * 2), 
								button_opts.pos.y - (over_scale / 2) * (text.geom.text_height + button_border_y * 2), 
								(text.geom.text_width + button_border_x * 2) * (1.0 + over_scale), 
								(text.geom.text_height + button_border_y * 2) * (1.0 + over_scale));
			}
			else
			{
				rectangle.color = if (button_opts.background_out != null) button_opts.background_out else default_background_out;
				text.geom.color = if (button_opts.color_out != null) button_opts.color_out else default_color_out;
				rectangle.set_xywh(button_opts.pos.x, 
								button_opts.pos.y, 
								(text.geom.text_width + button_border_x * 2), 
								(text.geom.text_height + button_border_y * 2));
			}
		}
	}
	
	public override function onmousedown(event:MouseEvent)
	{
		rectangle.set_xywh(button_opts.pos.x, 
						   button_opts.pos.y, 
						   (text.geom.text_width + button_border_x * 2), 
						   (text.geom.text_height + button_border_y * 2));
		if (_rect.point_inside(event.pos))
		{
			rectangle.color = if (button_opts.background_click != null) button_opts.background_click else default_background_click;
			text.geom.color = if (button_opts.color_click != null) button_opts.color_click else default_color_click;
			clicked_inside = true;
		}
		else
		{
			clicked_inside = false;
		}
	}
	
	public override function onmouseup(event:MouseEvent)
	{
		if (_rect.point_inside(event.pos) && clicked_inside)
		{
			events.fire('button.clicked', { button: this }, true);
		}
		
		clicked_inside = false;
	}
	
}
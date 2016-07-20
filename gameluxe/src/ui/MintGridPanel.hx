package ui;
import luxe.Color;
import luxe.Vector;
import mint.Control;
import mint.Window;

/**
 * ...
 * @author ...
 */
class MintGridPanel extends Window
{
	var num_columns : Int;
	var padding : Float;
	
	public var items : Array<Control> = new Array();
	
	public function new(parent : Control, title: String, pos : Vector, width : Float, num_col : Int, pad : Float) 
	{
		super({
            parent: parent,
            name: title,
            title: title,
            options: {
                color:new Color().rgb(0xFFFFFF),
                color_titlebar:new Color().rgb(0x191919),
                label: { color:new Color().rgb(0x06b4fb), text_size : 24 }
            },
            x: pos.x, y: pos.y, w: width, h: padding,
            collapsible: true,
			closable: false,
			moveable: false,
			resizable: false
        });
		
		num_columns = num_col;
		padding = pad;
	}
	
	public function add_item(item : Control)
	{
		var old_w = item.w;
		item.w = get_column_width();
		item.h *= get_column_width() / old_w;
		
		item.x_local = get_column(items.length) * (this.w / num_columns);
		item.x_local += padding;

		item.y_local = get_row(items.length) * item.h;
		item.y_local += title.h + title.y_local;
		item.y_local += padding;
		
		resize();
		
		trace("x: " + item.x_local + ", y: " + item.y_local + ", this.h: " + this.h + ", item.h: " + item.h);
		items.push(item);
	}
		
	private function get_column(i : Int) : Int
	{
		var c : Int = i % num_columns;
		return c;
	}
	
	private function get_row(i : Int) : Int
	{
		var r : Int = Math.floor(i / num_columns);
		return r;
	}
	
	private function get_column_width() : Float
	{
		var padded_w = this.w - (num_columns * padding) - padding;
		return padded_w / num_columns;
	}
	
	private function resize()
	{
		if (items.length > 0)
		{
			var num_rows = get_row(items.length) + 1;
			this.h = (num_rows * items[0].h) + (num_rows * padding) + padding + padding;
		}
	}
}
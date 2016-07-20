package ui;
import luxe.Vector;
import mint.Control;
import mint.Image;
import mint.types.Types.MouseEvent;

/**
 * ...
 * @author ...
 */
class MintImageButton extends Image
{
	public var is_active : Bool = true;
	var callback : Void->Void;
	
	
	public function new(parent : Control, name : String, pos : Vector, size : Vector, image_path : String, ?onclick : Void->Void) 
	{
		super(
		{
			parent: parent, 
			name: name,
			x:pos.x, y:pos.y, 
			w:size.x, h:size.y,
			path: image_path,
			mouse_input: true
		});
		
		callback = onclick;
	}
	
	override public function mouseenter(e:MouseEvent) 
	{
		if (is_active)
		{
			super.mouseenter(e);

			var renderer = cast(renderer, mint.render.luxe.Image);
			var hsl = renderer.visual.color.toColorHSL();
			hsl.l *= 1.5;
			renderer.visual.color.fromColorHSL(hsl);
		}
	}
	
	override public function mouseleave(e:MouseEvent) 
	{
		super.mouseleave(e);
		var renderer = cast(renderer, mint.render.luxe.Image);
		var hsl = renderer.visual.color.toColorHSL();
		hsl.l /= 1.5;
		renderer.visual.color.fromColorHSL(hsl);
	}
	
	override public function mousedown(e:MouseEvent) 
	{
		callback();
		super.mousedown(e);
	}
}
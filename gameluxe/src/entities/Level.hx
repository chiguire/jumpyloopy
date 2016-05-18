package entities;

import haxe.PosInfos;
import luxe.Entity;
import luxe.options.EntityOptions;
import phoenix.geometry.RectangleGeometry;

/**
 * ...
 * @author WK
 */
class Level extends Entity
{
	var lanes : Array<RectangleGeometry>;
	
	public function new(?_options:EntityOptions) 
	{
		super(_options);
		
	}
	
	override public function init() 
	{
		// create lanes geometry
		/*var rect = Luxe.draw.rectangle({
            x : 10, y : 10,
            depth: -2,
            w : Luxe.screen.w - 20,
            h : Luxe.screen.h - 20,
            color : new Color(0.4,0.4,0.4)
        });
		*/
		
	}
	
	override public function update(dt:Float)
	{
		// draw lanes
		
	}
}
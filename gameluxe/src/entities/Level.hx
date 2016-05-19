package entities;

import haxe.PosInfos;
import luxe.Color;
import luxe.Entity;
import luxe.Vector;
import luxe.options.EntityOptions;
import phoenix.geometry.RectangleGeometry;

/**
 * ...
 * @author WK
 */
class Level extends Entity
{
	var lanes : Array<RectangleGeometry>;
	var lanes_width = 64;
	var lanes_height = 8192;
	
	public function new(?_options:EntityOptions) 
	{
		super(_options);
	}
	
	override public function init() 
	{
		lanes = new Array<RectangleGeometry>();
		
		// create lanes geometry
		for (i in 0...5)
		{
			var rect = Luxe.draw.rectangle({
            x : 96 + i*lanes_width, y : Luxe.screen.height - 10 - lanes_height,
            depth: -2,
            w : lanes_width,
            h : lanes_height,
            color : new Color(0.5,0.5,0.5)
			});
			
			lanes.push(rect);
		}
	}
	
	override public function update(dt:Float)
	{
		// draw lanes
		
	}
	
	public function get_player_start_pos():Vector
	{
		var start_lane = Math.ceil(lanes.length * 0.5);
		return new Vector(96 + start_lane * lanes_width, Luxe.screen.height - 10 - lanes_height);
	}
}
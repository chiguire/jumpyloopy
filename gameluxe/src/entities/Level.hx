package entities;

import haxe.PosInfos;
import luxe.Color;
import luxe.Entity;
import luxe.Vector;
import luxe.options.EntityOptions;
import mint.layout.margins.Margins.SizeTarget;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.RectangleGeometry;

/**
 * ...
 * @author WK
 */
typedef LevelInitEvent = 
{
	pos : Vector,
	beat_height : Float
}

 
class Level extends Entity
{
	var lanes : Array<RectangleGeometry>;
	var lanes_width = 64;
	var lanes_height = 8192;
	
	var beat_height = 80;
	var beat_lines : Array<LineGeometry>;
	
	var game_start_pos : Float;
	
	var timer:snow.api.Timer;
	
	public function new(?_options:EntityOptions) 
	{
		super(_options);
	}
	
	override public function init() 
	{
		lanes = new Array<RectangleGeometry>();
		
		game_start_pos = Luxe.screen.height - 10;
		// create lanes geometry
		for (i in 0...5)
		{
			var rect = Luxe.draw.rectangle({
            x : 96 + i*lanes_width, y : game_start_pos - lanes_height,
            depth: -2,
            w : lanes_width,
            h : lanes_height,
            color : new Color(0.5,0.5,0.5)
			});
			
			lanes.push(rect);
		}
		
		beat_lines = new Array<LineGeometry>();
		for (i in 1...Std.int(lanes_height/beat_height))
		{
			var obj = Luxe.draw.line( {
			p0 : new Vector(90, game_start_pos - i * beat_height),
			p1 : new Vector(96 + lanes_width * lanes.length, game_start_pos - i * beat_height),
            color : new Color(0.5,0.75,0.5)
			});
			
			//if (i < 10) trace(game_start_pos + i * beat_height);
			
			beat_lines.push(obj);
		}
		
		var player_startpos = get_player_start_pos();
		Luxe.events.fire("Level.Init", { 
			pos:player_startpos,
			beat_height:beat_height 
		}, false );
		
		// fake beat
		timer = Luxe.timer.schedule(2.5, send_player_move_event, true);
	}
	
	override public function update(dt:Float)
	{
		// draw lanes
		
	}
	
	public function get_player_start_pos():Vector
	{
		var start_lane = Math.floor(lanes.length * 0.5);
		//trace(start_lane);
		return new Vector(96 + start_lane * lanes_width + lanes_width/2, beat_lines[0].p0.y);
	}
	
	public function send_player_move_event()
	{
		Luxe.events.fire("player_move_event");
	}
}
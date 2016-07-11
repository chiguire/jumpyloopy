package entities;

import haxe.PosInfos;
import luxe.Text;
import phoenix.Batcher;
import snow.api.Timer;
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
typedef LevelStartEvent = 
{
	pos : Vector,
	beat_height : Float
}

typedef LevelOptions = 
{
	> EntityOptions,
	var batcher_ui : Batcher;
}
 
class Level extends Entity
{
	//var lanes : Array<RectangleGeometry>;
	//var lanes_width = 64;
	//var lanes_height = 8192;
	//
	
	public var can_put_platforms : Bool = false;
	
	public var beat_height = 150;
	//var beat_lines : Array<LineGeometry>;
	
	//var game_start_pos : Float;
	
	var timer:snow.api.Timer;
	
	/// UI elements
	var batcher_ui : Batcher;
	var countdown_text : Text;
	
	var player_start_pos : Vector;
	
	var game_unpause_ev : String;
	
	public function new(?_options:LevelOptions, player_start_pos : Vector ) 
	{
		super(_options);
		
		this.player_start_pos = player_start_pos;
		
		batcher_ui = _options.batcher_ui;
		can_put_platforms = false;
		
		game_unpause_ev = Luxe.events.listen("game.unpause", on_game_unpause );
	}
	
	override public function ondestroy() 
	{
		Luxe.events.unlisten(game_unpause_ev);
		
		super.ondestroy();
	}
	
	override public function init() 
	{
		//lanes = new Array<RectangleGeometry>();
		
		//game_start_pos = Luxe.screen.height - 10;
		// create lanes geometry
		//for (i in 0...5)
		//{
		//	var rect = Luxe.draw.rectangle({
        //    x : 96 + i*lanes_width, y : game_start_pos - lanes_height,
        //    depth: 10,
        //    w : lanes_width,
        //    h : lanes_height,
        //    color : new Color(0.5,0.5,0.5)
		//	});
		//	
		//	lanes.push(rect);
		//}
		
		//beat_lines = new Array<LineGeometry>();
		//for (i in 1...Std.int(lanes_height/beat_height))
		//{
		//	var obj = Luxe.draw.line( {
		//	depth: 10,
		//	p0 : new Vector(90, game_start_pos - i * beat_height),
		//	p1 : new Vector(96 + lanes_width * lanes.length, game_start_pos - i * beat_height),
        //    color : new Color(0.5,0.75,0.5)
		//	});
		//	
		//	//if (i < 10) trace(game_start_pos + i * beat_height);
		//	
		//	beat_lines.push(obj);
		//}
		
		countdown_text = new Text({
			text: "Rise",
			point_size: 36,
			pos: new Vector(Main.global_info.ref_window_size_x/2, Main.global_info.ref_window_size_y * 0.25 ),
			color: Color.random(),
			batcher: batcher_ui
		});
		countdown_text.visible = false;
		can_put_platforms = false;
	}
	
	override public function update(dt:Float)
	{
		// draw lanes
		
	}
	
	var countdown_timer : Timer;
	var countdown_time = 3;
	var countdown_counter = 0;
	
	public function OnAudioLoad(e)
	{
		countdown_counter = countdown_time;
		countdown_text.visible = true;
		countdown_text.text = Std.string(countdown_counter);
		can_put_platforms = false;
		
		countdown_timer = Luxe.timer.schedule( 1.0, function()
		{
			countdown_counter--;
			countdown_text.text = Std.string(countdown_counter);
			if (countdown_counter == 0)
			{
				countdown_timer.stop();
				//var player_startpos = get_player_start_pos();
				countdown_text.visible = false;
				can_put_platforms = true;
				Luxe.events.fire("Level.Start", {pos:player_start_pos, beat_height:beat_height}, false );
			}
			//trace(countdown_counter);
			
		}, true);
	}
	
	public function on_game_unpause(e)
	{
		countdown_counter = countdown_time;
		countdown_text.visible = true;
		countdown_text.text = Std.string(countdown_counter);
		
		countdown_timer = Luxe.timer.schedule( 1.0, function()
		{
			countdown_counter--;
			countdown_text.text = countdown_counter == 1 ? "Go!" : Std.string(countdown_counter);
			if (countdown_counter == 0)
			{
				countdown_timer.stop();
				//var player_startpos = get_player_start_pos();
				countdown_text.visible = false;
			}
			//trace(countdown_counter);
			
		}, true);
	}
}
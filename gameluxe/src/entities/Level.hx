package entities;

import haxe.PosInfos;
import luxe.Text;
import luxe.tween.Actuate;
import phoenix.Batcher;
import snow.api.Timer;
import luxe.Color;
import luxe.Entity;
import luxe.Vector;
import luxe.options.EntityOptions;
import mint.layout.margins.Margins.SizeTarget;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.RectangleGeometry;
import ui.MintLabelPanel;

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
	
	var report_text : MintLabelPanel;
	var countdown_text : MintLabelPanel;
	
	var player_start_pos : Vector;
	
	// event id, stored so we can unlisten
	var event_id : Array<String>;
	
	public function new(?_options:LevelOptions, player_start_pos : Vector ) 
	{
		super(_options);
		
		this.player_start_pos = player_start_pos;
		
		batcher_ui = _options.batcher_ui;
		can_put_platforms = false;
		
		// events
		event_id = new Array<String>();
		event_id.push(Luxe.events.listen("game.unpause", on_game_unpause ));
		event_id.push(Luxe.events.listen("activate_report_text", on_activate_report_text )); 
	}
	
	override public function ondestroy() 
	{
		//trace("on destroy");
		for (id in event_id)
		{
			var res = Luxe.events.unlisten(id);
			//trace(res);
		}
		
		super.ondestroy();
	}
	
	override public function init() 
	{
		report_text = new MintLabelPanel({
			text: "",
			x: 720 - 250, y: 140, w: 500, h: 50,
			text_size: 36
		});
		report_text.set_visible(false);
		
		countdown_text = new MintLabelPanel({
			text: "",
			x: 720 - 250, y: 200, w: 500, h: 50,
			text_size: 36
		});
		countdown_text.set_visible(false);
		can_put_platforms = false;
	}
	
	override public function update(dt:Float)
	{
		// draw lanes
		
	}
	
	var countdown_timer : Timer;
	var countdown_time = 3;
	var countdown_counter = 0;
	
	public function activate_countdown_text( ?fire_start_event : Bool )
	{
		countdown_counter = countdown_time;
		countdown_text.set_visible(true);
		countdown_text.set_text( Std.string(countdown_counter) );
		can_put_platforms = false;
		
		countdown_timer = Luxe.timer.schedule( 1.0, function()
		{
			countdown_counter--;
			countdown_text.set_text( countdown_counter == 1 ? "Go!" : Std.string(countdown_counter) );
			if (countdown_counter == 0)
			{
				countdown_timer.stop();
				countdown_text.set_visible(false);
				
				can_put_platforms = true;
				
				// fire start event
				if (fire_start_event)
				{
					Luxe.events.fire("Level.Start", {pos:player_start_pos, beat_height:beat_height}, false );
				}
			}
			
		}, true);
	}
	
	public function OnAudioLoad(e)
	{
		activate_countdown_text(true);
	}
	
	public function on_game_unpause(e)
	{
		activate_countdown_text();
	}
	
	public function activate_report( s : String )
	{
		report_text.set_text(s);
		report_text.set_visible(true);
		report_text.set_alpha(1.0);
		
		Actuate.update(report_text.set_alpha, 3.0, [1.0], [0.0]).delay(2.0);
	}
	
	public function on_activate_report_text(e)
	{
		var str = e.s;
		//trace(str);
		activate_report(str);
	}
}
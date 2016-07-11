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
	var countdown_text : MintLabelPanel;
	
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
	
	public function OnAudioLoad(e)
	{
		countdown_counter = countdown_time;
		countdown_text.set_visible(true);
		countdown_text.set_text( Std.string(countdown_counter) );
		can_put_platforms = false;
		
		countdown_timer = Luxe.timer.schedule( 1.0, function()
		{
			countdown_counter--;
			countdown_text.set_text( Std.string(countdown_counter) );
			if (countdown_counter == 0)
			{
				countdown_timer.stop();
				//var player_startpos = get_player_start_pos();
				countdown_text.set_visible(false);
				can_put_platforms = true;
				Luxe.events.fire("Level.Start", {pos:player_start_pos, beat_height:beat_height}, false );
			}
			//trace(countdown_counter);
			
		}, true);
	}
	
	public function on_game_unpause(e)
	{
		countdown_counter = countdown_time;
		countdown_text.set_visible(true);
		countdown_text.set_text( Std.string(countdown_counter) );
		
		countdown_timer = Luxe.timer.schedule( 1.0, function()
		{
			countdown_counter--;
			countdown_text.set_text( countdown_counter == 1 ? "Go!" : Std.string(countdown_counter) );
			if (countdown_counter == 0)
			{
				countdown_timer.stop();
				//var player_startpos = get_player_start_pos();
				countdown_text.set_visible(false);
			}
			//trace(countdown_counter);
			
		}, true);
	}
}
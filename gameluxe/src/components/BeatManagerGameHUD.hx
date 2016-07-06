package components;

import components.BeatManagerVisualizer.InitDisplayGeometry;
import components.Common.HVector;
import entities.BeatManager;
import luxe.Color;
import luxe.Component;
import luxe.Vector;
import luxe.options.ComponentOptions;
import luxe.tween.Actuate;
import phoenix.geometry.CircleGeometry;
import phoenix.geometry.QuadGeometry;

/**
 * ...
 * @author 
 */
class BeatManagerGameHUD extends Component
{
	public static var display_interval = 5; // 10 sec
	
	var bar_size : Vector;
	var num_bars_disp = 0;
	
	var outer_box : QuadGeometry;
	var inner_box : QuadGeometry;
	var beats_disp : HVector<QuadGeometry>;
	var audiopos_disp : CircleGeometry;
	
	var outer_offset : Vector;
	var inner_offset : Vector;
	var outer_bound : Vector;
	var inner_bound	: Vector;
	
	var parent : BeatManager;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
	}
	
	override public function onadded() 
	{
		parent = cast( entity, BeatManager );
		
		num_bars_disp = Std.int(display_interval * BeatManager.num_samples_one_second / BeatManager.instant_interval);
		
		outer_bound = new Vector( 500, 0.1 * Main.global_info.ref_window_size_y );
		inner_bound = new Vector( 0.95 * outer_bound.x, 0.95 * outer_bound.y );
		
		bar_size = new Vector( inner_bound.x / num_bars_disp, inner_bound.y );
		
		outer_offset = new Vector( Main.global_info.ref_window_size_x/2 - outer_bound.x/2, Main.global_info.ref_window_size_y - 1.1 * outer_bound.y );
		inner_offset = new Vector( outer_offset.x + 0.025 * inner_bound.x, outer_offset.y + 0.025 * inner_bound.y );
		
		init_display();
	}
	
	override public function onremoved() 
	{	
		deinit_display();
		
		super.onremoved();
	}
		
	public function init_display()
	{
		// draw into UI view
		var viewport_ui = parent.batcher;
		
		// static border
		outer_box = Luxe.draw.box(
		{
			batcher : viewport_ui,
			depth : 1,
			x : outer_offset.x, y : outer_offset.y,
			w : outer_bound.x,
			h : outer_bound.y,
			color : new Color(0.5, 0.5, 0.5, 0.1)
		});
		
		inner_box = Luxe.draw.box(
		{
			batcher : viewport_ui,
			depth : 1,
			x : inner_offset.x, y : inner_offset.y,
			w : inner_bound.x,
			h : inner_bound.y,
			color : new Color(0.2, 0.2, 0.5, 0.2)
		});
				
		
		function init_display_geometry(init_options : InitDisplayGeometry)
		{
			for (i in 0...init_options.container.length)
			{
				init_options.container[i] = Luxe.draw.box({
					batcher : viewport_ui,
					depth : init_options.depth,
					x : inner_offset.x + i*bar_size.x, y : inner_offset.y + bar_size.y,
					w : bar_size.x,
					h : -bar_size.y,
					color : init_options.color,
					visible : false
				});
			}
		}
				
		// beats				
		beats_disp = new HVector<QuadGeometry>(num_bars_disp);
		var init_options = { container: beats_disp, depth: 2, color : new Color(0.5, 0.5, 0.5, 1) };
		init_display_geometry(init_options);
				
		// audio pos
		audiopos_disp = Luxe.draw.circle({
			batcher : viewport_ui,
			depth : init_options.depth,
			x : inner_offset.x , y : inner_offset.y + inner_bound.y * 0.8,
			r : bar_size.x * 5
		});
	}
	
	function deinit_display() 
	{
		audiopos_disp.drop();
		
		for (i in 0...beats_disp.length ) beats_disp[i].drop();
		
		inner_box.drop();
		outer_box.drop();
	}
	
	public function update_display(curr_time:Float)
	{
		var curr_display_interval = Std.int(curr_time / display_interval);
		var curr_display_interval_frag = (curr_time / display_interval) % 1.0; 
		var curr_display_interval_beg = curr_display_interval * num_bars_disp;
		
		for (i in 0...beats_disp.length)
		{
			var beat = BeatManager.get_data(parent.beat, curr_display_interval_beg + i) > 0;
			beats_disp[i].visible = beat;
		}
		
		if (audiopos_disp != null)
		{
			audiopos_disp.transform.pos.x = inner_offset.x + curr_display_interval_frag * inner_bound.x;
		}
	}
	
	public function on_move_event( interval: Float)
	{
		Actuate.tween(audiopos_disp.transform.pos, interval * 0.25, {y:inner_offset.y + inner_bound.y * 0.25}).reflect().repeat(1);
	}
}
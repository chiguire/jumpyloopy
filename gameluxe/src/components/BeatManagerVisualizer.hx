package components;

import entities.BeatManager;
import luxe.Color;
import luxe.Component;
import luxe.Entity;
import luxe.Visual;
import luxe.options.ComponentOptions;
import luxe.tween.easing.Quad;
import phoenix.geometry.LineGeometry;
import phoenix.geometry.QuadGeometry;
import components.Common.HVector;

import haxe.ds.Vector;
import luxe.Vector;

/**
 * ...
 * @author aik
 */

typedef InitDisplayGeometry = 
{
	var container : HVector<QuadGeometry>;
	var depth : Int;
	var color : Color;
};
 
class BeatManagerVisualizer extends Component
{
	/// constants
	var offsetx = 5;
	var offsety = 0;
	public static var display_interval = 10; // 10 sec
	
	/// helpers
	var bar_size : Vector;
	var num_bars_disp = 0;
	
	
	var parent : BeatManager;
	
	var size : Vector; 
	
	/// display
	var energy1024_disp	: HVector<QuadGeometry>;
	var energy44100_disp : HVector<QuadGeometry>;
	var energypeaks_disp : HVector<QuadGeometry>;
	var conv_disp : HVector<QuadGeometry>;
	var beats_disp : HVector<QuadGeometry>;
	var audiopos_disp : LineGeometry;
	
	/// fft analysis
	var spectral_flux_disp : HVector<QuadGeometry>;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
	}
	
	override public function init()
	{
		super.onadded();
	}
	
	override public function onadded() 
	{
		parent = cast( entity, BeatManager );
		
		num_bars_disp = Std.int(display_interval * BeatManager.num_samples_one_second / BeatManager.instant_interval);
		size = new Vector( (Main.global_info.ref_window_size_x - Main.global_info.ref_window_size_y / Main.ref_window_aspect()) / 2 - 10, 0.1 * Main.global_info.ref_window_size_y );
		bar_size = new Vector( size.x / num_bars_disp, size.y );
		
		offsetx = 10;
		offsety = 10;
		
		init_display();
	}
				
	public function init_display()
	{
		// draw into UI view
		var viewport_ui = parent.batcher;
		
		// static border
		var geom = Luxe.draw.rectangle(
		{
			batcher : viewport_ui,
			depth : 1,
			x : offsetx, y : offsety,
			w : size.x,
			h : size.y,
			color : new Color(0.5, 0, 0, 1)
		});
				
		function init_display_geometry(init_options : InitDisplayGeometry)
		{
			for (i in 0...init_options.container.length)
			{
				init_options.container[i] = Luxe.draw.box({
					batcher : viewport_ui,
					depth : init_options.depth,
					x : offsetx + i*bar_size.x, y : offsety + bar_size.y,
					w : bar_size.x,
					h : bar_size.y,//bar_size.y * parent.energy1024[i]/(65335*65335*2),
					color : init_options.color
				});
			}
		}
				
		// draw energy
		energy1024_disp = new HVector<QuadGeometry>(num_bars_disp);
		var init_options = { container: energy1024_disp, depth: 1, color : new Color(0.5, 0.5, 0, 1) };
		init_display_geometry(init_options);
		
		energy44100_disp = new HVector<QuadGeometry>(num_bars_disp);
		init_options = { container: energy44100_disp, depth: 1, color : new Color(0.4, 0.4, 0, 1) };
		init_display_geometry(init_options);
		
		energypeaks_disp = new HVector<QuadGeometry>(num_bars_disp);
		init_options = { container: energypeaks_disp, depth: 1, color : new Color(0.75, 0.75, 0, 1) };
		init_display_geometry(init_options);
		
		conv_disp = new HVector<QuadGeometry>(num_bars_disp);
		init_options = { container: conv_disp, depth: 1, color : new Color(0.0, 0.75, 0, 1) };
		init_display_geometry(init_options);
				
		beats_disp = new HVector<QuadGeometry>(num_bars_disp);
		init_options = { container: beats_disp, depth: 2, color : new Color(0.0, 0.5, 0, 1) };
		init_display_geometry(init_options);
				
		// audio pos
		audiopos_disp = Luxe.draw.line({
			batcher : viewport_ui,
			depth : 3,
            p0 : new Vector( offsetx + parent.audio_time * size.x, offsety ),
            p1 : new Vector( offsetx + parent.audio_time * size.x, offsety + size.y ),
            color : new Color(0.5,0.2,0.2,1)
        });
		
		//spectral_flux_disp = new HVector<QuadGeometry>(num_bars_disp);
		//init_options = { container: spectral_flux_disp, depth: 1, color : new Color(0.5, 0.0, 0, 1) };
		//init_display_geometry(init_options);
	}
	
	public function update_display(curr_time:Float)
	{
		var curr_display_interval = Std.int(curr_time / display_interval);
		var curr_display_interval_frag = (curr_time / display_interval) % 1.0; 
		var curr_display_interval_beg = curr_display_interval * num_bars_disp;
		
		for (i in 0...energy1024_disp.length)
		{
			energy1024_disp[i].transform.scale.y = BeatManager.get_data(parent.energy1024, curr_display_interval_beg + i) / (65335*65335*2);
		}
		
		for (i in 0...energy44100_disp.length)
		{
			energy44100_disp[i].transform.scale.y = BeatManager.get_data(parent.energy44100, curr_display_interval_beg + i) / (65335*65335*2);
		}
		
		for (i in 0...energypeaks_disp.length)
		{
			var scale = BeatManager.get_data(parent.energy_peak, curr_display_interval_beg + i) > 0.0 ? -0.2 : 0.0;
			energypeaks_disp[i].transform.scale.y = scale;
		}
		
		for (i in 0...conv_disp.length)
		{
			var scale = BeatManager.get_data(parent.conv, curr_display_interval_beg + i) > 0.0 ? -0.1 : 0.0;
			conv_disp[i].transform.scale.y = scale;
		}
		
		for (i in 0...beats_disp.length)
		{
			var scale = BeatManager.get_data(parent.beat, curr_display_interval_beg + i) > 0.0 ? -1.0 : 0.0;
			beats_disp[i].transform.scale.y = scale;
		}
		
		if (audiopos_disp != null)
		{
			audiopos_disp.p0.x = offsetx + curr_display_interval_frag * size.x;
			audiopos_disp.p1.x = offsetx + curr_display_interval_frag * size.x;
		}
	}
	
	override public function update(dt:Float) 
	{	
		super.update(dt);
	}
}
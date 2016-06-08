package components;

import entities.BeatManager;
import luxe.Color;
import luxe.Component;
import luxe.Entity;
import luxe.Vector;
import luxe.Visual;
import luxe.options.ComponentOptions;
import phoenix.geometry.LineGeometry;

/**
 * ...
 * @author aik
 */

 
class BeatManagerVisualizer extends Component
{
	/// constants
	var offsetx = 5;
	
	var parent : BeatManager;
	var size : Vector;
	
	var audio_pos : LineGeometry;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
	}
	
	override public function onadded() 
	{
		super.onadded();
		Luxe.events.listen("BeatManager.AudioLoaded", OnAudioLoad );
		
		parent = cast( entity, BeatManager );
		
		size = new Vector( Luxe.screen.size.x - 10, 0.23 * Luxe.screen.size.y );
	}
	
	public function OnAudioLoad(e)
	{
		// get UI view
		var viewport_ui = parent.batcher;
		
		var offsety = Std.int(0.75 * Luxe.screen.height);
		var geom = Luxe.draw.rectangle({
				batcher : viewport_ui,
				depth : 1,
                x : offsetx, y : offsety,
                w : size.x,
                h : size.y,
				color : new Color(0.5, 0, 0, 1)
            });
			
		// draw energy
		var bar_size = new Vector( size.x / parent.num_instant_interval, size.y );
		for(i in 0...parent.num_instant_interval)
		Luxe.draw.box({
				batcher : viewport_ui,
				depth : 1,
                x : offsetx + i*bar_size.x, y : offsety + bar_size.y,
                w : bar_size.x,
                h : bar_size.y * parent.energy1024[i]/(65335*65335*2),
				color : new Color(0.5, 0.5, 0, 1)
            });
			
		// draw energy peaks
		for(i in 0...parent.num_instant_interval)
		Luxe.draw.box({
				batcher : viewport_ui,
				depth : 1,
                x : offsetx + i*bar_size.x, y : offsety,
                w : bar_size.x,
                h : bar_size.y * (parent.energy_peak[i] > 0.0 ? 0.1 : 0.0),
				color : new Color(0.75, 0.75, 0, 1)
            });
			
		// draw conv
		for(i in 0...parent.num_instant_interval)
		Luxe.draw.box({
				batcher : viewport_ui,
				depth : 1,
                x : offsetx + i*bar_size.x, y : offsety + bar_size.y * 0.1,
                w : bar_size.x,
                h : bar_size.y * (parent.conv[i] > 0.0 ? 0.1 : 0.0),
				color : new Color(0.0, 0.75, 0, 1)
            });
			
		// draw beats
		for(i in 0...parent.beat.length)
		Luxe.draw.line({
				batcher : viewport_ui,
				depth : 2,
				p0 : new Vector( offsetx + parent.beat_pos[i]/parent.num_instant_interval * size.x, offsety ),
				p1 : new Vector( offsetx + parent.beat_pos[i]/parent.num_instant_interval * size.x, offsety + size.y ),
				color : new Color(0.0, 0.5, 0, 1)
            });
			
		// draw audio line
		audio_pos = Luxe.draw.line({
			batcher : viewport_ui,
			depth : 3,
            p0 : new Vector( offsetx + parent.audio_pos * size.x, offsety ),
            p1 : new Vector( offsetx + parent.audio_pos * size.x, offsety + size.y ),
            color : new Color(0.5,0.2,0.2,1)
        });
	}
	
	override public function update(dt:Float) 
	{	
		super.update(dt);
		
		audio_pos.p0.x = offsetx + parent.audio_pos * size.x;
		audio_pos.p1.x = offsetx + parent.audio_pos * size.x;
	}
}
package components;

import entities.BeatManager;
import luxe.Color;
import luxe.Component;
import luxe.Vector;
import luxe.options.ComponentOptions;

/**
 * ...
 * @author aik
 */
class BeatManagerVisualizer extends Component
{
	var parent : BeatManager;
	
	var size : Vector;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
		
		
	}
	
	override public function onadded() 
	{
		super.onadded();
		
		parent = cast( entity, BeatManager );
		
		size = new Vector( Luxe.screen.size.x - 10, 0.23 * Luxe.screen.size.y );
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		var offsetx = 5 + Luxe.camera.pos.x;
		var offsety = Std.int(0.75 * Luxe.screen.height) + Luxe.camera.pos.y;
		Luxe.draw.rectangle({
                //this line is important, as each frame it will create new geometry!
                immediate : true,
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
                //this line is important, as each frame it will create new geometry!
                immediate : true,
				depth : 1,
                x : offsetx + i*bar_size.x, y : offsety,
                w : bar_size.x,
                h : bar_size.y * parent.energy1024[i]/(65335*65335*2),
				color : new Color(0.5, 0.5, 0, 1)
            });
			
		// draw audio line
		Luxe.draw.line({
			immediate : true,
			depth : 2,
            p0 : new Vector( offsetx + parent.audio_pos * size.x, offsety ),
            p1 : new Vector( offsetx + parent.audio_pos * size.x, offsety + size.y ),
            color : new Color(0.5,0.2,0.2,1)
        });
	}
}
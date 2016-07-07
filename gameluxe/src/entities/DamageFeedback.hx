package entities;

import components.VisualFlashingComponent;
import luxe.Color;
import luxe.Scene;
import luxe.Vector;
import luxe.options.SpriteOptions;
import luxe.Sprite;

/**
 * ...
 * @author Aik
 */
class DamageFeedback extends Sprite
{		
	public var visual_flashing_comp: VisualFlashingComponent;
	
	public function new(scene : Scene) 
	{
		var options : SpriteOptions = {
			pos : Main.mid_screen_pos(),
			size : Main.gameplay_area_size(),
			color : new Color(0.5, 0, 0, 0.25),
			batcher : Main.batcher_ui,
			depth : 98,
			scene : scene,
			visible : false,
		};
				
		super(options);
		
		visual_flashing_comp = new VisualFlashingComponent();
		add(visual_flashing_comp);
	}
	
}
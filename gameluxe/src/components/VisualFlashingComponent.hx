package components;

import luxe.Component;
import snow.api.Timer;
import luxe.Visual;
import luxe.options.ComponentOptions;

/**
 * ...
 * @author Aik
 */
class VisualFlashingComponent extends Component
{
	var parent: Visual;
	var timer: Timer;
	var count = 0;
	// flashing speed, tweakable
	var speed = 0.05;
	var saved_visible_state = false;
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
		
	}
	
	public function is_activated() : Bool
	{
		return timer != null;
	}
	
	override public function onadded() 
	{
		super.onadded();
		
		parent = cast(entity, Visual);
		saved_visible_state = parent.visible;
	}
	
	override public function onremoved() 
	{
		super.onremoved();
		
		deactivate();
	}
	
	public function activate()
	{
		if (parent != null && timer == null)
		{
			count = 0;
			timer = Luxe.timer.schedule(speed, function(){
				parent.visible = (count % 2 == 1);
				count++;
			}, true);
		}
	}
	
	public function deactivate()
	{
		count = 0;
		if (timer != null) 
		{
			timer.stop();
			timer = null;
		}
		
		if (parent != null)
		{
			parent.visible = saved_visible_state;
		}
	}
}
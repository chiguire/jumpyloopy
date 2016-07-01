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
	
	public function new(?_options:ComponentOptions) 
	{
		super(_options);
		
	}
	
	public function is_activated() : Bool
	{
		return count > 0;
	}
	
	override public function onadded() 
	{
		super.onadded();
		
		parent = cast(entity, Visual);
	}
	
	override public function onremoved() 
	{
		super.onremoved();
		
		deactivate();
	}
	
	public function activate()
	{
		if (parent != null)
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
		if (parent != null)
		{
			parent.visible = true;
		}
		
		if (timer != null) timer.stop();
	}
}
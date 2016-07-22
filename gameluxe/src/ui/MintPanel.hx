package ui;

import mint.Panel;
import mint.Panel.PanelOptions;

/**
 * ...
 * @author 
 */
class MintPanel extends Panel
{
	public function new(_options:PanelOptions) 
	{
		super(_options);	
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		for (obj in children)
		{
			obj.update(dt);
		}
	}
}
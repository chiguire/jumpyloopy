package ui;

import luxe.Color;
import mint.Button;
import mint.Button.ButtonOptions;

/**
 * ...
 * @author Aik
 */
class MintButton extends Button
{	
	public function new(_options:ButtonOptions) 
	{
		super(_options);
		
		var button_renderer = cast(renderer, mint.render.luxe.Button);
		var text_renderer = cast(label.renderer, mint.render.luxe.Label);
		
		button_renderer.color = new Color(0.95, 0.95, 0.95, 1);
		button_renderer.color_hover = new Color(1, 1, 1, 1);
		button_renderer.color_hover = new Color(0.9, 0.9, 0.9, 1);
		button_renderer.visual.color = button_renderer.color; 
		button_renderer.visual.texture = Luxe.resources.texture("launcher_assets/image/UI_Game_Pause_paper.png");
		
		text_renderer.text.color = new Color(0.1, 0.1, 0.1, 1);
		text_renderer.text.font = Luxe.resources.font(Main.font_id);
	}
}
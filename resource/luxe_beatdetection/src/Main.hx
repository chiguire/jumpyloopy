package;

import luxe.Input;
import luxe.Screen;
import luxe.Vector;

// basic sprite
import luxe.Sprite;
import luxe.Color;

class Main extends luxe.Game 
{
	var m_centerPiece:Sprite;
	
	override function ready() 
	{
		// create an asset here
		m_centerPiece = new Sprite({
			name: "beat",
			pos: Luxe.screen.mid,
		size: new Vector(128,128)});
	}

	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
			
		if (e.keycode == Key.space)
		{
			m_centerPiece.destroy();
		}
	}

	override function update(dt:Float) 
	{
	}
}

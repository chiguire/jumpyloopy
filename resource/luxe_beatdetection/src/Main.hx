package;

import luxe.Input;

// basic sprite
import luxe.Sprite;
import luxe.Color;

class Main extends luxe.Game 
{
	var m_centerPiece:Sprite;
	
	override function ready() 
	{
		// create an asset here
		
	}

	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
	}

	override function update(dt:Float) 
	{
	}
}

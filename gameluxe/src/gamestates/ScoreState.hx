package gamestates;

import data.GameInfo;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
import mint.types.Types.TextAlign;

/**
 * ...
 * @author 
 */
class ScoreState extends State
{
	private var game_info : GameInfo;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			machine.set("MenuState");
	}
	
	override function onleave<T>(_value:T)
	{
		Main.canvas.destroy_children();	
	}
	
	override function onenter<T>(_value:T)
	{
		var label = new mint.Label({
			parent: Main.canvas, name: 'label',
			mouse_input:false, x:0, y:0, w:Main.global_info.ref_window_size_x, h:Main.global_info.ref_window_size_y, text_size: 32,
			align: TextAlign.center, align_vertical: TextAlign.center,
			text: "Thanks For Playing!\nPress Esc to go back to the Main Menu",
		});
	}
	
}
package gamestates;

import data.GameInfo;
import luxe.Scene;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
import mint.types.Types.TextAlign;
import ui.MintLabelPanel;

/**
 * ...
 * @author 
 */
class ScoreState extends State
{
	private var game_info : GameInfo;
	
	var scene : Scene;
	
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
		scene.empty();
		scene.destroy();
		
		Main.canvas.destroy_children();	
	}
	
	override function onenter<T>(_value:T)
	{
		// load parcels
		scene = new Scene();
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		/*
		var label = new mint.Label({
			parent: Main.canvas, name: 'label',
			mouse_input:false, x:0, y:0, w:Main.global_info.ref_window_size_x, h:Main.global_info.ref_window_size_y, text_size: 32,
			align: TextAlign.center, align_vertical: TextAlign.center,
			text: "Thanks For Playing!\nPress Esc to go back to the Main Menu",
		});*/
		
		create_panel();
	}
	
	function create_panel()
	{
		Main.create_background(scene);
		
		var panel = new MintLabelPanel({
			x: 720-225, y: 200, w: 450, h: 600, 
			text: "-Your Score-\n\n
				Score\t\t\t\t\t200\n
				Distance\t\t\t\t\t225\n
				PlayTime\t\t\t\t\t0:3:12\n\n
				Total Score\t\t\t\t\t1000\n
				Total Distance\t\t\t\t\t3425\n
				Total PlayTime\t\t\t\t\t10:11:44\n\n\n
				Thanks For Playing!\nPress Esc to go back to the Main Menu"
		});
	}
}
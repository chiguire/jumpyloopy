package gamestates;

import data.GameInfo;
import luxe.Scene;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
import mint.types.Types.TextAlign;
import ui.MintLabel;
import ui.MintLabelPanel;
import luxe.Sprite;

/**
 * ...
 * @author 
 */
class ScoreState extends State
{
	private var game_info : GameInfo;
	
	var scene : Scene;
	
	private var bg_image : Sprite;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function init()
	{
		
	}
	
	override function onleave<T>(_value:T)
	{
		bg_image.destroy();
		scene.empty();
		scene.destroy();
		scene = null;
		bg_image = null;
		
		Main.canvas.destroy_children();	
	}
	
	override function onenter<T>(_value:T)
	{
		// load parcels
		scene = new Scene();
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		var data : Dynamic = { pos_x: 720, pos_y: 450 };
		
		bg_image = new Sprite({
			name: 'BgSprite',
			texture: Luxe.resources.texture('assets/image/bg/cave_01_paper.png'),
			pos: new Vector(data.pos_x, data.pos_y),
			scene: scene,
		});
		
		create_panel();
	}
	
	function create_panel()
	{
		Main.create_background(scene);
		
		var name = ["Score", "Distance", "Time"];
		var val = [Std.string(game_info.current_score.score), Std.string(game_info.current_score.distance), Std.string(game_info.current_score.time)];
		
		for (i in 0...name.length)
		{
			new MintLabel({
				parent: Main.canvas,
				mouse_input:false, x:495, y:200 + i*72, w:450, h:72, text_size: 48,
				align: TextAlign.left, align_vertical: TextAlign.center,
				text: name[i],
				color: Main.global_info.text_color,
			});
			
			
			new MintLabel({
				parent: Main.canvas,
				mouse_input:false, x:495, y:200 + i*72, w:450, h:72, text_size: 48,
				align: TextAlign.right, align_vertical: TextAlign.center,
				text: val[i],
				color: Main.global_info.text_color,
			});
		}
				
		
		/*
		var panel = new MintLabelPanel({
			x: 495, y: 200, w: 450, h: 600, 
			text: "-Your Score-\n\n
				Score\t\t\t\t\t200\n
				Distance\t\t\t\t\t225\n
				PlayTime\t\t\t\t\t0:3:12\n\n
				Total Score\t\t\t\t\t1000\n
				Total Distance\t\t\t\t\t3425\n
				Total PlayTime\t\t\t\t\t10:11:44\n\n\n
				Thanks For Playing!\nPress Esc to go back to the Main Menu"
		});
		*/
	}
	
	override function update(dt:Float) 
	{
		var go_to_menu =
			Luxe.input.mousepressed(MouseButton.left) ||
			Luxe.input.mousepressed(MouseButton.right) ||
			Luxe.input.keypressed(Key.space) ||
			Luxe.input.keypressed(Key.escape) ||
			Luxe.input.keypressed(Key.backspace);
			
		if (go_to_menu)
		{
			machine.set("MenuState");
		}
	}
}
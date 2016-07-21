package gamestates;

import data.GameInfo;
import luxe.Scene;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
import mint.TextEdit;
import mint.types.Types.TextAlign;
import ui.MintImageButton;
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
	
	var text_edit : TextEdit;
	
	private var bg_image : Sprite;
	
	/// deferred state transition
	var change_state_signal = false;
	var next_state = "";
	
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
		change_state_signal = false;
		next_state = "";
		
		text_edit.unfocus();
		bg_image.destroy();
		scene.empty();
		scene.destroy();
		scene = null;
		bg_image = null;
		
		Main.canvas.destroy_children();	
		text_edit = null;
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
				mouse_input:false, x:520, y:200 + (i+1)*72, w:400, h:72, text_size: 48,
				align: TextAlign.left, align_vertical: TextAlign.center,
				text: name[i],
				color: Main.global_info.text_color,
			});
			
			
			new MintLabel({
				parent: Main.canvas,
				mouse_input:false, x:520, y:200 + (i+1)*72, w:400, h:72, text_size: 48,
				align: TextAlign.right, align_vertical: TextAlign.center,
				text: val[i],
				color: Main.global_info.text_color,
			});
		}
		
		new MintLabel({
			parent: Main.canvas,
			mouse_input:false, x:520, y:200, w:400, h:72, text_size: 48,
			align: TextAlign.left, align_vertical: TextAlign.center,
			text: "Your name:",
			color: Main.global_info.text_color,
		});
		
		text_edit = new TextEdit({
			text: game_info.current_score.name,
			x: 690, y:200, text_size: 48,
			w: 230, h: 72,
			parent: Main.canvas,
		});
		
		var button = new MintImageButton(Main.canvas, "MainMenu", new Vector(620, 200 + (name.length + 2) * 72), new Vector(202, 42), "assets/image/ui/UI_score_Mainmenu.png");
		button.onmouseup.listen(function(e, c) {
			game_info.current_score.name = text_edit.text;
			Main.submit_score(game_info.current_score);
			
			change_state_signal = true;
			next_state = "MenuState";
			
			//machine.set("MenuState");
		});
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (change_state_signal)
		{
			machine.set(next_state);
		}
	}
}
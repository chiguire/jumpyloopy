package gamestates;

import data.GameInfo;
import luxe.Color;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.Input.MouseButton;
import luxe.Scene;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.Actuate;

/**
 * ...
 * @author Aik
 */
class StoryEndingState extends State
{
	private var game_info : GameInfo;
	private var scene : Scene;
	
	var story_fragment_disp : Array<Text>;
	var paragraph_height = 72;
	var first_offset = 150;
	
	var first_delay = 1.0;
	var fade_in_duration = 1.5;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
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
		scene = null;
	}
	
	override function onenter<T>(_value:T)
	{	
		trace("enter StoryEndingState");
		scene = new Scene("StoryEndingScene");
		
		Main.create_background(scene);
		
		var background = new Sprite({
			texture: Luxe.resources.texture("assets/image/bg/cave_01_paper.png"),
			pos: Main.mid_screen_pos(),
			scene: scene,
			batcher: Main.batcher_ui,
		});
		
		StoryIntroState.reveal_story_fragments(scene);
	}
	
	override function update(dt:Float) 
	{
		var change_state = Luxe.input.mousepressed(MouseButton.left) ||
			Luxe.input.mousepressed(MouseButton.right) ||
			Luxe.input.keypressed(Key.space) ||
			Luxe.input.keypressed(Key.escape) ||
			Luxe.input.keypressed(Key.backspace);
			
		if(change_state)
		{
			var next_state = Main.achievement_manager.unlockables.completed_story_mode ? "StoryCompleteState" : "MenuState";
			machine.set(next_state);
		}
	}
}
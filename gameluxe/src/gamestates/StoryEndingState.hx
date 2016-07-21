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
		
		var collected_fragments = Main.achievement_manager.collected_fragments;
		trace(collected_fragments.length);
		
		story_fragment_disp = new Array<Text>();
		for (i in 0...collected_fragments.length )
		{
			story_fragment_disp.push(new Text({
				font: Luxe.resources.font(Main.rise_font_id),
				text: "",
				align: TextAlign.center,
				align_vertical: TextAlign.center,
				point_size: 24,
				pos: new Vector(Main.mid_screen_pos().x, first_offset + paragraph_height*i),
				scene: scene,
				color: new Color().rgb(0x3f2414),
				outline: 0,
				glow_amount: 0,
				visible: false,
				batcher: Main.batcher_ui,
			}));	
		}
		
		var letter_content = Luxe.resources.json(Main.letter_id).asset.json;
		for (i in 0...collected_fragments.length )
		{
			var txt = collected_fragments[i] ? letter_content.letter[i] : "...-Missing Story Fragment-..."; 
			
			var frag = story_fragment_disp[i];
			frag.visible = true;
			frag.color.a = 0;
			frag.text = txt;
			Actuate.tween(frag.color, fade_in_duration, { a: 1.0 }).delay(first_delay + first_delay * i);
		}
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
			machine.set("MenuState");
		}
	}
}
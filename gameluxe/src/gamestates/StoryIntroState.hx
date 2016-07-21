package gamestates;

import data.GameInfo;
import luxe.Color;
import luxe.Input.Key;
import luxe.Input.MouseButton;
import luxe.Parcel;
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
class StoryIntroState extends State
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
	}
	
	override function onleave<T>(_value:T)
	{
		Actuate.reset();
		
		
		scene.empty();
		scene.destroy();
		scene = null;
	}
	
	override function onenter<T>(_value:T)
	{		
		scene = new Scene();
		
		Main.create_background(scene);
		
		var background = new Sprite({
			texture: Luxe.resources.texture("assets/image/bg/cave_01_paper.png"),
			pos: Main.mid_screen_pos(),
			scene: scene,
			batcher: Main.batcher_ui,
		});
		
		var story_end_disp = new Sprite({
				scene : scene,
				texture : Luxe.resources.texture("assets/image/collectables/letter.png"),
				size : new Vector(250 * 1.5, 150 * 1.5),
				pos : Main.mid_screen_pos(),
				batcher: Main.batcher_ui,
				depth: 2,
		});
			
		trace( story_end_disp.pos );
		story_end_disp.rotation_z  = -3;
		Actuate.tween(story_end_disp, 2.0, { rotation_z : 3 }).reflect().repeat();
		
		story_end_disp.pos.y = 900;
		Actuate.tween(story_end_disp.pos, 15.0, { y : -900 });
		
		story_end_disp.pos.x = Luxe.utils.random.float(320, 1120);
		Actuate.tween(story_end_disp.pos, 5.0, { x : 720 }).reflect().repeat();
	
		var collected_fragments = Main.achievement_manager.collected_fragments;
		
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
		
		for (i in 0...collected_fragments.length )
		{
			var txt = collected_fragments[i] ? "...The quick brown fox jumps over the lazy dog\nThe quick brown fox jumps over the lazy dog..." : "...-Missing Story Fragment-..."; 
			
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
			var game_state_on_enter_data = { is_story_mode: true, play_audio_loop: true };
			machine.set("GameState", game_state_on_enter_data);
		}
	}
}
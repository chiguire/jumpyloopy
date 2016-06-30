package gamestates;

import data.GameInfo;
import luxe.Parcel;
import luxe.Scene;
import luxe.Sprite;
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
	private var scene : Scene;
	var parcel : Parcel;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
	}
	
	override function onleave<T>(_value:T)
	{
		Actuate.reset();
		//Luxe.audio.stop(music_handle);
		
		//Main.canvas.destroy_children();
		
		scene.empty();
		scene.destroy();
		scene = null;
		
		parcel = null;
	}
	
	override function onenter<T>(_value:T)
	{		
		// load parcels
		parcel = new Parcel();
		Main.load_parcel(parcel, "assets/data/story_intro_parcel.json", on_parcel_loaded);
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		scene = new Scene();
	}
	
	function on_parcel_loaded( p: Parcel )
	{
		var mid_pos = new Vector(Main.global_info.ref_window_size_x - Main.global_info.ref_window_size_x / 2, Main.global_info.ref_window_size_y / 2);
		
		var background = new Sprite({
			texture: Luxe.resources.texture("assets/image/bg/cave_01_paper.png"),
			pos: mid_pos,
			//size: new Vector(layout_data.background.width, layout_data.background.height),
			scene: scene,
		});
		
		var sprite = new Sprite({
			texture: Luxe.resources.texture("assets/image/story/01_mylove.png"),
			pos: mid_pos,
			//size: new Vector(layout_data.background.width, layout_data.background.height),
			scene: scene,
		});
		sprite.color.a = 0;
		
		Actuate.tween(sprite.color, 1.0, {a:1.0}).onComplete( function() { 
			Luxe.timer.schedule( 3.0, function() {
				Actuate.tween(sprite.color, 1.0, {a:0.0}).onComplete( function() { machine.set("GameState"); });
			});
		});
	}
}
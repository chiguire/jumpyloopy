package gamestates;

import data.GameInfo;
import entities.Avatar;
import entities.BeatManager;
import entities.Level;
import luxe.Camera;
import luxe.Input.Key;
import luxe.options.StateOptions;
import luxe.States.State;

import luxe.tween.Actuate;
import phoenix.Vector;
import luxe.Input;
import luxe.Sprite;
import luxe.Scene;

/**
 * ...
 * @author 
 */
class GameState extends State
{
	private var game_info : GameInfo;
	private var scene : Scene;
	
	private var level: Level;
	private var beat_manager: BeatManager;
	private var player_sprite: Avatar;
	
	var lanes : Array<Float>;
	var previous_lane : Int;
	var current_lane : Int;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		player_sprite = null;
		scene = null;
	}
	
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			machine.set("MenuState");
	}
	
	override function onleave<T>(d:T)
	{
		trace("Exiting game");
		
		scene.empty();
		scene.destroy();
		player_sprite = null;
		level = null;
		scene = null;
	}
	
	override function onenter<T>(d:T)
	{
		trace("Entering game");
		
		scene = new Scene("GameScene");
		
		level = new Level();
		beat_manager = new BeatManager();
		beat_manager.load_song();
		
		player_sprite = new Avatar({
			name: 'Player',
			texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			uv: game_info.spritesheet_elements['bunny1_ready.png'],
			pos: Luxe.screen.mid,
			//size: new Vector(game_info.spritesheet_elements['bunny1_ready.png'].w, game_info.spritesheet_elements['bunny1_ready.png'].h),
			size: new Vector(24, 48),
			//scene: scene,
		});
		
		connect_input();
		
		lanes = new Array<Float>();
		lanes.push(1 * Luxe.screen.width / 4.0);
		lanes.push(2 * Luxe.screen.width / 4.0);
		lanes.push(3 * Luxe.screen.width / 4.0);
		
		//player_sprite.pos.x = lanes[0];
		previous_lane = 0;
		current_lane = 0;		
	}
	
	override function update(dt:Float) 
	{
		
		if (Luxe.input.inputpressed('a'))
		{
			current_lane = 0;
		}
		else if (Luxe.input.inputpressed('b'))
		{
			current_lane = 1;
		}
		else if (Luxe.input.inputpressed('c'))
		{
			current_lane = 2;
		}
		
		if (current_lane != previous_lane)
		{
			//Actuate.tween(player_sprite.pos, 0.1, { x: lanes[current_lane] });
			trace(Luxe.camera.pos);
			Actuate.tween(Luxe.camera.pos, 0.1, { x: lanes[current_lane] });
		}
		
		previous_lane = current_lane;
	}
	
	private function connect_input()
	{
		// TODO remove key bindings when leaving, not urgent right now
		Luxe.input.bind_key('a', Key.key_q);
		Luxe.input.bind_key('b', Key.key_w);
		Luxe.input.bind_key('c', Key.key_e);
		
		//Luxe.input.bind_key("jump", Key.space);
		Luxe.input.bind_mouse("jump", MouseButton.left); 
	}
	
	override function onmousedown(event:MouseEvent)
	{
		
	}
}
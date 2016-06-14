package gamestates;

import data.GameInfo;
import entities.Avatar;
import entities.BeatManager;
import entities.Level;
import entities.Platform;
import entities.PlatformPeg;
import luxe.Camera;
import luxe.Color;
import luxe.Input.Key;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Rectangle;
import luxe.Text;
import luxe.options.StateOptions;
import luxe.States.State;
import phoenix.Batcher;

import luxe.tween.Actuate;
import phoenix.Vector;
import luxe.Input;
import luxe.Sprite;
import luxe.Scene;
import phoenix.Texture;

/**
 * ...
 * @author 
 */
class GameState extends State
{
	/// UI View
	var batcher_ui : Batcher;
	var camera_ui : Camera;
	
	
	private var game_info : GameInfo;
	private var scene : Scene;
	
	private var level: Level;

	private var sky_sprite : Sprite;

	private var beat_manager: BeatManager;

	private var player_sprite: Avatar;
	
	var lanes : Array<Float>;
	var previous_lane : Int;
	var current_lane : Int;
	
	var jumping_points : Array<PlatformPeg>;
	var jump_height : Float;
	var lane_start : Float;
	
	var sky_uv : Rectangle;
	
	var num_internal_lanes : Int;
	var num_all_lanes : Int;
	var num_peg_levels : Int;
	
	var beat_n : Int;
	var beat_start_wrap : Int;
	var platform_list : Array<Platform>;
	var mouse_platform : Platform;
	var mouse_pos : Vector;
	
	/// Text
	var processing_text : Text;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		player_sprite = null;
		scene = null;
		
		num_internal_lanes = 3;
		num_all_lanes = 5;
		num_peg_levels = 12;
		
		Luxe.events.listen("Level.Start", OnLevelStart );
		Luxe.events.listen("player_move_event", OnPlayerMove );
	}
	
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		//if (e.keycode == Key.escape)
		//	machine.set("MenuState");
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
		
		var lane_width = Luxe.screen.width * 1.25;
		
		lane_start = -0.5 * lane_width / num_all_lanes;
		lanes = new Array<Float>();
		lanes.push(lane_start + 0.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 1.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 2.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 3.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 4.0 * lane_width / num_all_lanes);
		
		scene = new Scene("GameScene");
		// create a view for UI rendering
		camera_ui = new Camera({name: "camera_ui"});
		batcher_ui = Luxe.renderer.create_batcher({name: "viewport_ui", camera: camera_ui.view});
		
		beat_manager = new BeatManager({batcher : batcher_ui});		
		level = new Level({batcher_ui : batcher_ui});
		
		var sky_texture = Luxe.resources.texture('assets/image/darkPurple.png');
		sky_texture.clamp_s = ClampType.repeat;
		sky_texture.clamp_t = ClampType.repeat;
		
		sky_uv = new Rectangle(0, 0, Luxe.screen.width, Luxe.screen.height);
		
		sky_sprite = new Sprite({
			name: 'Sky',
			texture: sky_texture,
			pos: Luxe.screen.mid,
			uv: sky_uv,
			size: new Vector(Luxe.screen.w, Luxe.screen.h)
		});
		
		jumping_points = new Array<PlatformPeg>();
		
		for (i in 0...num_internal_lanes * num_peg_levels)
		{
			var peg = new PlatformPeg(scene, game_info, i);
			peg.visible = false;
			jumping_points.push(peg);
		}
		
		player_sprite = new Avatar(lanes[2], {
			name: 'Player',
			texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			uv: game_info.spritesheet_elements['bunny1_ready.png'],
			pos: Luxe.screen.mid,
			//size: new Vector(game_info.spritesheet_elements['bunny1_ready.png'].w, game_info.spritesheet_elements['bunny1_ready.png'].h),
			size: new Vector(24, 48),
			scene: scene,
		});
		player_sprite.visible = false;
		
		connect_input();
		
		mouse_platform = new Platform(scene, game_info, 0, CENTER);
		
		mouse_pos = new Vector();
		
		/*
		Luxe.timer.schedule(0.4, function()
		{
			var res = beat_manager.async_load();
			res.then(function()
			{
				trace("Beats Loading completed!");
			});
		}, true); */
		
		
		//player_sprite.pos.x = lanes[0];
		//previous_lane = 0;
		//current_lane = 0;		
	}
	
	override function update(dt:Float) 
	{
		if (Luxe.input.inputpressed("put_platform"))
		{
			trace("Putting platform!");
		}
		else if (Luxe.input.inputpressed("switch_platform"))
		{
			trace("Switching platform!");
		}
		
		sky_uv.set((Luxe.camera.pos.x - Luxe.screen.width/2.0), (Luxe.camera.pos.y - Luxe.screen.height/2.0), sky_uv.w, sky_uv.h);
		//trace(sky_uv);
		sky_sprite.uv.set(sky_uv.x, sky_uv.y, sky_uv.w, sky_uv.h);
		sky_sprite.pos.set_xy(Luxe.camera.pos.x + Luxe.screen.width/2.0, Luxe.camera.pos.y + Luxe.screen.height/2.0);
		
		previous_lane = current_lane;
		
		var mouse_platform_x = lane_start + Math.max(1, Math.min(3, Math.fround((Luxe.camera.pos.x + mouse_pos.x) / (lanes[2] - lanes[1])))) * (lanes[2] - lanes[1]);
		var mouse_platform_y = Math.fround((Luxe.camera.pos.y + mouse_pos.y) / jump_height) * jump_height;
		mouse_platform.pos.set_xy(mouse_platform_x, mouse_platform_y);
	}
	
	private function connect_input()
	{
		Luxe.input.bind_mouse("put_platform", MouseButton.left); 
		Luxe.input.bind_mouse("switch_platform", MouseButton.right); 
	}
	
	override function onmousedown(event:MouseEvent)
	{
		
	}
	
	override function onmousemove(event:MouseEvent)
	{
		mouse_pos.set_xy(event.x, event.y);
	}
	
	function OnLevelStart( e:LevelStartEvent )
	{
		var jump_height = e.beat_height;
		var peg_y = e.pos.y - jump_height;
		var j = 0;
		for (peg in jumping_points)
		{
			peg.pos.set_xy(lanes[j + 1], peg_y);
			//trace('Setting peg at (${lanes[j + 1]}, $peg_y)');
			peg.visible = true;
			
			j++;
			if (j == 3)
			{
				j = 0;
				peg_y -= jump_height;
			}
		}
		this.jump_height = jump_height;
		beat_n = 0;
		beat_start_wrap = 7;
	}
	
	function OnPlayerMove( e:BeatEvent )
	{
		beat_n++;
		
		if (beat_n >= beat_start_wrap)
		{
			var n = beat_n - beat_start_wrap;
			var l = jumping_points.length;
			
			var prev_0_n = ( l + ( (n - 1) * num_internal_lanes + 0 ) ) % l;
			var prev_1_n = ( l + ( (n - 1) * num_internal_lanes + 1 ) ) % l;
			var prev_2_n = ( l + ( (n - 1) * num_internal_lanes + 2 ) ) % l;
			var current_0_n = (n * num_internal_lanes + 0) % l;
			var current_1_n = (n * num_internal_lanes + 1) % l;
			var current_2_n = (n * num_internal_lanes + 2) % l;
			
			trace('n is $n, prev is ($prev_0_n, $prev_1_n, $prev_2_n), current is ($current_0_n, $current_1_n, $current_2_n)');
			
			var prev_0 = jumping_points[prev_0_n];
			var prev_1 = jumping_points[prev_1_n];
			var prev_2 = jumping_points[prev_2_n];
			var current_0 = jumping_points[current_0_n];
			var current_1 = jumping_points[current_1_n];
			var current_2 = jumping_points[current_2_n];
			
			current_0.pos.y = prev_0.pos.y - jump_height;
			current_1.pos.y = prev_1.pos.y - jump_height;
			current_2.pos.y = prev_2.pos.y - jump_height;
		}
	}
}
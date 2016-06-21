package gamestates;

import data.GameInfo;
import entities.Avatar;
import entities.BeatManager;
import entities.Level;
import entities.Platform;
import entities.PlatformPeg;
import entities.PlatformType;
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
	private var game_info : GameInfo;
	private var scene : Scene;
	
	private var level: Level;

	private var sky_sprite : Sprite;

	private var beat_manager: BeatManager;

	private var player_sprite: Avatar;
	
	private var absolute_floor : Sprite;
	
	var lanes : Array<Float>;
	
	var jumping_points : Array<PlatformPeg>;
	var platform_points : Array<Platform>;
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
	var next_platform : Platform;
	var mouse_pos : Vector;
	var mouse_index_x : Int;
	var mouse_index_y : Int;
	var max_tile : Int;
	var starting_y : Float;
	
	var current_platform_type : PlatformType;
	var next_platform_type : PlatformType;
	
	/// Text
	var processing_text : Text;
	var debug_text : Text;
	
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
		
		beat_manager = new BeatManager({batcher : Main.batcher_ui});		
		level = new Level({batcher_ui : Main.batcher_ui});
		
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
		platform_points = new Array<Platform>();
		
		for (i in 0...num_internal_lanes * num_peg_levels)
		{
			var peg = new PlatformPeg(scene, game_info, i);
			peg.visible = false;
			jumping_points.push(peg);
			
			var platform = new Platform(scene, game_info, i, NONE);
			platform.visible = false;
			platform_points.push(platform);
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
		player_sprite.current_lane = 2;
		player_sprite.visible = false;
		
		absolute_floor = new Sprite({
			name: 'BottomFloor',
			texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			uv: game_info.spritesheet_elements['ground_cake.png'],
			pos: new Vector(Luxe.screen.width / 2.0, 0),
			size: new Vector(game_info.spritesheet_elements['ground_cake.png'].w, game_info.spritesheet_elements['ground_cake.png'].h),
			scene: scene,
		});
		absolute_floor.visible = false;
		
		connect_input();
		
		mouse_platform = new Platform(scene, game_info, num_internal_lanes * num_peg_levels + 1, NONE);
		next_platform = new Platform(scene, game_info, num_internal_lanes * num_peg_levels + 2, NONE);
		next_platform.pos.set_xy(Luxe.screen.width - 100, 40);
		
		mouse_pos = new Vector();
		
		debug_text = new Text({
			pos: new Vector(10, 10),
			text: "",
			color: new Color(210/255.0, 210/255.0, 210/255.0),
			point_size: 12,
			scene: scene,
		});
	}
	
	override function update(dt:Float) 
	{
		if (Luxe.input.inputpressed("put_platform"))
		{
			trace("Putting platform!");
			put_platform();
		}
		else if (Luxe.input.inputpressed("switch_platform"))
		{
			trace("Switching platform!");
			switch_platform();
		}
		
		sky_uv.set((Luxe.camera.pos.x - Luxe.screen.width/2.0), (Luxe.camera.pos.y - Luxe.screen.height/2.0), sky_uv.w, sky_uv.h);
		//trace(sky_uv);
		sky_sprite.uv.set(sky_uv.x, sky_uv.y, sky_uv.w, sky_uv.h);
		sky_sprite.pos.set_xy(Luxe.camera.pos.x + Luxe.screen.width/2.0, Luxe.camera.pos.y + Luxe.screen.height/2.0);
		
		//mouse_index_x = Std.int(Math.max(1, Math.min(3, Math.fround((Luxe.camera.pos.x + mouse_pos.x) / (lanes[2] - lanes[1])))));
		var lanes_distance = (lanes[2] - lanes[1]);
		max_tile = Math.round( (Luxe.screen.height/2.0 - Luxe.camera.pos.y) / jump_height);
		mouse_index_x = Std.int(Math.min(3, Math.max(1, Math.round((Luxe.camera.pos.x + mouse_pos.x + lanes_distance*0.5) / lanes_distance))));
		mouse_index_y = Math.round (mouse_pos.y / jump_height);
		var mouse_platform_x = lane_start + mouse_index_x * lanes_distance;
		var mouse_platform_y = mouse_index_y * jump_height;
		mouse_platform.pos.set_xy(mouse_platform_x, Math.min(Luxe.camera.pos.y + mouse_platform_y, starting_y));
		
		next_platform.pos.set_xy(Luxe.screen.width - 100, Luxe.camera.pos.y + 40);
		
		debug_text.pos.y = Luxe.camera.pos.y + 10;
		debug_text.text = 'player (${player_sprite.current_lane}, $beat_n) / cursor (${mouse_index_x}, $mouse_index_y)\ncamera (${Luxe.camera.pos.x}, ${Luxe.camera.pos.y}) / maxtile $max_tile';
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
		var peg_y = e.pos.y;
		starting_y = e.pos.y;
		var j = 0;
		var first_line = true;
		for (i in 0...jumping_points.length)
		{
			var peg = jumping_points[i];
			var platform = platform_points[i];
			
			peg.pos.set_xy(lanes[j + 1], peg_y);
			platform.pos.set_xy(lanes[j + 1], peg_y);
			//trace('Setting peg at (${lanes[j + 1]}, $peg_y)');
			peg.visible = true;
			platform.visible = platform.type != NONE;
			
			if (first_line)
			{
				platform.type = CENTER;
				platform.visible = false;
			}
			
			j++;
			if (j == 3)
			{
				first_line = false;
				j = 0;
				peg_y -= jump_height;
			}
		}
		this.jump_height = jump_height;
		beat_n = 0;
		beat_start_wrap = 7;
		
		absolute_floor.visible = true;
		absolute_floor.pos.x = lanes[2];
		absolute_floor.pos.y = starting_y + absolute_floor.size.y / 2.0;
		
		current_platform_type = get_next_platform_type();
		next_platform_type = get_next_platform_type();
		
		mouse_platform.type = current_platform_type;
	}
	
	function OnPlayerMove( e:BeatEvent )
	{
		var pl_src = get_platform(player_sprite.current_lane, beat_n);
		
		//trace('player is now at ${player_sprite.current_lane}, $beat_n' );
		//trace('cursor is now at ${mouse_index_x}, $mouse_index_y' );
		
		if (pl_src == null)
		{
			trace('player is standing outside lanes. Game over');
		}
		else
		{
			player_sprite.current_lane = player_sprite.current_lane + switch (pl_src.type)
			{
				case NONE: 0;
				case CENTER: 0;
				case LEFT: -1;
				case RIGHT: 1;
			}
			
			if (player_sprite.current_lane < 1 || player_sprite.current_lane > 3)
			{
				trace('Game over');
				return;
			}
			
			var pl_dst = get_platform(player_sprite.current_lane, beat_n + 1);
			
			player_sprite.trajectory_movement.nextPos.x = lanes[player_sprite.current_lane];
			if (pl_dst.type != NONE)
			{
				player_sprite.trajectory_movement.nextPos.y -= jump_height;
				beat_n++;
			}
			
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
				
				var peg_prev_0 = jumping_points[prev_0_n];
				var peg_prev_1 = jumping_points[prev_1_n];
				var peg_prev_2 = jumping_points[prev_2_n];
				var peg_current_0 = jumping_points[current_0_n];
				var peg_current_1 = jumping_points[current_1_n];
				var peg_current_2 = jumping_points[current_2_n];
				
				peg_current_0.pos.y = peg_prev_0.pos.y - jump_height;
				peg_current_1.pos.y = peg_prev_1.pos.y - jump_height;
				peg_current_2.pos.y = peg_prev_2.pos.y - jump_height;
				
				var platform_prev_0 = platform_points[prev_0_n];
				var platform_prev_1 = platform_points[prev_1_n];
				var platform_prev_2 = platform_points[prev_2_n];
				var platform_current_0 = platform_points[current_0_n];
				var platform_current_1 = platform_points[current_1_n];
				var platform_current_2 = platform_points[current_2_n];
				
				platform_current_0.type = NONE;
				platform_current_1.type = NONE;
				platform_current_2.type = NONE;
				
				platform_current_0.pos.y = platform_prev_0.pos.y - jump_height;
				platform_current_1.pos.y = platform_prev_1.pos.y - jump_height;
				platform_current_2.pos.y = platform_prev_2.pos.y - jump_height;
			}
		}
	}
	
	function get_platform(x:Int, y:Int) : Platform
	{
		if (x < 1 || x > 3) return null;
		if (y < 0) return null;
		var current = (platform_points.length + (y * num_internal_lanes + (x - 1))) % platform_points.length;
		return platform_points[current];
	}
	
	function put_platform() : Void
	{
		//trace('putting platform at $mouse_index_x, ${max_tile - mouse_index_y}' );
		var pl = get_platform(mouse_index_x, max_tile - mouse_index_y);
		
		if (pl == null)
		{
			trace('null platform');
			return;
		}
		
		if (pl.type != NONE)
		{
			return;
		}
		
		pl.type = current_platform_type;
		
		current_platform_type = next_platform_type;
		next_platform_type = get_next_platform_type();
		
		mouse_platform.type = current_platform_type;
		next_platform.type = next_platform_type;
	}
	
	function switch_platform()
	{
		var t = current_platform_type;
		current_platform_type = next_platform_type;
		next_platform_type = t;
		
		mouse_platform.type = current_platform_type;
		next_platform.type = next_platform_type;
	}
	
	function get_next_platform_type() : PlatformType
	{
		return Type.createEnumIndex(PlatformType, Luxe.utils.random.int(1, Type.getEnumConstructs(PlatformType).length));
	}
}
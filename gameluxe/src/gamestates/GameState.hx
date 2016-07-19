package gamestates;

import data.BackgroundGroup;
import data.GameInfo;
import components.GameCameraComponent;
import entities.Avatar;
import entities.Background;
import entities.BeatManager;
import entities.CollectableManager;
import entities.DamageFeedback;
import entities.Level;
import entities.Platform;
import entities.PlatformPeg;
import entities.PlatformType;
import entities.Score;
import luxe.Camera;
import luxe.Color;
import luxe.Input.Key;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Rectangle;
import luxe.Text;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.easing.Back;
import mint.Label;
import mint.Panel;
import phoenix.Batcher;
import ui.MintLabelPanel;

import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Input;
import luxe.Sprite;
import luxe.Scene;
import phoenix.Texture;

import mint.types.Types.TextAlign;

typedef MintTextAlign = mint.types.Types.TextAlign;

typedef GameOverReasonEvent = {
	msg : String,
}

typedef GameStateOnEnterData = {
	@:optional var play_audio_loop : Bool; 
}

/**
 * ...
 * @author 
 */
class GameState extends State
{	
	private var game_info : GameInfo;
	public var scene : Scene;
	
	private var level: Level;
	
	var parcel : Parcel;
	
	var fader_overlay_sprite : Sprite;
	var background_groups : Array<BackgroundGroup>;
	var background : Background;

	public static var player_sprite: Avatar;
	
	private var absolute_floor : Sprite;
	
	var lanes : Array<Float>;
	
	var jumping_points : Array<PlatformPeg>;
	var platform_points : Array<Platform>;
	var collectable_manager : CollectableManager;
	
	var lane_start : Float;
	
	var sky_uv : Rectangle;
	
	var level_rect : Rectangle;
	
	var num_internal_lanes : Int;
	var num_all_lanes : Int;
	var num_peg_levels : Int;
	
	var beat_n : Int;
	var beat_index_y : Int;
	var beat_bottom_y : Int;
	var beat_start_wrap : Int;
	var mouse_platform : Platform;
	var mouse_pos : Vector;
	var mouse_index_x : Int;
	var mouse_index_y : Int;
	var max_tile : Int;
	var starting_y : Float;
	
	var current_platform_type : PlatformType;
	var next_platform_types : Array<PlatformType>;
	var next_platforms : Array<Platform>;
	var last_next_platform_index : Int;
	
	/// Text
	var processing_text : Text;
	var debug_text : Text;
	var txt_poppings : Array<Text>;
	var current_txt_popping : Int;
	
	public var is_pause (default, null) = false;
	/// pause panel
	var pause_panel : Panel;
	
	//Game over panel.
	public var is_game_over (default, null) = false;
	var game_over_panel : Panel;
	var game_over_score_label : Label;
	var game_over_death_label : Label;
	
	// UI
	var ui_bg : Sprite;
	var list_of_platforms_bg : Sprite;
	var ui_distance_panel : MintLabelPanel;
	var ui_hp_remaining : MintLabelPanel;
	var ui_score : MintLabelPanel;
	
	// Score
	var score_component : entities.Score;
	
	var restart_signal = false;
	var state_change_menu_signal = false;
	
	// Damage
	var damage_feedback : DamageFeedback;
	
	var event_id : Array<String>;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		player_sprite = null;
		scene = null;
		
		num_internal_lanes = 3;
		num_all_lanes = 5;
		num_peg_levels = 12;
		
		var aspect_ratio = Main.ref_window_aspect();
		var level_height = Main.global_info.ref_window_size_y;
		var level_width = level_height / aspect_ratio;
		
		level_rect = new Rectangle((Main.global_info.ref_window_size_x - level_width) / 2.0, 0, level_width, level_height);
	}
	
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{			
		if ( e.keycode == Key.escape && is_pause == false)
		{
			pause();
		}
		else if ( e.keycode == Key.escape && is_pause == true)
		{
			unpause();
		}
		
		/*
		if ( e.keycode == Key.key_o)
		{
			trace("game over");
			reset_state();
		}
		*/
	}
	
	function pause()
	{
		is_pause = true;
		activate_pause_panel();
		Luxe.events.fire("game.pause");
	}
	
	function unpause()
	{
		is_pause = false;
		deactivate_pause_panel();
		Luxe.events.fire("game.unpause");
	}
	
	function reset_state()
	{
		onleave({});
		onenter({});
	}
	
	override function onleave<T>(d:T)
	{
		trace("Exiting game");
		
		is_pause = false;
		
		// events
		for (i in 0...event_id.length)
		{
			var res = Luxe.events.unlisten(event_id[i]);
		}
		event_id = null;
		
		// reset and remove all tweenign that is current in-flight
		Actuate.reset();
		
		//De-register events.
		score_component.unregister_listeners();
		                     
		Main.beat_manager.leave_game_state();
		Main.canvas.destroy_children();

		player_sprite = null;
		background = null;
		level = null;

		scene.empty();
		scene.destroy();
		scene = null;
		
		parcel = null;
	}
	
	function calc_lane_width() : Float
	{
		return level_rect.w * 1.25;
	}
	
	function calc_lanes_distance() : Float
	{
		return lanes[2] - lanes[1];
	}
	
	override function onenter<T>(d:T)
	{
		trace("Entering game");
		var restart_signal = false;
		var state_change_menu_signal = false;
		
		var on_enter_data = cast d;
		
		// events
		event_id = new Array<String>();
		event_id.push(Luxe.events.listen("Level.Start", OnLevelStart ));
		event_id.push(Luxe.events.listen("player_move_event", OnPlayerMove ));
		event_id.push(Luxe.events.listen("player_respawn_end", on_player_respawn_end ));
		event_id.push(Luxe.events.listen("platform_time_out", on_platform_time_out ));
		event_id.push(Luxe.events.listen("audio_track_finished", on_audio_track_finished ));
		event_id.push(Luxe.events.listen("player_damage", on_player_damage));
		event_id.push(Luxe.events.listen("kill_player", trigger_game_over));
		event_id.push(Luxe.events.listen("add_score", add_score));
		event_id.push(Luxe.events.listen("add_multiplier", add_multiplier));
		
		Main.load_parcel(parcel, "assets/data/game_state_parcel.json", on_parcel_loaded);
		
		scene = new Scene("GameScene");
		fader_overlay_sprite = Main.create_transition_sprite(scene);
				
		var lane_width = calc_lane_width();
		
		lane_start = -0.5 * lane_width / num_all_lanes;
		lanes = new Array<Float>();
		lanes.push(lane_start + 0.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 1.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 2.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 3.0 * lane_width / num_all_lanes);
		lanes.push(lane_start + 4.0 * lane_width / num_all_lanes);
		
		lanes[0] -= lane_width / num_all_lanes;
		lanes[4] += lane_width / num_all_lanes;
		
		Main.beat_manager.play_audio_loop = (on_enter_data != null) ? on_enter_data.play_audio_loop : true;
		Main.beat_manager.enter_game_state();
		
		level = new Level({batcher_ui : Main.batcher_ui}, new Vector(lanes[2], 0));
						
		jumping_points = new Array<PlatformPeg>();
		platform_points = new Array<Platform>();
		
		var platform_size = new Vector(calc_lanes_distance(), 1); // height will be filled later once the texture is loaded
		
		for (i in 0...num_internal_lanes * num_peg_levels)
		{
			var peg = new PlatformPeg(scene, game_info, i);
			peg.visible = false;
			jumping_points.push(peg);
			
			var platform = new Platform({ scene: scene, game_info: game_info, n:i, type:NONE, size:platform_size.clone() });
			platform.visible = false;
			platform_points.push(platform);
		}
		
		collectable_manager = new CollectableManager(this, lanes, level.beat_height);
		
		score_component = new Score();
		
		player_sprite = new Avatar(lanes[2], {
			name: 'Player',
			texture: Luxe.resources.texture("assets/image/aviator_sprite_color.png"),
			pos: Luxe.screen.mid,
			size: new Vector(140, 140),
			scene: scene,
		});
		player_sprite.current_lane = 2;
		player_sprite.visible = false;
		
		absolute_floor = new Sprite({
			name: 'BottomFloor',
			//texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			//uv: game_info.spritesheet_elements['ground_cake.png'],
			pos: new Vector(Luxe.screen.width / 2.0, 0),
			//size: new Vector(game_info.spritesheet_elements['ground_cake.png'].w, game_info.spritesheet_elements['ground_cake.png'].h),
			scene: scene,
		});
		absolute_floor.visible = false;
		
		connect_input();
		
		mouse_platform = new Platform({
			scene: scene, 
			game_info: game_info, 
			n:num_internal_lanes * num_peg_levels + 1, 
			type:NONE, 
			size:platform_size.clone(),
			color: new Color(1.0, 1.0, 1.0, 0.5)
		});
		
		ui_bg = Main.create_background(scene);
		
		ui_distance_panel = new MintLabelPanel({
			x: 305, y: 55, w: 125, h: 65, 
			text: "Distance Traveled"
		});
		
		ui_score = new MintLabelPanel({
			x: 305, y: 180, w: 125, h: 65, 
			text: "Score"
		});
		
		ui_hp_remaining = new MintLabelPanel({
			x: 305, y: 300, w: 125, h: 85, 
			text: "Lives",
			text_size: 32
		});
		
		next_platforms = new Array<Platform>();
		
		var platform_scale = 0.7;
		var distance_scale = 0.93;
		for (i in 0...4)
		{
			next_platforms.push(new Platform({
				scene: scene, 
				game_info: game_info, 
				n:num_internal_lanes * num_peg_levels + 2 + i, 
				type: CENTER(1), 
				batcher: Main.batcher_ui,
				pos: new Vector(970 + 40, 200 + i * Platform.max_size.y * distance_scale),
				size: Platform.max_size,
				origin: new Vector(0,0),
				depth: 10 + i,
			}));
			next_platforms[next_platforms.length - 1].scale.set_xy(platform_scale, platform_scale);
			next_platforms[next_platforms.length - 1].eternal = true;
			next_platforms[next_platforms.length - 1].visible = false;
		}
		last_next_platform_index = next_platforms.length - 1;
		
		list_of_platforms_bg = new Sprite({
			pos: new Vector(970,200),
			origin: new Vector(0, 0),
			name: 'list_of_platforms_bg',
			scene:scene,
			texture: Luxe.resources.texture("assets/image/ui/list_of_platforms.png"),
			batcher: Main.batcher_ui,
			depth: 20,
			visible: false,
		});
		
		mouse_pos = new Vector();
		
		/*
		debug_text = new Text({
			pos: new Vector(10, 10),
			text: "",
			color: new Color(120/255.0, 120/255.0, 120/255.0),
			point_size: 18,
			scene: scene,
		});
		*/
		
		damage_feedback = new DamageFeedback(scene);
		
		txt_poppings = new Array<Text>();
		for (i in 0...4)
		{
			txt_poppings.push(new Text({
				font: Luxe.resources.font("assets/image/font/later_on.fnt"),
				text: "",
				point_size: 48,
				pos: new Vector(0, 0),
				scene: scene,
				color: new Color(1, 1, 1, 1),
				outline: 0,
				glow_amount: 0,
			}));
			txt_poppings[txt_poppings.length - 1].visible = false;
		}
		current_txt_popping = 0;
	}
	
	function on_player_damage(e)
	{
		Luxe.camera.shake(10.0);
		
		damage_feedback.visual_flashing_comp.activate();
		Luxe.timer.schedule(0.3, function(){
			damage_feedback.visual_flashing_comp.deactivate();
		});
	}
	
	function on_audio_track_finished(e)
	{
		fader_overlay_sprite.visible = true;
		fader_overlay_sprite.color.a = 0;
		Actuate.tween(fader_overlay_sprite.color, 3.0, {a:1}).onComplete(function() {
			machine.set("ScoreState");
		});
	}
	
	function on_parcel_loaded( p: Parcel )
	{
		create_pause_panel();
		create_game_over_panel();
		create_background_groups();
		
		fader_overlay_sprite.visible = true;
		fader_overlay_sprite.color.a = 1;
		Actuate.tween(fader_overlay_sprite.color, 3.0, {a:0}).onComplete(function() {
			fader_overlay_sprite.visible = false;			
			// fire level.start
			level.OnAudioLoad({});
		});
		
		// initialize platform
		var tex = Luxe.resources.texture('assets/image/platforms/platform_straight02.png');
		absolute_floor.texture = tex;
		absolute_floor.size = new Vector( calc_lanes_distance() * num_internal_lanes,  tex.height);
	}
	
	function on_player_respawn_end(e)
	{
		// reset gameplay platform
		for (pl in platform_points)
		{
			pl.type = NONE;
			pl.eternal = false;
			pl.stepped_on_by_player = false;
		}
		
		for (pl in [get_platform(1, beat_n), get_platform(2, beat_n), get_platform(3, beat_n)])
		{
			pl.type = CENTER(Platform.get_random_center_type());
			pl.visible = false;
			pl.eternal = true;
			pl.stepped_on_by_player = true;
		}
	}
	
	function on_platform_time_out(e:PlatformTimeoutEvent)
	{
		if ( player_sprite.pos.equals( e.pos ) )
		{
			trace("player need to fall");
			Luxe.events.fire("player_move_event", { interval: BeatManager.jump_interval, falling: true }, false );
		}
	}
	
	override function update(dt:Float) 
	{
		// state control
		if (restart_signal)
		{
			restart_signal = false;
			reset_state();
		}
		else if (state_change_menu_signal)
		{
			state_change_menu_signal = false;
			machine.set("MenuState");
			return;
		}
		
		
		if (level.can_put_platforms && !player_sprite.respawning)
		{
			if (Luxe.input.inputpressed("put_platform"))
			{
				//trace("Putting platform!");
				put_platform();
			}
			else if (Luxe.input.inputpressed("switch_platform"))
			{
				//trace("Switching platform!");
				switch_platform();
			}
			
			if (Luxe.input.keypressed(Key.key_1))
			{
				current_platform_type = LEFT;
				mouse_platform.type = current_platform_type;
			}
			else if (Luxe.input.keypressed(Key.key_2))
			{
				current_platform_type = CENTER(Platform.get_random_center_type());
				mouse_platform.type = current_platform_type;
			}
			else if (Luxe.input.keypressed(Key.key_3))
			{
				current_platform_type = RIGHT;
				mouse_platform.type = current_platform_type;
			}
		}
		
		if (player_out_of_bound() && !player_sprite.respawning)
		{
			trace("need player respawn here " + player_sprite.pos.y);
			
			player_sprite.num_lives -= 1;
			if (player_sprite.num_lives <= 0)
			{
				// this will finish the game
				on_audio_track_finished({});
			}
			
			// damage feedback
			Luxe.events.fire("player_damage");
			
			// place player
			beat_n = beat_bottom_y + 2;
			player_sprite.current_lane = 2;
			var respawn_pos_x = lanes[player_sprite.current_lane];
			var respawn_pos_y = -(beat_n) * level.beat_height;
			player_sprite.respawn_begin(new Vector(respawn_pos_x, respawn_pos_y));
			
			// place absolute platform
			absolute_floor.visible = true;
			absolute_floor.pos.x = lanes[2];
			absolute_floor.pos.y = respawn_pos_y;// + absolute_floor.size.y / 2.0;
			// reset gameplay platform
			var j = 0;
			for (i in 0...platform_points.length)
			{
				var platform = platform_points[i];
				platform.type = NONE;
				platform.stepped_on_by_player = false;
				if (platform.pos.y == -(beat_n) * level.beat_height && test_internal_platform(platform.pos.x))
				{
					platform.type = CENTER(Platform.get_random_center_type());
				}
				
				platform.visible = false;
			}
			
			Main.beat_manager.on_player_respawn_begin();
		}
		
		// check if the plaform that player currently on still existed
		for (i in 0...platform_points.length)
		{
			var platform = platform_points[i];
			if (platform.type == NONE)
			{
				on_platform_time_out({ pos: platform.pos });
			}
		}
		
		//mouse_index_x = Std.int(Math.max(1, Math.min(3, Math.fround((mouse_pos.x) / (lanes[2] - lanes[1])))));
		var lanes_distance = calc_lanes_distance();
		max_tile = Math.round( (Main.global_info.ref_window_size_y/2.0 - Luxe.camera.pos.y) / level.beat_height);
		mouse_index_x = Std.int(Math.min(3, Math.max(1, Math.round((mouse_pos.x  + lanes_distance * 0.5) / lanes_distance))));
		beat_index_y = Math.round((starting_y - mouse_pos.y) / level.beat_height);
		mouse_index_y = Std.int(Math.max(beat_index_y, 0));
		var old_beat_bottom_y = beat_bottom_y;
		beat_bottom_y = Math.round((starting_y - Luxe.camera.pos.y - Main.global_info.ref_window_size_y) / level.beat_height);
		var mouse_platform_x = lane_start + mouse_index_x * lanes_distance;
		var mouse_platform_y = (starting_y - mouse_index_y * level.beat_height);
		mouse_platform.pos.set_xy(mouse_platform_x, mouse_platform_y);
		
		if (beat_bottom_y >= beat_start_wrap && beat_bottom_y > old_beat_bottom_y)
		{
			var n = beat_bottom_y - beat_start_wrap;
			var l = jumping_points.length;
			
			var current_0_n = (n * num_internal_lanes + 0) % l;
			var current_1_n = (n * num_internal_lanes + 1) % l;
			var current_2_n = (n * num_internal_lanes + 2) % l;
			
			var peg_current_0 = jumping_points[current_0_n];
			var peg_current_1 = jumping_points[current_1_n];
			var peg_current_2 = jumping_points[current_2_n];
			
			peg_current_0.pos.y = peg_current_0.pos.y - num_peg_levels * level.beat_height;
			peg_current_1.pos.y = peg_current_1.pos.y - num_peg_levels * level.beat_height;
			peg_current_2.pos.y = peg_current_2.pos.y - num_peg_levels * level.beat_height;
			
			var platform_current_0 = platform_points[current_0_n];
			var platform_current_1 = platform_points[current_1_n];
			var platform_current_2 = platform_points[current_2_n];
			
			platform_current_0.type = NONE;
			platform_current_1.type = NONE;
			platform_current_2.type = NONE;
			
			platform_current_0.eternal = false;
			platform_current_1.eternal = false;
			platform_current_2.eternal = false;
			
			platform_current_0.stepped_on_by_player = false;
			platform_current_1.stepped_on_by_player = false;
			platform_current_2.stepped_on_by_player = false;
			
			//trace('Moving ($n) over ($current_0_n, $current_1_n, $current_2_n), new height is ${ platform_current_0.pos.y - num_peg_levels * level.beat_height}');
			
			platform_current_0.pos.y = platform_current_0.pos.y - num_peg_levels * level.beat_height;
			platform_current_1.pos.y = platform_current_1.pos.y - num_peg_levels * level.beat_height;
			platform_current_2.pos.y = platform_current_2.pos.y - num_peg_levels * level.beat_height;
		}
		
		//trace('texture size is (${ui_bg.size.x}, ${ui_bg.size.y}), origin is (${ui_bg.origin.x}, ${ui_bg.origin.y})');
		
		//debug_text.pos.y = Luxe.camera.pos.y + 10;
		//debug_text.text = 'player (${player_sprite.current_lane}, $beat_n) / cursor (${mouse_index_x}, $mouse_index_y) / index ${(platform_points.length + ((mouse_index_y) * num_internal_lanes + (mouse_index_x - 1))) % platform_points.length} / beat_bottom_y $beat_bottom_y \ncamera (${Luxe.camera.pos.x}, ${Luxe.camera.pos.y}) / maxtile $max_tile / mouse (${mouse_pos.x}, ${mouse_pos.y})\n mouse_platform (${mouse_platform_x}, ${mouse_platform_y})';
		
		// update UI elements
		var travelled_distance = beat_n;
		ui_distance_panel.set_text('Travelled Distance\n${travelled_distance}');
		
		var score = score_component.get_score();
		ui_score.set_text('score\n${score}');
		
		ui_hp_remaining.set_text('Lives\n${player_sprite.num_lives}');
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
		var w = Luxe.camera.screen_point_to_world(mouse_pos);
		mouse_pos.set_xy(w.x, w.y);
	}
	
	function OnLevelStart( e:LevelStartEvent )
	{
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
				platform.type = CENTER(Platform.get_random_center_type());
				platform.visible = false;
				platform.eternal = true;
			}
			
			j++;
			if (j == 3)
			{
				first_line = false;
				j = 0;
				peg_y -= level.beat_height;
			}
		}
		beat_n = 0;
		beat_start_wrap = 0;
		
		absolute_floor.visible = true;
		absolute_floor.pos.x = lanes[2];
		absolute_floor.pos.y = starting_y;// + absolute_floor.size.y / 2.0;
		
		current_platform_type = get_next_platform_type();
		
		if (next_platform_types == null)
		{
			next_platform_types = new Array<PlatformType>();
		}
		
		for (i in 0...next_platform_types.length)
		{
			next_platform_types.pop();
		}
		
		for (i in 0...next_platforms.length)
		{
			var next_pl = get_next_platform_type();
			next_platform_types.push(next_pl);
			next_platforms[i].type = next_pl;
			next_platforms[i].eternal = true;
			//next_platforms[i].visible = true;
		}
		
		mouse_platform.type = current_platform_type;
		//[Aik] test platform
		mouse_platform.eternal = true;
		
		//Collectable Manager
		collectable_manager.CreateFirstGroup();
		
		//Listen for collectable events.
		score_component.register_listeners();
		
		
		list_of_platforms_bg.visible = true;
		
		player_sprite.gamecamera._highest_y = starting_y - 2 * level.beat_height;
	}
	
	function OnPlayerMove( e:BeatEvent )
	{
		var pl_src = get_platform(player_sprite.current_lane, beat_n);
		var pl_dst = null;
		
		var platform_destination_x = player_sprite.current_lane;
		var platform_destination_y = beat_n;
		var outside_lanes_left = false;
		var outside_lanes_right = false;
		var fall_below = false;
		
		//trace('player is now at ${player_sprite.current_lane}, $beat_n' );
		//trace('cursor is now at ${mouse_index_x}, $mouse_index_y' );
		
		if (pl_src == null)
		{
			trace('player is standing outside lanes. Game over');
			
			// TODO: GAME OVER Set a timer here and wait 2 seconds before restart
			trace("ply:" + player_sprite.pos.y);
			trace("bound " + -(beat_bottom_y - 2) * level.beat_height);
			trace(beat_bottom_y + " n " + beat_n);
		}
		else
		{
			var pl_src_type = pl_src.type;
			
			//var s_debug = 'jumping from platform (${player_sprite.current_lane}, $beat_n) $pl_src_type to ';
			
			if (e.falling == false)
			{
				platform_destination_x += switch (pl_src_type)
				{
					case NONE: 0;
					case CENTER(_): 0;
					case LEFT: -1;
					case RIGHT: 1;
				}
				platform_destination_y += 1;
			}
			else
			{
				platform_destination_y -= 1;
			}
			
			outside_lanes_left = platform_destination_x < 1;
			outside_lanes_right = platform_destination_x > 3;
			
			if (!outside_lanes_left && !outside_lanes_right)
			{
				do
				{
					pl_dst = get_platform(platform_destination_x, platform_destination_y);
					
					if (pl_dst.type == NONE)
					{
						platform_destination_y -= 1;
						
						if (platform_destination_y < beat_bottom_y)
						{
							fall_below = true;
							pl_dst = null;
							platform_destination_y -= 2;
							trace('fell below!'); // TODO: GAME OVER Set a timer here and wait 2 seconds before restart
						}
					}
				} while ((pl_dst == null || pl_dst.type == NONE) && !fall_below);
				
				if (pl_dst != null)
				{
					if (pl_dst.stepped_on_by_player)
					{
						Luxe.events.fire("reset_multiplier", null);
						
						// Reset stepped on by player for all platforms
						for (pl in platform_points)
						{
							pl.stepped_on_by_player = false;
						}
						pl_dst.stepped_on_by_player = true;
					}
					else
					{
						pl_dst.stepped_on_by_player = true;
						Luxe.events.fire("add_multiplier", null);
					}
				}
				//s_debug += '($platform_destination_x, $platform_destination_y) beat_n is $beat_n';
			}
			else
			{
				trace('fell out!');
				
				platform_destination_y = beat_bottom_y-2;
			}
			
			//if (pl_dst == null)
			//{
			//	s_debug += ' the abyss';
			//}
			//else
			//{
			//	s_debug += ' destination ($platform_destination_x, $platform_destination_y) ${pl_dst.type}';
			//}
			//trace(s_debug);
			
			player_sprite.current_lane = platform_destination_x;
			beat_n = Std.int(Math.max(0, platform_destination_y));
			
			//trace(s_debug);
			
			player_sprite.trajectory_movement.nextPos.x = lanes[player_sprite.current_lane];
			player_sprite.trajectory_movement.nextPos.y = - platform_destination_y * level.beat_height;
		}
	}
	
	
	function test_internal_platform( pos_x:Float ) : Bool
	{
		return pos_x > lanes[0] && pos_x < lanes[num_all_lanes - 1];
	}
	
	function player_out_of_bound() : Bool
	{
		return player_sprite.pos.y >= -(beat_bottom_y-2) * level.beat_height;
	}
	
	function get_platform(x:Int, y:Int) : Platform
	{
		if (x < 1 || x > 3)
		{
			//trace("fail_x");
			return null;
		}
		if (y < 0)
		{
			//trace("fail_y");
			return null;
		}
		var current = (platform_points.length + ((y) * num_internal_lanes + (x - 1))) % platform_points.length;
		return platform_points[current];
	}
	
	function put_platform() : Void
	{
		var pl = get_platform(mouse_index_x, mouse_index_y);
		
		if (pl == null)
		{
			//trace('null platform');
			return;
		}
		
		if (pl.type != NONE)
		{
			return;
		}
		
		pl.type = current_platform_type;
		
		current_platform_type = next_platform_types.pop();
		next_platform_types.unshift(get_next_platform_type());
		
		mouse_platform.type = current_platform_type;
		
		var color = new Color(1, 1, 1, 1);
		next_platforms[next_platforms.length - 1].color = color;
		Actuate.tween(color, 0.1, { a: 0 }, true).onComplete(function ()
		{
			next_platforms[next_platforms.length - 1].type = next_platform_types[next_platform_types.length - 1];
			color.a = 1;
			
		});
		
		for (i in 0...next_platforms.length - 1)
		{
			//next_platforms[i].type = next_platform_types[i];
			var starting_pos_y = next_platforms[i].pos.y;
			var final_pos_y = starting_pos_y + Platform.max_size.y * next_platforms[i].scale.y;
			Actuate.tween(next_platforms[i].pos, 0.1, { y: final_pos_y }, true).onComplete(function ()
			{
				next_platforms[i].pos.y = starting_pos_y;
				next_platforms[i].type = next_platform_types[i];
			});
		}
	}
	
	function switch_platform()
	{
		var t = current_platform_type;
		current_platform_type = next_platform_types[last_next_platform_index];
		next_platform_types[last_next_platform_index] = t;
		
		mouse_platform.type = current_platform_type;
		next_platforms[last_next_platform_index].type = next_platform_types[last_next_platform_index];
	}
	
	var random_next_platforms : Array<PlatformType>;
	var random_next_platforms_index : Int;
	
	function get_next_platform_type() : PlatformType
	{
		if (random_next_platforms == null)
		{
			random_next_platforms = new Array<PlatformType>();
			random_next_platforms.push(CENTER(1));
			random_next_platforms.push(CENTER(2));
			random_next_platforms.push(LEFT);
			random_next_platforms.push(RIGHT);
			
			random_next_platforms_index = 0;
			
			shuffle(random_next_platforms);
		}
		
		var platform_type = random_next_platforms[random_next_platforms_index];
		
		random_next_platforms_index = (random_next_platforms_index + 1) % random_next_platforms.length;
		
		if (random_next_platforms_index % random_next_platforms.length == 0)
		{
			shuffle(random_next_platforms);
		}
		
		return platform_type;
	}
	
	function activate_pause_panel()
	{
		pause_panel.visible = true;
	}
	
	function deactivate_pause_panel()
	{
		pause_panel.visible = false;
	}
	
	function create_background_groups()
	{
		var json = Luxe.resources.json("assets/data/background_groups.json").asset.json;
		
		background_groups = new Array<BackgroundGroup>();
		var groups : Array<Dynamic> = json.groups;
		for (i in 0...groups.length)
		{
			//trace(groups[i]);
			var group = new BackgroundGroup();
			group.load_group(groups[i]);
			background_groups.push(group);
		}
		
		background = new Background({scene : scene});
		background.background_group = background_groups[0];
	}
	
	function create_pause_panel()
	{
		pause_panel = new mint.Panel({
			parent: Main.canvas,
			name: 'panel_pause',
			mouse_input: true,
			x: 595, y: 300, w: 250, h: 300,
		});
		pause_panel.visible = false;
		
		var title = new mint.Label({
			parent: pause_panel, name: 'label',
			mouse_input:false, x:0, y:0, w:250, h:100, text_size: 32,
			align: MintTextAlign.center, align_vertical: MintTextAlign.center,
			text: "Game Pause",
		});
		
		var button = new mint.Button({
            parent: pause_panel,
            name: 'button',
            text: "Resume",
			x: 61, y: 110, w: 128, h: 32,
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } }
        });
		button.onmouseup.listen(
			function(e,c) 
			{
				unpause();
			}
		);
		
		var button1 = new mint.Button({
            parent: pause_panel,
            name: 'button',
            text: "Restart",
			x: 61, y: 152, w: 128, h: 32,
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } }
        });
		button1.onmouseup.listen(
			function(e,c) 
			{
				restart_signal = true;
			}
		);
		
		var button2 = new mint.Button({
            parent: pause_panel,
            name: 'button',
            text: "Main Menu",
			x: 61, y: 152+42, w: 128, h: 32,
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } }
        });
		button2.onmouseup.listen(
			function(e,c) 
			{
				state_change_menu_signal = true;
				//reset_state();
			}
		);
	}
	
		
	public function get_bottom_y()
	{
		return beat_bottom_y;
	}
	
	public function get_max_tile()
	{
		return max_tile;
	}
	
	//Game Over state - SM	
	public function create_game_over_panel()
	{
		game_over_panel = new mint.Panel({
			parent: Main.canvas,
			name: 'game_over_panel',
			mouse_input: true,
			x: 465, y: 300, w: 500, h: 400,
		});
		game_over_panel.visible = false;
		
		var title = new mint.Label({
			parent: game_over_panel, name: 'label',
			mouse_input:false, x:0, y:0, w:500, h:100, text_size: 32,
			align: MintTextAlign.center, align_vertical: MintTextAlign.center,
			text: "Game Over",
		});

		game_over_death_label = new mint.Label({
			parent: game_over_panel, name: 'label',
			mouse_input:false, x:0, y:50, w:500, h:100, text_size: 32,
			align: MintTextAlign.center, align_vertical: MintTextAlign.center,
			text: "You died",
		});
		
		
		game_over_score_label = new mint.Label({
			parent: game_over_panel, name: 'label',
			mouse_input:false, x:0, y:120, w:500, h:100, text_size: 32,
			align: MintTextAlign.center, align_vertical: MintTextAlign.center,
			text: "Score: " + score_component.get_score(),
		});
		
		var button1 = new mint.Button({
            parent: game_over_panel,
            name: 'button',
            text: "Restart",
			x: 50, y: 200, w: 400, h: 32,
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } }
        });
		button1.onmouseup.listen(
			function(e,c) 
			{
				restart_signal = true;
			}
		);
		
		var button2 = new mint.Button({
            parent: game_over_panel,
            name: 'button',
            text: "Main Menu",
			x: 50, y: 200+42, w: 400, h: 32,
            text_size: 14,
            options: { label: { color:new Color().rgb(0x9dca63) } }
        });
		button2.onmouseup.listen(
			function(e,c) 
			{
				state_change_menu_signal = true;
			}
		);
	}
	
	public function activate_game_over_panel()
	{
		game_over_panel.visible = true;
	}
	
	public function deactivate_game_over_panel()
	{
		game_over_panel.visible = false;
	}
	
	function trigger_game_over(e : GameOverReasonEvent)
	{
		trace("Game Over! Caused by: " + e.msg);
		pause();
		
		game_over_death_label.text =  "You died by " + e.msg;
		game_over_score_label.text = "Score: " + score_component.get_score();
		activate_game_over_panel();
	}
	
	private function shuffle(a:Array<PlatformType>)
	{
		if (a.length < 2)
		{
			return;
		}
		
		var times = 3;
		for (k in 0...times)
		{
			for (i in 0...a.length)
			{
				for (j in (i+1)...a.length)
				{
					if (Luxe.utils.random.bool())
					{
						var t = a[i];
						a[i] = a[j];
						a[j] = t;
					}
				}
			}
		}
	}
	
	function add_score(e:ScoreEvent)
	{
		create_score_popping(e.val);
	}
	
	function add_multiplier(e:ScoreEvent)
	{
		create_multiplier_popping(score_component.current_multiplier);
	}
	
	function create_score_popping( val : Int )
	{
		var s = (val > 0 ? "+" : "-") + Std.string(val);
		
		var txt_obj = txt_poppings[current_txt_popping];
		txt_obj.text = s;
		txt_obj.pos = player_sprite.pos.clone();
		txt_obj.pos.x -= txt_obj.geom.text_width / 2;
		txt_obj.visible = true;
		txt_obj.color.set(1, 1, 1, 1);
		
		Actuate.tween(txt_obj.pos, 2, {y : player_sprite.pos.y - 96 });
		Actuate.tween(txt_obj.color, 2, {a : 0}).onComplete( function(){
			txt_obj.visible = false;
		});
		
		current_txt_popping = (current_txt_popping + 1) % txt_poppings.length;
	}
	
	function create_multiplier_popping( val : Int )
	{
		if (val <= 1)
		{
			return;
		}
		
		var s = 'x$val combo'; 
		
		var txt_obj = txt_poppings[current_txt_popping];
		txt_obj.text = s;
		txt_obj.pos = player_sprite.pos.clone();
		txt_obj.pos.y -= 30;
		txt_obj.pos.x -= txt_obj.geom.text_width / 2;
		txt_obj.visible = true;
		txt_obj.color.set(1, 1, 1, 1);
		
		Actuate.tween(txt_obj.pos, 2, {y : player_sprite.pos.y - 126 });
		Actuate.tween(txt_obj.color, 2, {a : 0}).onComplete( function(){
			txt_obj.visible = false;
		});
		
		current_txt_popping = (current_txt_popping + 1) % txt_poppings.length;
	}
}
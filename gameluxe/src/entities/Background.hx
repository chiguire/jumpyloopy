package entities;

import data.BackgroundGroup;
import entities.BeatManager.BeatEvent;
import entities.Level.LevelStartEvent;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.Rectangle;
import luxe.Vector;
import luxe.Visual;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.options.VisualOptions;
import phoenix.Texture;
import phoenix.geometry.QuadGeometry;

typedef HVector<T> = haxe.ds.Vector<T>;

/**
 * ...
 * @author Aik
 */
class Background extends Visual
{
	public var background_group : BackgroundGroup;
	
	var tiling_textures : Array<Texture>;
	var transition_textures : Array<Texture>;
	
	var geoms : HVector<QuadGeometry>;
	
	var rect : Rectangle;
	
	var bg_size_x = 0.0;
	var bg_size_y = 0.0;
	
	/// transition_pos (should come from level, data)
	var transition_pos = 1500;
	var transition_pos_counter = 0.0;
	var curr_state = 0;
	
	var transitioning_state = false;
	var transition_geom_id = 0;
	
	var prev_camera_pos_y = Math.NEGATIVE_INFINITY;
	
	var level_start_ev : String;
	
	public function new(options:VisualOptions) 
	{
		super(options);
		// Background don't have to be Visual, fix this later! [Aik]
		visible = false;
		
		tiling_textures = new Array<Texture>();
		transition_textures = new Array<Texture>();
		
		bg_size_x = Main.global_info.ref_window_size_y / Main.ref_window_aspect();
		bg_size_y = Main.global_info.ref_window_size_y;
		
		depth = -1;
		
		rect = new Rectangle(0, 0, 500, bg_size_y);
		
		geoms = new HVector<QuadGeometry>(4);
		for (i in 0...geoms.length)
		{
			var geom = new QuadGeometry({
				x: Main.global_info.ref_window_size_x/2 - bg_size_x/2, y:0 - (i)*Main.global_info.ref_window_size_y, w:bg_size_x, h:bg_size_y,
				batcher: Main.batcher_bg,
				depth: depth
			});
			geoms[i] = geom;
		}
		
		level_start_ev = Luxe.events.listen("Level.Start", on_level_start );
	}
	
	override public function ondestroy() 
	{
		Luxe.events.unlisten(level_start_ev);
		
		for (i in 0...geoms.length) 
			geoms[i].drop();
		
		super.ondestroy();
	}
	
	override public function init() 
	{		
		super.init();
		
		for (i in 0...background_group.tile_textures.length)
		{
			trace(background_group.tile_textures[i]);
			var t0 = Luxe.resources.texture(background_group.tile_textures[i]);
			t0.clamp_s = ClampType.repeat;
			t0.clamp_t = ClampType.repeat;
			var t1 = Luxe.resources.texture(background_group.trans_textures[i]);
			t1.clamp_s = ClampType.repeat;
			t1.clamp_t = ClampType.repeat;
			
			tiling_textures.push(t0);
			transition_textures.push(t1);
		}
		
		for (i in 0...geoms.length)
		{
			geoms[i].texture = tiling_textures[0];
			geoms[i].uv(rect);
		}
		
		//trace(Main.global_info.ref_window_size_y * (geoms.length - 1));
	}
	
	var speed_mul = 1.0;	
	override function onkeyup(e:KeyEvent) 
	{
		super.onkeyup(e);
		
		if (e.keycode == Key.key_d)
		{
			speed_mul = 1.0;
		}
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if(Luxe.input.keydown(Key.key_d)) {
            speed_mul = 50;
        }
		
		if ( prev_camera_pos_y != Math.NEGATIVE_INFINITY )
		{
			var delta_pos = Luxe.camera.pos.y - prev_camera_pos_y;
			prev_camera_pos_y = Luxe.camera.pos.y;
			
			if(curr_state+1 < tiling_textures.length) transition_pos_counter += 10*dt*speed_mul - delta_pos;
			
			if ( transition_pos_counter > transition_pos )
			{			
				transition_start();
				transition_pos_counter = 0;
				
				//trace(curr_state);
			}
			
			// move background
			for (i in 0...geoms.length)
			{
				geoms[i].transform.pos.y -= -10*dt*speed_mul + delta_pos;
			}
		}
		
		
		if (transitioning_state)
		{
			//trace( geoms[transition_geom_id].transform.pos.y );
			if (geoms[transition_geom_id].transform.pos.y > Main.global_info.ref_window_size_y)
			{
				//trace(geoms[transition_geom_id].transform.pos.y);
				transitioning_state = false;
				
				for (i in 0...geoms.length)
				{
					geoms[i].texture = tiling_textures[curr_state];
				}
			}
		}
		
		for (i in 0...geoms.length)
		{
			if (geoms[i].transform.pos.y > Main.global_info.ref_window_size_y) geoms[i].transform.pos.y -= Main.global_info.ref_window_size_y * geoms.length;
		}
	}
	
	function transition_start()
	{
		curr_state++;
		// transition
		var top_pos = 0.0;
		for (i in 0...geoms.length)
		{
			if (geoms[i].transform.pos.y < top_pos)
			{
				top_pos = geoms[i].transform.pos.y;
				transition_geom_id = i;
			}
		}
		
		geoms[transition_geom_id].texture = tiling_textures[curr_state];
		transition_geom_id = (transition_geom_id - 1 + geoms.length) % geoms.length;
		geoms[transition_geom_id].texture = transition_textures[curr_state-1];
		//trace(geoms[transition_geom_id].transform.pos.y);
		
		transitioning_state = true;
	}
	
	function on_level_start( e:LevelStartEvent )
	{
		if ( prev_camera_pos_y == Math.NEGATIVE_INFINITY )
		{
			prev_camera_pos_y = Luxe.camera.pos.y;
			curr_state = 0;
			//transition_start();
		}
	}
}
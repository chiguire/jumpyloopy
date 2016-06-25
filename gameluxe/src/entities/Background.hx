package entities;

import components.BeatManagerVisualizer.HVector;
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
	var tiling_textures : Array<Texture>;
	var transition_textures : Array<Texture>;
	
	var geoms : HVector<QuadGeometry>;
	
	var rect : Rectangle;
	
	var bg_size_x = 0.0;
	var bg_size_y = 0.0;
	
	/// transition_pos (should come from level, data)
	var transition_pos = 30; // test transition at 30 sec
	var transition_pos_counter = 0.0;
	var next_transition = false;
	
	var transitioning_state = false;
	var transition_geom_id = 0;
	
	var prev_camera_pos_y = Math.NEGATIVE_INFINITY;
	
	public function new(options:VisualOptions) 
	{
		super(options);
		
		tiling_textures = new Array<Texture>();
		transition_textures = new Array<Texture>();
		
		bg_size_x = Main.global_info.ref_window_size_y / Main.ref_window_aspect();
		bg_size_y = Main.global_info.ref_window_size_y;
		
		depth = -1;
		
		rect = new Rectangle(0, 0, 500, bg_size_y);
		
		geoms = new HVector<QuadGeometry>(4);
		
		Luxe.events.listen("Level.Start", on_level_start );
	}
	
	override public function init() 
	{		
		super.init();
		
		var base_tex0 = Luxe.resources.texture("assets/image/bg/sky_01_tiling.png");
		base_tex0.clamp_s = ClampType.repeat;
		base_tex0.clamp_t = ClampType.repeat;
		tiling_textures.push(base_tex0);
		
		var base_tex = Luxe.resources.texture("assets/image/bg/space_02_tiling.png");
		base_tex.clamp_s = ClampType.repeat;
		base_tex.clamp_t = ClampType.repeat;
		tiling_textures.push(base_tex);
		
		var trans_tex = Luxe.resources.texture("assets/image/bg/space_01_transition.png");
		base_tex.clamp_s = ClampType.repeat;
		base_tex.clamp_t = ClampType.repeat;
		transition_textures.push(trans_tex);
		
		for (i in 0...geoms.length)
		{
			var geom = new QuadGeometry({
				texture: base_tex0,
				x: Main.global_info.ref_window_size_x/2 - bg_size_x/2, y:0 - i*Main.global_info.ref_window_size_y, w:bg_size_x, h:bg_size_y,
				uv: rect,
				batcher: Main.batcher_bg,
				depth: depth
			});
			geoms[i] = geom;
		}
		
		//trace(Main.global_info.ref_window_size_y * (geoms.length - 1));
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if ( prev_camera_pos_y != Math.NEGATIVE_INFINITY )
		{
			var delta_pos = Luxe.camera.pos.y - prev_camera_pos_y;
			prev_camera_pos_y = Luxe.camera.pos.y;
			
			if(next_transition) transition_pos_counter += dt;
			
			if ( transition_pos_counter > transition_pos )
			{
				transition_start();
				
				transition_pos_counter = 0;
				next_transition = false;
			}
			
			// move background
			for (i in 0...geoms.length)
			{
				geoms[i].transform.pos.y -= delta_pos;
			}
		}
		
		
		if (transitioning_state)
		{
			//trace( geoms[transition_geom_id].transform.pos.y );
			if (geoms[transition_geom_id].transform.pos.y > Main.global_info.ref_window_size_y)
			{
				trace(geoms[transition_geom_id].transform.pos.y);
				transitioning_state = false;
				
				for (i in 0...geoms.length)
				{
					geoms[i].texture = tiling_textures[1];
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
		
		geoms[transition_geom_id].texture = tiling_textures[1];
		transition_geom_id = (transition_geom_id - 1 + geoms.length) % geoms.length;
		geoms[transition_geom_id].texture = transition_textures[0];
		//trace(geoms[transition_geom_id].transform.pos.y);
		
		transitioning_state = true;
	}
	
	function on_level_start( e:LevelStartEvent )
	{
		if ( prev_camera_pos_y == Math.NEGATIVE_INFINITY )
		{
			prev_camera_pos_y = Luxe.camera.pos.y;
			next_transition = true;
		}
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		
	}
}
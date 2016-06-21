package gamestates;

import data.GameInfo;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;

/**
 * ...
 * @author Aik
 */
class LevelSelectState extends State
{
	var game_info : GameInfo;
	
	var parcel : Parcel;
	
	/// deferred state transition
	var change_to = "";

	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function onleave<T>(_value:T)
	{
		Main.canvas.destroy_children();
		
		parcel = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering level select");
		
		// load parcels
		parcel = new Parcel();
		parcel.from_json(Luxe.resources.json("assets/data/level_select_parcel.json").asset.json);
		
		var progress = new ParcelProgress({
            parcel      : parcel,
            background  : new Color(1,1,1,0.85),
            oncomplete  : on_loaded
        });
		
		parcel.load();
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/level_select.json");
		var layout_data = json_resource.asset.json;
		
		var button1 = MenuState.create_button( layout_data.level_0 );
		button1.onmouseup.listen(
			function(e,c) 
			{
				change_to = "GameState";
			}
		);
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (change_to != "")
		{
			machine.set(change_to);
			change_to = "";
		}
	}
}
package gamestates;

import data.GameInfo;
import luxe.Input;
import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.Parcel;
import luxe.Scene;
import luxe.Text;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import ui.MintImageButton;

/**
 * ...
 * @author Simon
 */
class ShopState extends State
{
	private var game_info : GameInfo;
	private var scene : Scene;
	private var title_text : Text;
	var parcel : Parcel;
	var change_to : String;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		scene = null;
		
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
	
	override public function onkeyup(event:KeyEvent) 
	{
		if(event.keycode == Key.escape)
			change_to = "MenuState";
	}
	
	override function onenter<T>(d:T)
	{
		super.onenter(d);
		trace("Entering Shop");
		
		// load parcels
		Main.load_parcel(parcel, "assets/data/shop_parcel.json", on_loaded);
		
		scene = new Scene("ShopScene");
		
		//Luxe.camera.size_mode = luxe.SizeMode.contain;
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		// Background Layer
		Main.create_background(scene);
	}
	
	override public function onleave<T>(d:T) 
	{
		super.onleave(d);
		trace("Leaving Shop. Come again!");
		
		Main.canvas.destroy_children();
		
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
		
		parcel = null;
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/shop.json");
		var layout_data = json_resource.asset.json;

		// UI layer
		var canvas = Main.canvas;
		
		var img : MintImageButton = new MintImageButton("test", new Vector(0, 0), new Vector(40, 40), "assets/image/war-child-logo-home.png");
	}
}
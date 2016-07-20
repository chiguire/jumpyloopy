package gamestates;

import analysis.DFT;
import data.GameInfo;
import data.CharacterGroup;
import data.CharacterGroup;
import luxe.Color;
import luxe.Input;
import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.Parcel;
import luxe.Scene;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import mint.List;
import ui.MintGridPanel;
import ui.MintImageButton;
import ui.MintImageButton_Store;

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
	
	private var character_panel : MintGridPanel;
	private var equipped_character_button : MintImageButton_Store;
	
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
		var background1 = new Sprite({
			texture: Luxe.resources.texture('assets/image/frontend_bg.png'),
			pos: new Vector(720, 450),
			size: new Vector(500, 900),
			scene: scene,
		});

		// UI layer	
		var window_w = 500;
		character_panel = new MintGridPanel(Main.canvas, "Characters", new Vector((Main.canvas.w / 2) - (window_w/2), 200), window_w, 3, 5);
		
		for (i in 0...Main.achievement_manager.character_groups.length)
		{
			var item : MintImageButton_Store = new MintImageButton_Store(character_panel, Main.achievement_manager.character_groups[i].name, 
				new Vector(0, 0), new Vector(143, 193), 
				Main.achievement_manager.character_groups[i].tex_path);
			
			//Check if character was unlocked here as we don't update.
			if (Main.achievement_manager.is_character_unlocked(Main.achievement_manager.character_groups[i].name))
			{
				item.is_unlocked = true;
				
				item.update_button();
			}
			
			if (Main.achievement_manager.selected_character == Main.achievement_manager.character_groups[i].name)
			{
				
				item.is_equipped = true;
			}
				
			character_panel.add_item(item);
		}
	}

}
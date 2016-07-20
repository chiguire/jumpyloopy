package gamestates;

import analysis.DFT;
import data.BackgroundGroup;
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
	var change_to : String = "";
	
	private var equipped_character_button : MintImageButton_Store;
	private var equipped_background_button : MintImageButton_Store;
	
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
		
		scene = new Scene("ShopScene");
		
		// Background Layer
		Main.create_background(scene);
		
		//Luxe.camera.size_mode = luxe.SizeMode.contain;
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		var background1 = new Sprite({
			texture: Luxe.resources.texture('assets/image/frontend_bg.png'),
			pos: new Vector(720, 450),
			size: new Vector(500, 900),
			scene: scene,
		});
		
		// load parcels
		Main.load_parcel(parcel, "assets/data/shop_parcel.json", on_loaded);
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
		trace("Loaded Shop");
		
		// UI layer	
		var window_w = 500;
		var window_y = 200;
		
		var character_panel = new MintGridPanel(Main.canvas, "Characters", 
			new Vector((Main.canvas.w / 2) - (window_w / 2), window_y), window_w, 3, 5);	
			
		for (i in 0...Main.achievement_manager.character_groups.length)
		{
			var item : MintImageButton_Store = new MintImageButton_Store(character_panel, Main.achievement_manager.character_groups[i].name, 
				new Vector(0, 0), new Vector(143, 193), 
				Main.achievement_manager.character_groups[i].tex_path);
			
			//Check if character was unlocked here as we don't update.
			if (Main.achievement_manager.is_character_unlocked(Main.achievement_manager.character_groups[i].name))
				item.is_unlocked = true;
			
			if (Main.achievement_manager.selected_character == Main.achievement_manager.character_groups[i].name)
			{
				item.is_equipped = true;
				equipped_character_button = item;
			}
			
			item.update_button();
			
			item.onmouseup.listen(
			function(e,c) 
			{
				trace("clicked!" + Main.achievement_manager.character_groups[i].name);
				clicked_character(item, Main.achievement_manager.character_groups[i]);
			});
				
			character_panel.add_item(item);
		}
		
		var background_panel = new MintGridPanel(Main.canvas, "Background", 
			new Vector((Main.canvas.w / 2) - (window_w / 2), window_y + character_panel.h), window_w, 3, 5);
			
		for (i in 0...Main.achievement_manager.background_groups.length)
		{
			var item : MintImageButton_Store = new MintImageButton_Store(background_panel, Main.achievement_manager.background_groups[i].name, 
				new Vector(0, 0), new Vector(143, 193), 
				Main.achievement_manager.background_groups[i].tex_path);
			
			//Check if character was unlocked here as we don't update.
			if (Main.achievement_manager.is_background_unlocked(Main.achievement_manager.background_groups[i].name))
				item.is_unlocked = true;
			
			if (Main.achievement_manager.selected_background == Main.achievement_manager.background_groups[i].name)
			{
				item.is_equipped = true;
				equipped_background_button = item;
			}
			
			item.update_button();
			
			item.onmouseup.listen(
			function(e,c) 
			{
				trace("clicked!" + Main.achievement_manager.background_groups[i].name);
				clicked_background(item, Main.achievement_manager.background_groups[i]);
			});
				
			background_panel.add_item(item);
		}
	}

	private function clicked_character(button : MintImageButton_Store, character : CharacterGroup)
	{
		if (Main.achievement_manager.is_character_unlocked(character.name))
		{
			if (Main.achievement_manager.selected_character != character.name)
			{
				if (equipped_background_button != null)
				{
					equipped_character_button.is_equipped = false;
					equipped_character_button.update_button();
				}
				
				button.is_equipped = true;
				button.update_button();
				
				Main.achievement_manager.select_character(character.name);
				equipped_character_button = button;
			}
		}
		else
		{
			if (Main.achievement_manager.current_coins >= character.cost)
			{
				button.is_unlocked = true;
				Main.achievement_manager.unlock_character(character.name);
				Main.achievement_manager.current_coins -= character.cost;
				
				button.update_button();
			}
		}
	}
	
	private function clicked_background(button : MintImageButton_Store, background : BackgroundGroup)
	{
		if (Main.achievement_manager.is_background_unlocked(background.name))
		{
			if (Main.achievement_manager.selected_background != background.name)
			{
				if (equipped_background_button != null)
				{
					equipped_background_button.is_equipped = false;
					equipped_background_button.update_button();
				}
				
				button.is_equipped = true;
				button.update_button();
				
				
				Main.achievement_manager.select_background(background.name);
				equipped_background_button = button;
			}
		}
		else
		{
			if (Main.achievement_manager.current_coins >= background.cost)
			{
				button.is_unlocked = true;
				Main.achievement_manager.unlock_background(background.name);
				Main.achievement_manager.current_coins -= background.cost;
				
				button.update_button();
			}
		}
	}
}
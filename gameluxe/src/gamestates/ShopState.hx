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
import mint.Canvas;
import mint.Image;
import mint.Label;
import mint.List;
import mint.Panel;
import mint.Scroll;
import ui.MintGridPanel;
import ui.MintImageButton;
import ui.MintImageButton_Store;
import ui.MintLabel;
import mint.types.Types.TextAlign;

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
	var canvas : Canvas;
	var coins_text : MintLabel;
	var selected_char_text : MintLabel;
	var selected_background_text : MintLabel;
	
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
		
		canvas = Main.canvas;
		
		scene = new Scene("ShopScene");
		
		// Background Layer
		Main.create_background(scene);
		
		//Luxe.camera.size_mode = luxe.SizeMode.contain;
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		// load parcels
		Main.load_parcel(parcel, "assets/data/shop_parcel.json", on_loaded);
	}
	
	override public function onleave<T>(d:T) 
	{
		super.onleave(d);
		trace("Leaving Shop. Come again!");
		
		canvas.destroy_children();
		
		canvas = null;
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
		
		parcel = null;
		
		// save userdata
		Main.user_data.unlockables = Main.achievement_manager.unlockables;
		Main.save_user_data();
	}
	
	function on_loaded( p: Parcel )
	{		
		trace("Loaded Shop");
		
		// UI layer	
				
		var background1 = new Sprite({
			texture: Luxe.resources.texture("assets/image/ui/unlockables_background.png"),
			pos: new Vector(720, 450),
			size: new Vector(500, 900),
			scene: scene,
		});
		
		var window_y = 150;
		var window_w = 500;
		var window_h = canvas.h - window_y;
		var grid_padding = 10;

		var panel_colour : Color = new Color();
		panel_colour.rgb(0x000000);
		panel_colour.a = 0;
		
		//Main Panel
		var grid_panel : Panel = new Panel({
			parent: canvas,
            name: "panel",
            options: { color:panel_colour },
            x: (canvas.w / 2) - (window_w / 2) + grid_padding, y:window_y + grid_padding, 
			w:window_w - (grid_padding * 2), h: window_h,
			mouse_input: true,
		});

		//Header Text
		coins_text = new MintLabel({
                parent: grid_panel, name: "coins",
				x:0, y:grid_padding, 
				w:grid_panel.w, h:60, 
				text_size: 36,
                text: "coins",
				color : Main.global_info.text_color,
				align: TextAlign.center, align_vertical: TextAlign.center,
            });		
		
		//Back Button	
		var back_button : MintImageButton = new MintImageButton(Main.canvas, "Back", new Vector(470+220, 823), new Vector(62, 38), "assets/image/ui/UI_track_selection_back.png");
		//On click action
		back_button.onmouseup.listen(
		function(e,c) 
		{
			change_to = "MenuState";
		});
	
		
		
		//Characters
		var char_header : mint.Image = new mint.Image({
                parent: grid_panel, name: "bgc",
                x:(grid_panel.w / 2) - (201/2), y:coins_text.y_local + coins_text.h + grid_padding, 
				w:201, h:45,
                path: "assets/image/ui/unlockables_characters_button.png"
            });
		
		//Selected char Text
		selected_char_text = new MintLabel({
                parent: grid_panel, name: "selected_char",
				x:0, y:char_header.y_local + char_header.h + (grid_padding*0.5), 
				w:grid_panel.w, h:36, 
				text_size: 36,
                text: "coins",
				color : Main.global_info.text_color,
				align: TextAlign.center, align_vertical: TextAlign.center,
            });		

		//Char Panel
		var character_panel : MintGridPanel = new MintGridPanel(grid_panel, "Characters", 
			new Vector(0, selected_char_text.y_local + selected_char_text.h + (grid_padding*0.5)), 
			grid_panel.w, 5, 5, 1, panel_colour);		
		load_character_grid(character_panel);

		
		
		//Backgrounds
		var background_header : mint.Image = new mint.Image({
                parent: grid_panel, name: "bgh",
                x:(grid_panel.w / 2) - (201/2), y:character_panel.y_local + character_panel.h + grid_padding, 
				w:201, h:45,
                path: "assets/image/ui/unlockables_environments_button.png"
            });
			
		//Selected bg Text
		selected_background_text = new MintLabel({
                parent: grid_panel, name: "selected_bg",
				x:0, y:background_header.y_local + background_header.h + (grid_padding*0.5), 
				w:grid_panel.w, h:36, 
				text_size: 36,
                text: "coins",
				color : Main.global_info.text_color,
				align: TextAlign.center, align_vertical: TextAlign.center,
            });	
		
		//BG Panel
		var background_panel : MintGridPanel = new MintGridPanel(grid_panel, "Background", 
			new Vector(0, selected_background_text.y_local + selected_background_text.h + (grid_padding*0.5)), 
			grid_panel.w, 5, 5, 1, panel_colour);
		load_background_grid(background_panel);

		//Reupdate here as we now know what size we are ^_^
		grid_panel.set_size(grid_panel.w, grid_panel.children_bounds.real_h);
		update_text_assets();
	}

	private function load_character_grid(character_panel : MintGridPanel)
	{
		for (i in 0...Main.achievement_manager.character_groups.length)
		{
			//Item Button
			var item : MintImageButton_Store = new MintImageButton_Store(character_panel, Main.achievement_manager.character_groups[i].name, 
				new Vector(0, 0), new Vector(143, 193), 
				Main.achievement_manager.character_groups[i].tex_path);
			character_panel.add_item(item);

			//On click action
			item.onmouseup.listen(
			function(e,c) 
			{
				trace("clicked!" + Main.achievement_manager.character_groups[i].name);
				clicked_character(item, Main.achievement_manager.character_groups[i]);
			});
			
			//Initial update
			var is_dirty = false;	
			//Check if character was unlocked here as we don't update.
			if (Main.achievement_manager.is_character_unlocked(Main.achievement_manager.character_groups[i].name))
			{
				item.is_unlocked = true;
				is_dirty = true;
			}
			else
			{						
				//Cost text
				var item_text : MintLabel = new MintLabel({
					parent: item, 
					name: Main.achievement_manager.character_groups[i].name + "_coins",
					x:0, y:0, 
					w:item.w, h:item.h, 
					text_size: 32,
					text: Main.achievement_manager.character_groups[i].cost + "\n Coins",
					color : new Color(),
					align: TextAlign.center, align_vertical: TextAlign.center,
				});
			}
			
			if (Main.achievement_manager.unlockables.selected_character == Main.achievement_manager.character_groups[i].name)
			{
				item.is_equipped = true;
				equipped_character_button = item;
				is_dirty = true;
			}
			
			//Update the button!			
			if (is_dirty)
			{
				item.update_button();
			}
		}
	}
	
	private function load_background_grid(background_panel : MintGridPanel)
	{
		for (i in 0...Main.achievement_manager.background_groups.length)
		{
			//Item button
			var item : MintImageButton_Store = new MintImageButton_Store(background_panel, Main.achievement_manager.background_groups[i].name, 
				new Vector(0, 0), new Vector(143, 193), 
				Main.achievement_manager.background_groups[i].tex_path);
			background_panel.add_item(item);
			
			
			
			//On click action
			item.onmouseup.listen(
			function(e,c) 
			{
				trace("clicked!" + Main.achievement_manager.background_groups[i].name);
				clicked_background(item, Main.achievement_manager.background_groups[i]);
			});
				
			//Check state
			var is_dirty = false;
			//Check if character was unlocked here as we don't update.
			if (Main.achievement_manager.is_background_unlocked(Main.achievement_manager.background_groups[i].name))
			{	
				item.is_unlocked = true;
				is_dirty = true;
			}
			else
			{
				//Cost text.
				var item_text : MintLabel = new MintLabel({
					parent: item, 
					name: Main.achievement_manager.background_groups[i].name + "_coins",
					x:0, y:0, 
					w:item.w, h:item.h, 
					text_size: 32,
					text: Main.achievement_manager.background_groups[i].cost + "\n Coins",
					color : new Color(),
					align: TextAlign.center, align_vertical: TextAlign.center,
				});
			}
			
			if (Main.achievement_manager.unlockables.selected_background == Main.achievement_manager.background_groups[i].name)
			{
				item.is_equipped = true;
				equipped_background_button = item;
				is_dirty = true;
			}
			
			if (is_dirty)
			{
				item.update_button();
			}
		}
	}
	
	private function clicked_character(button : MintImageButton_Store, character : CharacterGroup)
	{
		if (Main.achievement_manager.is_character_unlocked(character.name))
		{
			if (Main.achievement_manager.unlockables.selected_character != character.name)
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
			if (Main.achievement_manager.unlockables.current_coins >= character.cost)
			{
				button.is_unlocked = true;
				Main.achievement_manager.unlock_character(character.name);
				Main.achievement_manager.unlockables.current_coins -= character.cost;
				button.destroy_children();
				button.update_button();
			}
		}
		
		update_text_assets();
	}
	
	private function clicked_background(button : MintImageButton_Store, background : BackgroundGroup)
	{
		if (Main.achievement_manager.is_background_unlocked(background.name))
		{
			if (Main.achievement_manager.unlockables.selected_background != background.name)
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
			if (Main.achievement_manager.unlockables.current_coins >= background.cost)
			{
				button.is_unlocked = true;
				Main.achievement_manager.unlock_background(background.name);
				Main.achievement_manager.unlockables.current_coins -= background.cost;
				button.destroy_children();
				button.update_button();
			}
		}
		
		update_text_assets();
	}
	
	function update_text_assets()
	{
		coins_text.text = "Coins: " + Main.achievement_manager.unlockables.current_coins + "\n Earn Coins by playing songs";
		selected_char_text.text = "Selected Character: " + Main.achievement_manager.unlockables.selected_character;
		selected_background_text.text = "Selected Background: " + Main.achievement_manager.unlockables.selected_background;
	}
}
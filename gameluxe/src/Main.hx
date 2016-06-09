package;

import data.GameInfo;
import data.GameInfo.ScoreList;
import gamestates.CreditsState;
import gamestates.GameState;
import gamestates.MenuState;
import gamestates.ScoreState;
import luxe.States;
import haxe.xml.Fast;
import luxe.Rectangle;
import luxe.Input;

class Main extends luxe.Game 
{
	private var game_info : GameInfo;
	private var machine : States;
	
	override function ready() 
	{
		var music_volume = Std.parseFloat(Luxe.io.string_load("music_volume"));
		var effects_volume = Std.parseFloat(Luxe.io.string_load("effects_volume"));
		game_info = {
			spritesheet_elements: create_spritesheet_elements(),
			score_list: create_score_list(),
			music_volume: if (Math.isNaN(music_volume)) 0.5 else music_volume,
			effects_volume: if (Math.isNaN(effects_volume)) 0.8 else effects_volume,
		};
		
		machine = new States({ name: 'appmachine' });
		
		machine.add(new MenuState("MenuState", game_info));
		machine.add(new GameState("GameState", game_info));
		machine.add(new ScoreState("ScoreState", game_info));
		machine.add(new CreditsState("CreditsState", game_info));
		
		machine.set("MenuState");
	}

	override function config(config:luxe.GameConfig) {

#if (web && sample)
		config.window.width = 405;
		config.window.height = 720;
#else
		config.window.width = 405;
		config.window.height = 720;
#end

		config.preload.textures.push({id:'assets/image/darkPurple.png'});
        config.preload.textures.push({id:'assets/image/spritesheet_jumper.png'});
        config.preload.texts.push({id:'assets/image/spritesheet_jumper.xml'});

        return config;

    } //config
	
	private function create_spritesheet_elements()
	{
		var spritesheet_txt : String = Luxe.resources.text('assets/image/spritesheet_jumper.xml').asset.text;
		var spritesheet_xml = new Fast(Xml.parse(spritesheet_txt).firstElement());
		var result = new SpritesheetElements();
		for (xml in spritesheet_xml.nodes.SubTexture)
		{
			result.set(xml.att.name, new Rectangle(
				Std.parseFloat(xml.att.x), Std.parseFloat(xml.att.y),
				Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height)));
		}
		
		return result;
	}
	
	private function create_score_list()
	{
		var values_array : Array<String> = Luxe.io.string_load("scores").split(",");
		var score_list : ScoreList = new ScoreList();
		
		var i = 0;
		var name : String = "";
		
		for (s in values_array)
		{
			if (i == 0)
			{
				name = s;
			}
			else
			{
				var score = Std.parseInt(s);
				
				score_list.push({name: name, score: score});
			}
			
			i = (i + 1) % 2;
		}
		
		return score_list;
	}
	
}

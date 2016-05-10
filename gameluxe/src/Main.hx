package;

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
	private var spritesheet_elements : Map<String, Rectangle>;
	private var machine : States;
	
	override function ready() 
	{
		spritesheet_elements = create_spritesheet_elements();
		
		machine = new States({ name: 'appmachine' });
		
		machine.add(new MenuState("MenuState", { spritesheet_elements : spritesheet_elements }));
		machine.add(new GameState("GameState", { spritesheet_elements : spritesheet_elements }));
		machine.add(new ScoreState("ScoreState", { spritesheet_elements : spritesheet_elements }));
		machine.add(new CreditsState("CreditsState", { spritesheet_elements : spritesheet_elements }));
		
		machine.set("MenuState");
	}

	override function config(config:luxe.GameConfig) {

#if (web && sample)
		config.window.width = 720;
		config.window.height = 405;
#else
		config.window.width = 720;
		config.window.height = 405;
#end

        config.preload.textures.push({id:'assets/image/spritesheet_jumper.png'});
        config.preload.texts.push({id:'assets/image/spritesheet_jumper.xml'});

        return config;

    } //config
	
	private function create_spritesheet_elements()
	{
		var spritesheet_txt : String = Luxe.resources.text('assets/image/spritesheet_jumper.xml').asset.text;
		var spritesheet_xml = new Fast(Xml.parse(spritesheet_txt).firstElement());
		var result = new Map<String, Rectangle>();
		for (xml in spritesheet_xml.nodes.SubTexture)
		{
			result.set(xml.att.name, new Rectangle(
				Std.parseFloat(xml.att.x), Std.parseFloat(xml.att.y),
				Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height)));
		}
		
		return result;
	}
}

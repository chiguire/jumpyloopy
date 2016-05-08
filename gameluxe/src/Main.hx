package;

import phoenix.Vector;
import luxe.Input;
import luxe.Sprite;
import luxe.Rectangle;
import haxe.xml.Fast;
import luxe.tween.Actuate;

class Main extends luxe.Game 
{
	var player_sprite: Sprite;
	var spritesheet_elements : Map<String, Rectangle>;
	
	var lanes : Array<Float>;
	var previous_lane : Int;
	var current_lane : Int;
	
	override function ready() 
	{
		spritesheet_elements = create_spritesheet_elements();
		
		trace(spritesheet_elements['bunny1_ready.png']);
		player_sprite = new Sprite({
			name: 'Player',
			texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			uv: spritesheet_elements['bunny1_ready.png'],
			pos: new Vector(150, 100),
			size: new Vector(spritesheet_elements['bunny1_ready.png'].w, spritesheet_elements['bunny1_ready.png'].h),
		});
		
		connect_input();
		
		lanes = new Array<Float>();
		lanes.push(1 * Luxe.screen.width / 4.0);
		lanes.push(2 * Luxe.screen.width / 4.0);
		lanes.push(3 * Luxe.screen.width / 4.0);
		
		player_sprite.pos.x = lanes[0];
		previous_lane = 0;
		current_lane = 0;
	}

	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
	}

	override function update(dt:Float) 
	{
		if (Luxe.input.inputpressed('a'))
		{
			current_lane = 0;
		}
		else if (Luxe.input.inputpressed('b'))
		{
			current_lane = 1;
		}
		else if (Luxe.input.inputpressed('c'))
		{
			current_lane = 2;
		}
		
		if (current_lane != previous_lane)
		{
			Actuate.tween(player_sprite.pos, 0.1, { x: lanes[current_lane] });
		}
		
		previous_lane = current_lane;
	}
	
	override function config(config:luxe.AppConfig) {

        #if (web && sample)
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
	
	private function connect_input()
	{
		Luxe.input.bind_key('a', Key.key_q);
		Luxe.input.bind_key('b', Key.key_w);
		Luxe.input.bind_key('c', Key.key_e);
	}
}

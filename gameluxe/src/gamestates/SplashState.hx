package gamestates;

import luxe.Vector;
import luxe.Color;
import luxe.Sprite;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.Actuate;
import data.GameInfo;
import luxe.Scene;
import luxe.Input.KeyEvent;
import luxe.Input.Key;

/**
 * ...
 * @author 
 */
class SplashState extends State
{
	private var game_info : GameInfo;

	private var scene : Scene;
	
	private var warchild : Sprite;
	private var ca : Sprite;
	private var audio : Sprite;
	
	private var color : Color;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			machine.set("MenuState");
	}
	
	override function onleave<T>(_value:T)
	{
		trace("Exiting Credits");
		
		warchild.destroy();
		ca.destroy();
		audio.destroy();
		scene.empty();
		scene.destroy();
		scene = null;
		warchild = null;
		ca = null;
		audio = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering Splash");
		
		scene = new Scene("SplashScene");
		
		Main.create_background(scene);
		
		var data : Dynamic = { pos_x: 720, pos_y: 450 };
		
		warchild = new Sprite({
			name: 'WarchildSplashSprite',
			texture: Luxe.resources.texture('assets/image/splash/warchild.png'),
			pos: new Vector(data.pos_x, data.pos_y),
			scene: scene,
		});
		
		ca = new Sprite({
			name: 'CASplashSprite',
			texture: Luxe.resources.texture('assets/image/splash/ca.png'),
			pos: new Vector(data.pos_x, data.pos_y),
			scene: scene,
		});
		
		audio = new Sprite({
			name: 'AudioSplashSprite',
			texture: Luxe.resources.texture('assets/image/splash/audio.png'),
			pos: new Vector(data.pos_x, data.pos_y),
			scene: scene,
		});
		
		warchild.visible = false;
		ca.visible = false;
		audio.visible = false;
		
		color = new Color(1, 1, 1, 0);
		
		warchild.color = color;
		ca.color = color;
		audio.color = color;
		
		warchild.visible = true;
		
		var appear_time = 0.5;
		var stay_time = 1;
		Actuate.tween(color, appear_time, {a:1.0}).onComplete(function()
		{
			Actuate.timer(stay_time).onComplete(function()
			{
				Actuate.tween(color, appear_time, {a:0.0}).onComplete(function()
				{
					warchild.visible = false;
					ca.visible = true;
					Actuate.tween(color, appear_time, {a:1.0}).onComplete(function()
					{
						Actuate.timer(stay_time).onComplete(function()
						{
							Actuate.tween(color, appear_time, {a:0.0}).onComplete(function()
							{
								ca.visible = false;
								audio.visible = true;
								Actuate.tween(color, appear_time, {a:1.0}).onComplete(function()
								{
									Actuate.timer(stay_time).onComplete(function()
									{
										Actuate.tween(color, appear_time, {a:0.0}).onComplete(function()
										{
											machine.set("MenuState");
										});
									});
								});
							});
						});
					});
				});
			});
		});
	}
	
}
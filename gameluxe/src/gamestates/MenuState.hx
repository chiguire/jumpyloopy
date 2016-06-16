package gamestates;

import analysis.FFT;
import data.GameInfo;
import luxe.Input.MouseEvent;
import luxe.Scene;
import luxe.Vector;
import luxe.Color;
import luxe.Game;
import luxe.Text;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
import ui.Button;
	
/**
 * ...
 * @author 
 */
class MenuState extends State
{
	private var game_info : GameInfo;
	
	private var scene : Scene;
	private var title_text : Text;
	private var play_button : Button;
	private var scores_button : Button;
	private var credits_button : Button;
	
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		scene = null;
		title_text = null;
		play_button = null;
		scores_button = null;
		credits_button = null;
	}
	
	override function init()
	{
		
	}
	
	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
	}
	
	override function onleave<T>(_value:T)
	{
		trace("Exiting menu");
		
		play_button.destroy();
		scores_button.destroy();
		credits_button.destroy();
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
		
		play_button = null;
		scores_button = null;
		credits_button = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering menu");
		
		scene = new Scene("MenuScene");
		
		title_text = new Text({
			text: "Jumpyloopy (please change this)",
			point_size: 48,
			pos: new Vector(10, 10),
			color: Color.random(),
			scene: scene,
		});
		
		play_button = new Button({
			name: "Play",
			pos: new Vector(10, 110),
			text: {
				text: "Play",
				point_size: 12
			},
			scene: scene,
		});
		
		scores_button = new Button({
			name: "Scores",
			pos: new Vector(10, 160),
			text: {
				text: "Scores",
				point_size: 12,
			},
			scene: scene,
		});
		
		credits_button = new Button({
			name: "Credits",
			pos: new Vector(10, 210),
			text: {
				text: "Credits",
				point_size: 12,
			},
			scene: scene,
		});
		
		
		play_button.events.listen('button.clicked', function (e:ButtonEvent)
		{
			machine.set("GameState");
		});
		
		scores_button.events.listen('button.clicked', function (e:ButtonEvent)
		{
			machine.set("ScoreState");
		});
		
		credits_button.events.listen('button.clicked', function (e:ButtonEvent)
		{
			machine.set("CreditsState");
		});
		
		FFT.test_fft();
	}
}
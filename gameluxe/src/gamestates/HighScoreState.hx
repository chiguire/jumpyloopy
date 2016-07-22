package gamestates;

import data.GameInfo;
import luxe.Scene;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.Input;
import mint.types.Types.TextAlign;
import ui.MintImageButton;
import ui.MintLabel;
import ui.MintLabelPanel;
import luxe.Sprite;

/**
 * ...
 * @author 
 */
class HighScoreState extends State
{
	private var game_info : GameInfo;
	
	var scene : Scene;
	
	private var bg_image : Sprite;
	
	var change_state_signal = false;
	
	private var current_score : Int = 0;
	private var score_ids : Array<SongSignature>;
	
	private var song_title : MintLabel;
	
	private var name_label : MintLabel;
	private var score_label : MintLabel;
	private var distance_label : MintLabel;
	private var time_label : MintLabel;
	
	private var score_name : Array<MintLabel>;
	private var score_score : Array<MintLabel>;
	private var score_distance : Array<MintLabel>;
	private var score_time : Array<MintLabel>;
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
	}
	
	override function init()
	{
		
	}
	
	override function onleave<T>(_value:T)
	{
		bg_image.destroy();
		scene.empty();
		scene.destroy();
		scene = null;
		bg_image = null;
		
		Main.canvas.destroy_children();	
		
		song_title = null;
		name_label = null;
		score_label = null;
		distance_label = null;
		time_label = null;
		score_name = null;
		score_score = null;
		score_distance = null;
		score_time = null;
	}
	
	override function onenter<T>(_value:T)
	{
		// load parcels
		scene = new Scene();
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		var data : Dynamic = { pos_x: 720, pos_y: 450 };
		
		bg_image = new Sprite({
			name: 'BgSprite',
			texture: Luxe.resources.texture('assets/image/bg/cave_01_paper.png'),
			pos: new Vector(data.pos_x, data.pos_y),
			scene: scene,
		});
		
		create_panel();
		
		current_score = 0;
		score_ids = [for (k in Main.user_data.score_list.keys()) k];
		current_score = Lambda.indexOf(score_ids, "e1c230c608ea62436abde2ee6d412e8d");
		update_scores();
	}
	
	function create_panel()
	{
		Main.create_background(scene);
		
		//Prev Button	
		var prev_button : MintImageButton = new MintImageButton(Main.canvas, "Prev", new Vector(470 + 50, 144), new Vector(113, 50), "assets/image/ui/UI_highscore_prev.png");
		prev_button.onmouseup.listen(function(e, c) {
			show_previous_scores();
		});
		
		//Next Button	
		var next_button : MintImageButton = new MintImageButton(Main.canvas, "Next", new Vector(470 + 350, 144), new Vector(113, 50), "assets/image/ui/UI_highscore_next.png");
		next_button.onmouseup.listen(function(e, c) {
			show_next_scores();
		});
		
		song_title = new MintLabel({
			parent: Main.canvas,
			mouse_input:false, x:495, y:200, w:450, h:72, text_size: 48,
			align: TextAlign.left, align_vertical: TextAlign.center,
			text: "",
			color: Main.global_info.text_color,
		});
		
		var col1 = 495;
		var col2 = 620;
		var col3 = 755;
		var col4 = 875;
		var line_height = 72;
		
		name_label = new MintLabel({
			parent: Main.canvas,
			mouse_input:false, x:col1, y:200+1*line_height, w:450, h:72, text_size: 48,
			align: TextAlign.left, align_vertical: TextAlign.center,
			text: "Name",
			color: Main.global_info.text_color,
		});
		
		score_label = new MintLabel({
			parent: Main.canvas,
			mouse_input:false, x:col2, y:200+1*line_height, w:450, h:72, text_size: 48,
			align: TextAlign.left, align_vertical: TextAlign.center,
			text: "Score",
			color: Main.global_info.text_color,
		});
		
		distance_label = new MintLabel({
			parent: Main.canvas,
			mouse_input:false, x:col3, y:200+1*line_height, w:450, h:72, text_size: 48,
			align: TextAlign.left, align_vertical: TextAlign.center,
			text: "Distance",
			color: Main.global_info.text_color,
		});
		
		time_label = new MintLabel({
			parent: Main.canvas,
			mouse_input:false, x:col4, y:200+1*line_height, w:450, h:72, text_size: 48,
			align: TextAlign.left, align_vertical: TextAlign.center,
			text: "Time",
			color: Main.global_info.text_color,
		});
		
		score_name = new Array();
		score_distance = new Array();
		score_score = new Array();
		score_time = new Array();
		
		for (i in 0...5)
		{
			score_name.push(new MintLabel({
				parent: Main.canvas,
				mouse_input:false, x:col1, y:200+(i+2)*line_height, w:450, h:72, text_size: 48,
				align: TextAlign.left, align_vertical: TextAlign.center,
				text: "",
				color: Main.global_info.text_color,
			}));
			
			score_score.push(new MintLabel({
				parent: Main.canvas,
				mouse_input:false, x:col2, y:200+(i+2)*line_height, w:450, h:72, text_size: 48,
				align: TextAlign.left, align_vertical: TextAlign.center,
				text: "",
				color: Main.global_info.text_color,
			}));
			
			score_distance.push(new MintLabel({
				parent: Main.canvas,
				mouse_input:false, x:col3, y:200+(i+2)*line_height, w:450, h:72, text_size: 48,
				align: TextAlign.left, align_vertical: TextAlign.center,
				text: "",
				color: Main.global_info.text_color,
			}));
			
			score_time.push(new MintLabel({
				parent: Main.canvas,
				mouse_input:false, x:col4, y:200+(i+2)*line_height, w:450, h:72, text_size: 48,
				align: TextAlign.left, align_vertical: TextAlign.center,
				text: "",
				color: Main.global_info.text_color,
			}));
		}
		
		//Back Button	
		var back_button : MintImageButton = new MintImageButton(Main.canvas, "Back", new Vector(470 + 220, 823), new Vector(62, 38), "assets/image/ui/UI_track_selection_back.png");
		back_button.onmouseup.listen(function(e, c) {
			change_state_signal = true;
		});
	}
	
	function show_previous_scores()
	{
		current_score = (score_ids.length + current_score - 1) % score_ids.length;
		update_scores();
	}
	
	function show_next_scores()
	{
		current_score = (current_score + 1) % score_ids.length;
		update_scores();
	}
	
	function update_scores()
	{
		trace('Current song id is ${score_ids[current_score]}');
		
		var song_name = Main.user_data.score_list.get(score_ids[current_score]).name;
		
		if (song_name.length > 30)
		{
			song_name = song_name.substring(0, 30) + "...";
		}
		
		song_title.text = song_name;
		
		var scrs : Array<ScoreRun> = Main.user_data.score_list.get(score_ids[current_score]).scores;
		
		for (i in 0...scrs.length)
		{
			var scr = scrs[i];
			
			score_name[i].text = scr.name;
			score_score[i].text = Std.string(scr.score);
			score_distance[i].text = Std.string(scr.distance);
			score_time[i].text = ScoreState.time_to_string(scr.time);
		}
		
	}
	
	override function update(dt:Float) 
	{
		if (change_state_signal)
		{
			change_state_signal = false;
			machine.set("MenuState");
		}
	}
}
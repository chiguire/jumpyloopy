package data;

import haxe.ds.Vector;
import luxe.Color;
import luxe.Rectangle;


/// user data
typedef UserDataHeader = 
{
	version : Float,
};

typedef UserDataV1 = 
{
	?user_name : String,
	?score_list : ScoreList,
	unlockables : Unlockables,
};

typedef Unlockables = {
	var total_coins : Int;
	var current_coins : Int;
	var collected_fragments : Array<Bool>;
	var completed_story_mode : Bool;
	var selected_character : String;
	var selected_background : String;
	var unlocked_backgrounds : Array<String>;
	var unlocked_characters : Array<String>; 
};

typedef ScoreRun = {
	name:String,
	score:Int,
	distance:Int,
	time:Int,
	?song_id:SongSignature,
};

typedef SongSignature = String;
typedef SongInfo = {
	name : String,
	scores : Array<ScoreRun>,
}
typedef ScoreList = Map<SongSignature, SongInfo>;
typedef VolumeUnit = Float;

typedef GlobalGameInfo = 
{
	var ref_window_size_x : Int;
	var ref_window_size_y : Int;
	var window_size_x : Int;
	var window_size_y : Int;
	var fullscreen : Bool;
	var borderless : Bool;
	var platform_lifetime : Float;
	var text_color : Color;
	var user_storage_filename : String;
};

typedef GameInfo =
{
	music_volume : VolumeUnit,
	effects_volume : VolumeUnit,
	?current_score : ScoreRun,
};

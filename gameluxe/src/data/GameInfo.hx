package data;

import haxe.ds.Vector;
import luxe.Rectangle;

typedef ScoreList = Array<{name:String, score:Int}>;
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
};

typedef GameInfo =
{
	score_list : ScoreList,
	music_volume : VolumeUnit,
	effects_volume : VolumeUnit,
	?current_score : Int,
};

/// user data
typedef UserDataHeader = 
{
	var version : Float;
};

typedef UserDataV1 = 
{
	> UserDataHeader,
	var total_score : Int;
};
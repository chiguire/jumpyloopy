package entities;
import luxe.Entity;

/**
 * ...
 * @author ...
 */

 
typedef ScoreEvent = {
      val : Int,
}

class Score extends Entity
{
	var current_score : Int;
	var current_multiplier : Int;
	
	public function new() 
	{
		super();
		reset_score();
		reset_multiplier();
	}
	
		//High Score - SM
	public function add_score(e : ScoreEvent)
	{
		trace("Player Scored " + e.val + "*" + current_multiplier +"= " + (e.val * current_multiplier) +" points");
		current_score += e.val * current_multiplier;
	}
	
	public function get_score() : Int
	{
		return current_score;
	}
	
	public function reset_score()
	{
		current_score = 0;
	}
	
	public function add_multiplier(e : ScoreEvent)
	{
		trace("Player Multiplier increased!");
		current_multiplier *= 2;
	}
	
	public function get_multiplier() : Int
	{
		return current_multiplier;
	}
	
	public function reset_multiplier()
	{
		current_multiplier = 1;
	}
	
	public function register_listeners()
	{
		Luxe.events.listen("add_score", add_score);
		Luxe.events.listen("add_multiplier", add_multiplier);
	}
	
	public function unregister_listeners()
	{
		Luxe.events.unlisten("add_score");
		Luxe.events.unlisten("add_multiplier");
	}
}
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
	
	// event id, stored so we can unlisten
	var event_id : Array<String>;
	
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
		
		var mul = e.val > 0 ? current_multiplier : 1;
		current_score += e.val * mul;
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
		// events
		event_id = new Array<String>();
		event_id.push(Luxe.events.listen("add_score", add_score));
		event_id.push(Luxe.events.listen("add_multiplier", add_multiplier));
	}
	
	public function unregister_listeners()
	{
		// events
		for (i in 0...event_id.length)
		{
			var res = Luxe.events.unlisten(event_id[i]);
		}
		event_id = null;
	}
}
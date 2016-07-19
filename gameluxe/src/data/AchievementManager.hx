package data;
import haxe.ds.Vector;

/**
 * ...
 * @author 
 */
class AchievementManager
{
	public var collected_fragments : Vector<Bool>;
	
	public function new() 
	{
		collected_fragments = new Vector<Bool>(10);
	}
	
	public function update_collected_fragments( fragment_states : Array<Bool> )
	{
		for ( i in 0...collected_fragments.length )
		{
			collected_fragments[i] = (collected_fragments[i] == false) ? fragment_states[i] : collected_fragments[i];
		}
	}
}
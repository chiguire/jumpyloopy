package analysis;

/**
 * ...
 * @author WK
 */
class ThresholdFunction
{
	/** the history size **/
	var history_size = 0;
	/** the average multiplier **/
	var multiplier = 0.0;
	
	/**
	 * Consturctor, sets the history size in number of spectra
	 * to take into account to calculate the average spectral flux
	 * at a specific position. Also sets the multiplier to 
	 * multiply the average with.
	 * 
	 * @param historySize The history size.
	 * @param multiplier The average multiplier.
	 */
	public function new( history_size:Int, multiplier:Float ) 
	{
		this.history_size = history_size;
		this.multiplier = multiplier;
	}
	
	/**
	 * Returns the threshold function for a given 
	 * spectral flux function.
	 * 
	 * @return The threshold function.
	 */
	public function calculate( spectral_flux: Array<Float> ) : Array<Float>
	{
		var thresholds = new Array<Float>();
		
		for ( i in 0...spectral_flux.length)
		{
			var sum = 0.0;
			var start = Std.int(Math.max( 0, i - history_size / 2));
			var end = Std.int(Math.min( spectral_flux.length - 1, i + history_size / 2 ));
			
			for ( j in start...end + 1)
			{
				sum += spectral_flux[j];
			}
			
			sum /= ( end - start );
			sum *= multiplier;
			
			thresholds.push( sum );
		}
		
		return thresholds;
	}
}
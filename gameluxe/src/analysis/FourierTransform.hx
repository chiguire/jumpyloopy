package analysis;
import haxe.ds.Vector;

/**
 * ...
 * @author WK
 */
class FourierTransform
{
	/** A constant indicating no window should be used on sample buffers. */
	public static var NONE = 0;
	/** A constant indicating a Hamming window should be used on sample buffers. */
	public static var HAMMING = 1;
	
	/// average mode
	static var LINAVG = 2;
	static var LOGAVG = 3;
	static var NOAVG = 4; 
	
	var time_size = 0;
	var sample_rate = 0;
	var bandwidth = 0.0;
	var which_avg = NOAVG;
	public var which_window = NONE;
	
	// log avg
	var octaves = 0;
	var avg_per_octave = 0;
	
	var real : Vector<Float>;
	var imag : Vector<Float>;
	
	public var spectrum : Vector<Float>;
	var averages : Vector<Float>;
	
	
	/**
    * Construct a FourierTransform that will analyze sample buffers that are
    * <code>ts</code> samples long and contain samples with a <code>sr</code>
    * sample rate.
    * 
    * @param ts
    *          the length of the buffers that will be analyzed
    * @param sr
    *          the sample rate of the samples that will be analyzed
    */
	public function new( ts:Int, sr:Float) 
	{
		time_size = ts;
		sample_rate = Std.int(sr);
		bandwidth = (2.0 / time_size) * (sample_rate / 2.0);
		
		allocate_arrays();
	}
	
	public function allocate_arrays() {}
	
	public function set_complex( r:Vector<Float>, i:Vector<Float>)
	{
		Vector.blit(real, 0, r, 0, real.length);
		Vector.blit(imag, 0, i, 0, imag.length);
	}
	
	// fill the spectrum array with the amps of the data in real and imag
	// used so that this class can handle creating the average array
	// and also do spectrum shaping if necessary
	function fill_spectrum()
	{
		for ( i in 0...spectrum.length )
		{
			spectrum[i] = Math.sqrt( real[i] * real[i] + imag[i] * imag[i] );
		}
		
		// average calculation
		if (which_avg == LINAVG)
		{
			var avg_width = Std.int(spectrum.length / averages.length);
			
			for ( i in 0...averages.length)
			{
				var avg = 0.0;
				var counter = 0;
				
				for ( j in 0...avg_width )
				{
					var offset = j + i * avg_width;
					
					if ( offset < spectrum.length ) 
					{
						avg += spectrum[offset];
						counter++;
					}
					else 
					{
						break;
					}
				}
				
				avg /= counter;
				averages[i] = avg;
			}
		}
		else if (which_avg == LOGAVG)
		{
			for ( i in 0...octaves)
			{
				var lowfreq = 0.0;
				var hifreq = 0.0;
				var freqstep = 0.0;
				
				if ( i != 0 )
				{
					lowfreq = (sample_rate / 2.0) / Math.pow( 2, octaves - i );
				}
				hifreq = (sample_rate / 2.0) / Math.pow( 2, octaves - i - 1 );
				freqstep = (hifreq - lowfreq) / avg_per_octave;
				
				var f = lowfreq;
				
				for (j in 0...avg_per_octave)
				{
					var offset = j + i * avg_per_octave;
					averages[offset] = calc_avg(f, f + freqstep);
					f += freqstep;
				}
			}
		}
	}
	
	/**
	* Calculate the average amplitude of the frequency band bounded by
	* <code>lowFreq</code> and <code>hiFreq</code>, inclusive.
	* 
	* @param lowFreq
	*          the lower bound of the band
	* @param hiFreq
	*          the upper bound of the band
	* @return the average of all spectrum values within the bounds
	*/
	public function calc_avg( lowfreq:Float, hifreq:Float) : Float 
	{
		var lowbound = freq_to_index(lowfreq);
		var hibound = freq_to_index(hifreq);
		
		var avg = 0.0;
		for ( i in lowbound...hibound + 1)
		{
			avg += spectrum[i];
		}
		avg /= (hibound - lowbound + 1);
		return avg;
	}
	
	/**
	* Returns the index of the frequency band that contains the requested
	* frequency.
	* 
	* @param freq
	*          the frequency you want the index for (in Hz)
	* @return the index of the frequency band that contains freq
	*/
	public function freq_to_index(freq:Float) : Int
	{
		// special case: freq is lower than the bandwidth of spectrum[0]
		if (freq < bandwidth / 2) return 0;
		// special case: freq is within the bandwidth of spectrum[spectrum.length - 1]
		if (freq > sample_rate / 2 - bandwidth / 2) return spectrum.length - 1;
		// all other cases
		var fraction = freq / sample_rate;
		//trace(fraction);
		var i = Math.round(time_size * fraction);
		return i;
	}
	
	function do_window( samples:Vector<Float> )
	{
		switch which_window
		{
			case FourierTransform.HAMMING : hamming(samples);
		}
	}
	
	// windows the data in samples with a Hamming window
	function hamming( samples:Vector<Float> )
	{
		for ( i in 0...samples.length )
		{
			samples[i] *= (0.54 - 0.46 * Math.cos(Math.PI * 2 / (samples.length - 1))); 
		}
	}
}
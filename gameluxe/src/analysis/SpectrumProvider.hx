package analysis;
import haxe.ds.Vector;

/**
 * ...
 * @author ...
 */

/**
 * Provides float[] arrays of successive spectrum frames retrieved via
 * FFT from a Decoder. The frames might overlapp by n samples also called
 * the hop size. Using a hop size smaller than the spectrum size is beneficial
 * in most cases as it smears out the spectra of successive frames somewhat. 
 * @author mzechner
 *
 */
class SpectrumProvider
{
	var  
	
	var hop_size = 0;
	var fft : FFT;
	
	// samples
	var samples : Vector<Float>;
	var next_samples : Vector<Float>;
	var temp_samples : Vector<Float>;
	
	/**
	 * Constructor, sets the {@link Decoder}, the sample window size and the
	 * hop size for the spectra returned. Say the sample window size is 1024
	 * samples. To get an overlapp of 50% you specify a hop size of 512 samples,
	 * for 25% overlap you specify a hopsize of 256 and so on. Hop sizes are of
	 * course not limited to powers of 2. 
	 * 
	 * @param decoder The decoder to get the samples from.
	 * @param sampleWindowSize The sample window size.
	 * @param hopSize The hop size.
	 * @param useHamming Wheter to use hamming smoothing or not.
	 */
	public function new(sample_window_size:Int, _hop_size:Int, use_hamming:Bool)
	{
		samples = new Vector<Float>(sample_window_size);
		next_samples = new Vector<Float>(sample_window_size);
		temp_samples = new Vector<Float>(sample_window_size);
		
		hop_size = _hop_size;
		
		fft = new FFT(sample_window_size, 44100.0);
		if (use_hamming) fft.which_window = FourierTransform.HAMMING;
		
		// read samples
		// read next_samples
		
	}
	
}
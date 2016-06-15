package analysis;
import haxe.ds.Vector;

/**
 * ...
 * @author ...
 */

 /**
 * DFT stands for Discrete Fourier Transform and is the most widely used Fourier
 * Transform. You will never want to use this class due to the fact that it is a
 * brute force implementation of the DFT and as such is quite slow. Use an FFT
 * instead. This exists primarily as a way to ensure that other implementations
 * of the DFT are working properly. This implementation expects an even
 * <code>timeSize</code> and will throw and IllegalArgumentException if this
 * is not the case.
 * 
 * @author Damien Di Fede
 * 
 * @see FourierTransform
 * @see FFT
 * @see <a href="http://www.dspguide.com/ch8.htm">The Discrete Fourier Transform</a>
 * 
 */
class DFT extends FourierTransform
{
	/**
	* Constructs a DFT that expects audio buffers of length <code>timeSize</code> that 
	* have been recorded with a sample rate of <code>sampleRate</code>. Will throw an 
	* IllegalArgumentException if <code>timeSize</code> is not even.
	* 
	* @param timeSize the length of the audio buffers you plan to analyze
	* @param sampleRate the sample rate of the audio samples you plan to analyze
	*/
	public function new( ts:Int, sr:Float ) 
	{
		super(ts, sr);
	}
	
	override public function allocate_arrays() 
	{
		var size = Std.int(time_size / 2) + 1;
		spectrum = new Vector<Float>(size);
		real = new Vector<Float>(size);
		imag = new Vector<Float>(size);
	}
	
	public function forward( samples:Vector<Float> )
	{
		do_window(samples);
		var N = samples.length;
		
		for ( f in 0...Std.int(N / 2) )
		{
			real[f] = 0.0;
			imag[f] = 0.0;
			
			for ( t in 0...N )
			{
				real[f] += samples[t] * Math.cos(t * f);
				imag[f] += samples[t] * -Math.sin(t * f);
			}
		}
		
		fill_spectrum();
	}
}
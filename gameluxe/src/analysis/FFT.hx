package analysis;
import haxe.ds.Vector;

/**
 * ...
 * @author WK
 */

/**
 * FFT stands for Fast Fourier Transform. It is an efficient way to calculate the Complex 
 * Discrete Fourier Transform. There is not much to say about this class other than the fact 
 * that when you want to analyze the spectrum of an audio buffer you will almost always use 
 * this class. One restriction of this class is that the audio buffers you want to analyze 
 * must have a length that is a power of two. If you try to construct an FFT with a 
 * <code>timeSize</code> that is not a power of two, an IllegalArgumentException will be 
 * thrown.
 * 
 * @see FourierTransform
 * @see <a href="http://www.dspguide.com/ch12.htm">The Fast Fourier Transform</a>
 * 
 * @author Damien Di Fede
 * 
 */ 
class FFT extends FourierTransform
{
	var reverse : Vector<Int>;
	
	// worth noting that ts has to be power of 2
	public function new( ts:Int, sr:Float) 
	{
		super(ts, sr);
		
		build_reverse_table();
		
	}
	
	public override function allocate_arrays()
	{
		spectrum = new Vector<Float>(Std.int(time_size / 2) + 1);
		real = new Vector<Float>(time_size);
		imag = new Vector<Float>(time_size);
	}
	
	function build_reverse_table()
	{
		var N = time_size;
		reverse = new Vector<Int>(N);
		
		var limit = 1;
		var bit : Int = N / 2;
		while ( limit < N )
		{
			for (i in 0...limit)
			{
				reverse[i + limit] = reverse[i] + bit;
			}
			
			limit <<= 1;
			bit >>= 1;
		}
	}
}
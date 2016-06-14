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
	
	public function forward( buffer:Vector<Float> )
	{
		do_window(buffer);
		// copy samples to real/imag in bit-reversed order
		bit_reverse_samples(buffer);
		// perform the fft
		fft();
		// fill the spectrum buffer with amplitudes
		fill_spectrum(); 
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
	
	// copies the values in the samples array into the real array
	// in bit reversed order. the imag array is filled with zeros.
	function bit_reverse_samples( samples:Vector<Float> )
	{
		for ( i in 0...samples.length)
		{
			real[i] = samples[reverse[i]];
			imag[i] = 0.0;
		}
	}
	
	// performs an in-place fft on the data in the real and imag arrays
	// bit reversing is not necessary as the data will already be bit reversed
	function fft()
	{
		var half_size = 1;
		while ( half_size < real.length )
		{
			var k = -Math.PI / half_size;
			// phase shift step
			var phase_shift_step_r = Math.cos(k);
			var phase_shift_step_i = Math.sin(k);
			
			// current phase shift
			var curr_phase_shift_r = 1.0;
			var curr_phase_shift_i = 0.0;
			
			for ( fft_step in 0...half_size )
			{
				var i = fft_step;
				while ( i < real.length )
				{
					var off = i + half_size;
					var tr = ( curr_phase_shift_r * real[off] ) - ( curr_phase_shift_i * imag[off] );
					var ti = ( curr_phase_shift_r * imag[off] ) + ( curr_phase_shift_i * real[off] );
					
					real[off] = real[i] - tr;
					imag[off] = imag[i] - ti;
					
					real[i] += tr;
					imag[i] += ti;
					
					// step
					i += 2 * half_size;
				}
				
				var tmp_r = curr_phase_shift_r;
				
				curr_phase_shift_r = (tmp_r * phase_shift_step_r) - (curr_phase_shift_i * phase_shift_step_i);
				curr_phase_shift_i = (tmp_r * phase_shift_step_i) + (curr_phase_shift_i * phase_shift_step_r);
			}
			
			// step
			half_size *= 2;
		}
	}
}
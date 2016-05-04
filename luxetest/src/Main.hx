package;

import haxe.ds.Vector;
import luxe.Input;
import luxe.resource.Resource.AudioResource;
import phoenix.geometry.QuadGeometry;
import luxe.Color;
import luxe.Audio;
import snow.api.Debug.*;
import snow.api.buffers.Uint8Array;
import hxa.fft.FFTFilter;
import hxa.ds.CircularBuffer;

class Main extends luxe.Game 
{
	public var box      : Array<QuadGeometry>;
	private var music: AudioResource;
	private var music_handle: luxe.Audio.AudioHandle;
		
	private static inline var LOG_N = 16;
	private static inline var SAMPLE_RATE = 44;
	
	private var fft_filter : FFTFilter;
	private var buffer : CircularBuffer<Float>;
	private var final_freqs : Array<Float>;
	
	private static inline var NUM_BOXES = 200;
	private static inline var BOX_WIDTH = 1;
	private static inline var BOX_SPACE = 1;
	private static inline var BOX_MARGIN = 20;
	
	override function ready() 
	{	
		box = new Array<QuadGeometry>();
		final_freqs = new Array<Float>();
		for (i in 0...NUM_BOXES)
		{
			box.push(Luxe.draw.box({
				x : BOX_MARGIN + i * (BOX_WIDTH + BOX_SPACE),
				y : 40,
				depth:-3,
				w : BOX_WIDTH,
				h : 1,
				color : new Color(255,255,255,1.0)
			}));
			final_freqs.push(0.0);
		}
		
		buffer = new CircularBuffer<Float>(1 << LOG_N, 0.0);
		fft_filter = new FFTFilter(buffer, SAMPLE_RATE * 1000);
		
		var load = snow.api.Promise.all([
            Luxe.resources.load_audio('assets/timemachine.ogg')
        ]);
		
		load.then(function(_) {

            //go away
            //box.color.tween(2, {a:0});
			music = Luxe.resources.audio('assets/timemachine.ogg');
			music_handle = Luxe.audio.loop(music.source);
			
			trace("Format: " + music.source.data.format);
			trace("Channels: " + music.source.data.channels);
			trace("Rate: " + music.source.data.rate);
			trace("Length: " + music.source.data.length);
			
	 		//var s = "";
			//for (i in 0...1024)
			//{
			//	s += Std.string(music.source.data.samples[i]) +",";
			//}
			//log(s);
			
			//Luxe.showConsole(true);
		});
	}

	override function onkeyup(e:KeyEvent) 
	{
		if(e.keycode == Key.escape)
			Luxe.shutdown();
	}

	override function update(dt:Float) 
	{
		//box.pos = Luxe.screen.cursor.pos;
		//trace(fft_filter.mag.length);
		var audio_time = music.source.seconds_to_bytes(Luxe.audio.position_of(music_handle));
		//trace(audio_time);
		for (i in 0...buffer.length)
		{
			var val = 1.0 * music.source.data.samples[(audio_time + i) % music.source.data.length];
			buffer.writeValue(val);
			//trace(val);
		}
		//trace("***");
		fft_filter.update();
		
		for (i in 0...final_freqs.length)
		{
			final_freqs[i] = 0.0;
		}
		
		for (i in 0...fft_filter.mag.length)
		{
			final_freqs[Math.floor(i * (final_freqs.length / fft_filter.mag.length))] += Math.max(fft_filter.mag[i], 0);
		}
		
		//trace(fft_filter.mag[0]);
		for (i in 0...NUM_BOXES)
		{
			box[i].resize_xy(BOX_WIDTH, 
				1 + final_freqs[i]*0.25);
		}	
	}
	
	//public function apply_window_function(arr:Uint8Array, start:Int, N:Int)
	//{
	//	var result : Array<Float> = new Array<Float>(N);
	//	for (i in 0...N)
	//	{
	//		result[i] = 1.0f * arr[i];
	//	}
	//}
}

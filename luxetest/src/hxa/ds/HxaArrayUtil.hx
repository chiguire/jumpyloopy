package hxa.ds;

/**
 * Cross-platform "Array.new".
 */
class HxaArrayUtil {
    public static inline function newArray<T>(len=0, fixed=false, default_value:T = null): HxaArray<T> {
        #if flash
		return new flash.Vector<T>(len, fixed);
		#else
		var result = new Array<T>();
		for (i in 0...len)
		{
			result.push(default_value);
		}
		return result;
		#end
    }
}
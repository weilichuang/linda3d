package linda.math;
    import flash.Memory;
	class MathUtil
	{
		public static inline var ROUNDING_ERROR : Float = 0.0001;
		public static inline var ONE_EIGHTY_OVER_PI : Float = 180. / Math.PI;
		public static inline var PI_OVER_ONE_EIGHTY : Float = Math.PI / 180.;
		public static inline var TWO_PI : Float = Math.PI * 2.0;
		/**
		* 近似相等
		*/
		public static inline function equals (a : Float, b : Float) : Bool
		{
			return (a + ROUNDING_ERROR > b) && (a - ROUNDING_ERROR < b);
		}
		
		public static inline function clamp(value:Float,low:Float,high:Float):Float
		{
			return min(max(value, low), high);
		}
		
		public static inline function clampInt(value:Int,low:Int,high:Int):Int
		{
			return minInt(minInt(value, low), high);
		}
		
		public static inline function sin(angle:Float):Float
		{
			var f:Int = Std.int(angle * 683565275.57643158978229477811035) >> 16;
            var sin:Int = (f - ((f * ((f < 0)?-f:f)) >> 15)) * 41721;
            var ssin:Int = sin >> 15;
            return (((ssin * (sin < 0?-ssin:ssin)) >> 9) * 467 + sin) / 441009855.21060102566599663103894;
		}
		public static inline function cos(angle:Float):Float
		{
			var f:Int = (Std.int(angle * 683565275.57643158978229477811035) + 1073741824) >> 16;
            var sin:Int = (f - ((f * ((f < 0)?-f:f)) >> 15)) * 41721;
            var ssin:Int = sin >> 15;
            return (((ssin * (sin < 0?-ssin:ssin)) >> 9) * 467 + sin) / 441009855.21060102566599663103894;
		}

		public static inline function invSqrt( x : Float ) : Float {
    	    var half:Float = 0.5 * x;
    	    Memory.setFloat(0,x);
    	    var i:Int = Memory.getI32(0);
    	    i = 0x5f3759df - (i>>1);
    	    Memory.setI32(0,i);
    	    x = Memory.getFloat(0);
    	    x = x * (1.5 - half*x*x);
    	    return x;
	    }
		public static inline function sqrt( x : Float ) : Float {
			if (x == 0)
			{
				return 0;
			}else
			{
				return 1 / invSqrt(x);
			}
	    }
		/**
		 * 
		 * @param	val1
		 * @param	val2 must be >=0;
		 * @return  Math.pow(val1,val2)
		 */
		public static inline function powInt(val1:Float, val2:Int):Float
		{
			var value:Float = 1.0;
			for ( i in 0...val2)
			{
				value *= val1;
			}
			return value;
		}
		public static inline function abs( x : Float):Float
		{
			return (x < 0) ? -x : x;
		}
		public static inline function min(a:Float, b:Float):Float
		{
			return (a < b) ? a : b;
		}
		public static inline function max(a:Float, b:Float):Float
		{
			return (a > b) ? a : b;
		}
		public static inline function minInt(a:Int, b:Int):Int
		{
			return (a < b) ? a : b;
		}
		public static inline function maxInt(a:Int, b:Int):Int
		{
			return (a > b) ? a : b;
		}
	}
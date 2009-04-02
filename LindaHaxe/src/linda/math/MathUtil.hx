package linda.math;
import flash.Memory;
class MathUtil
{
		public static inline var RADTODEG : Float = 180/Math.PI;		
		public static inline var DEGTORAD : Float = Math.PI / 180;
		public static inline var TWO_PI : Float = Math.PI * 2.0;
		public static inline var PI:Float = Math.PI;
		public static inline var ONE_EIGHTY_OVER_PI : Float = 180. / Math.PI;
		public static inline var PI_OVER_ONE_EIGHTY : Float = Math.PI / 180.;
		
		private static inline var sincosParam:Float = 1 / 441009855.21060102566599663103894;
		
		public static inline var ROUNDING_ERROR : Float = 0.0000001;
        
		public static inline var MAX_VALUE:Float = untyped __global__["Number"].MAX_VALUE;
		
		public static inline var MIN_VALUE:Float = untyped __global__["Number"].MIN_VALUE;
		
		public static inline var NaN:Float       = untyped __global__["NaN"];
		
		public static inline var POSITIVE_INFINITY:Float = untyped __global__["Number"].POSITIVE_INFINITY;
		
		public static inline var NEGATIVE_INFINITY:Float = untyped __global__["Number"].NEGATIVE_INFINITY;

		public static inline function equals (a : Float, b : Float) : Bool
		{
			return (a + ROUNDING_ERROR > b) && (a - ROUNDING_ERROR < b);
		}
		
		public static inline function isNaN(c:Dynamic):Bool 
		{
			return untyped __global__["isNaN"](c);
		}
		
		public static inline function uint(value:Float):UInt
		{
			return absInt(Std.int(value));
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
            var sin:Int = (f - ((f * ((f < 0)? -f:f)) >> 15)) * 41721;
            var ssin:Int = sin >> 15;
            return (((ssin * (sin < 0? -ssin:ssin)) >> 9) * 467 + sin) * sincosParam;
		}
		public static inline function cos(angle:Float):Float
		{
			var f:Int = (Std.int(angle * 683565275.57643158978229477811035) + 1073741824) >> 16;
            var sin:Int = (f - ((f * ((f < 0)? -f:f)) >> 15)) * 41721;
            var ssin:Int = sin >> 15;
            return (((ssin * (sin < 0? -ssin:ssin)) >> 9) * 467 + sin) * sincosParam;
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

		public static inline function abs( x : Float):Float
		{
			return (x < 0) ? -x : x;
		}
		
		public static inline function absInt( x : Int):Int
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
		public static inline function getAngleWeight(v1:Vector3,v2:Vector3,v3:Vector3):Vector3
		{
			// Calculate this triangle's weight for each of its three vertices
			// start by calculating the lengths of its sides
			var a:Float = Vector3.distanceSquared(v2,v3);
			var asqrt:Float = sqrt(a);
			var b:Float = Vector3.distanceSquared(v1,v3);
			var bsqrt:Float = sqrt(b);
			var c:Float = Vector3.distanceSquared(v1,v2);
			var csqrt:Float = sqrt(c);

			// use them to find the angle at each vertex
			return new Vector3( cos((b + c - a) / (2. * bsqrt * csqrt)),
				                cos((-b + c + a) / (2. * asqrt * csqrt)),
				                cos((b - c + a) / (2. * bsqrt * asqrt)));
		}
		
		
		 //test 100000 times,this take 13ms,and Math.floor take 22ms
		public static inline function floor(d:Float):Int
		{
			if (d < 0.0)
   		 	{
    	 	  var f:Int = Std.int(d);
    	 	  if (f != d) f -= 1;
			  return f;
    	 	}else {
				return Std.int(d);
			}
		}
		
		/**
  	     * This method produces identical results to Math.ceil() for all normal input values
  	      * (one which fall inside the allowed range of the int type).
  	      */

  	    public static inline function ceil(d:Float):Int
  	    {
   	        if (d > 0.0)
  	        {
  	          var f:Int = Std.int(d);
   	          if (f != d) f += 1;
              return f;
            }else
			{
				return Std.int(d);
			}
        }

        /**
         * This method produces identical results to Math.round() for all normal input values
         * (one which fall inside the allowed range of the int type).
         */

        public static inline function round(d:Float):Int
        {
            return floor(d+0.5);
        }

        /**
         * This method produces results which are nearly identical to Math.pow(), although the
         * last few digits may be different due to numerical error.  Unlike Math.pow(), this
         * method requires the exponent to be an integer.
         */
        //test 100000 times,this take 4ms,and Math.pow take 18ms
        public static inline function pow( base:Float, exponent:Int):Float
        {
            if (exponent < 0)
            {
              exponent = -exponent;
              base = 1.0/base;
            }
            var result:Float = 1.0;
            while (exponent != 0)
            {
              if ((exponent&1) == 1)
                result *= base;
              base *= base;
              exponent = exponent>>1;
            }
            return result;
        }

        /**
         * This method calculates a fast approximation to the arctan function.  It differs from
         * the true value by no more than 0.005 for any input value.
         * <p>
         * I found this formula on an internet discussion board post by Ranko Bojanic.  The reference
         * cited in that post was
         * <p>
         * Approximation Theory (C. Hastings, Jr., Note 143, Math. Tables Aids. Comp 6, 68 (1953))
         */
        //test 100000 times,this take 15ms,and Math.pow take 28ms
        public static inline function atan(d:Float):Float
        {
            if (d >= 1.0)
		    {
                return (0.5 * PI - d / (d * d + 0.28));
            }else if (d <= -1.0)
		    {
                return ( -0.5 * PI - d / (d * d + 0.28));
		    }else
		    {  
                return (d / (1.0 + 0.28 * d * d));
		    }
        }
}
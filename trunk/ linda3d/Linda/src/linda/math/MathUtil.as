package linda.math
{
	public class MathUtil
	{
		public static const ROUNDING_ERROR : Number = 0.0001;
		public static const ONE_EIGHTY_OVER_PI : Number = 180. / Math.PI;//57.2957795
		public static const PI_OVER_ONE_EIGHTY : Number = Math.PI / 180.;//0.01745329
		public static const TWO_PI : Number = Math.PI * 2.0;
		/**
		* 近似相等
		*/
		public static function equals (a : Number, b : Number) : Boolean
		{
			return (a + ROUNDING_ERROR > b) && (a - ROUNDING_ERROR < b);
		}
		//确保值idx在0...size-1之间
		public static function clamp(idx:int,size:int):int
		{
			return (idx < 0 ? size+idx : (idx>=size ? idx-size : idx));
		}
		
		/**Fast sine and cosine
		 * @see http://blog.haxe.org
		 * 
		 * sine
		 *   var f:int = int(angle * 683565275.57643158978229477811035) >> 16;
             var sin:int = (f - ((f * ((f < 0)?-f:f)) >> 15)) * 41721;
             var ssin:int = sin >> 15;
             return (((ssin * (sin < 0?-ssin:ssin)) >> 9) * 467 + sin) / 441009855.21060102566599663103894;
           * 
           * 
           * cosine
           * 
           * var f:int = (int(angle * 683565275.57643158978229477811035) + 1073741824) >> 16;
             var sin:int = (f - ((f * ((f < 0)?-f:f)) >> 15)) * 41721;
             var ssin:int = sin >> 15;
             return (((ssin * (sin < 0?-ssin:ssin)) >> 9) * 467 + sin) / 441009855.21060102566599663103894;
           * 
		 */
	}
}

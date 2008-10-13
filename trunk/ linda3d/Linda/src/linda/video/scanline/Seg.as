package linda.video.scanline
{
/** class: Seg
 * Segment used with SBuffer to render a line segment on screen
*/
	internal class Seg 
	{
		// prev seg and next segment pointers
		public var prev:Seg;
		public var next:Seg;

		// x0: start x value | x1: end x value
		public var x0:Number;
		public var x1:Number;

		// z value @ x = 0
		public var z0:Number;

		// z slope
		public var dzdx:Number;

		// material pointer
		public var m:Mat;

		public function Seg() 
		{
			x0 = x1 = 0;
			z0 = dzdx = 0;
			prev = next = null;
			m = null;
		}		
	}
}

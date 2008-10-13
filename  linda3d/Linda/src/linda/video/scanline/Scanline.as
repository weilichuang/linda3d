package linda.video.scanline
{
	/** class:Scanline
	 * Used with SBuffer to render a horizontal line on screen
	 */
	internal class Scanline 
	{
		// count of segments in line
		public var n:int;
		public var na:int;
		
		// first segment
		public var first:Seg;
		public var firstAlpha:Seg;

		public function Scanline()
		{
			n = 0;
			na = 0;
			first = null;
			firstAlpha = null;
		}
	}
}
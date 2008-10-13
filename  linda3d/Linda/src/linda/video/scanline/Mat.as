package linda.video.scanline
{
	import flash.display.BitmapData;
	
	internal class Mat 
	{
		// type of material - instructs renderer
		public var p:int;
		
		// perspective correct texture mapping
		public var pc:Boolean;
		
		// x edges 
		public var lx0:Number, rx0:Number;
		public var ldxdy:Number, rdxdy:Number;
		
		// r edges
		public var lr0:Number, rr0:Number;
		public var ldrdy:Number, rdrdy:Number;
		
		// g edges
		public var lg0:Number, rg0:Number;
		public var ldgdy:Number, rdgdy:Number;
		
		// b edges
		public var lb0:Number, rb0:Number;
		public var ldbdy:Number, rdbdy:Number;

		// u edges
		public var lu0:Number, ru0:Number;
		public var ldudy:Number, rdudy:Number;
		
		// v edges
		public var lv0:Number, rv0:Number;
		public var ldvdy:Number, rdvdy:Number;

		// texture pointer
		public var t:BitmapData;

		public function Mat()
		{
			p = 1;
			pc = true;
		}
	}
}
package linda.math
{
	import flash.geom.Rectangle;
	
	public class Dimension2D
	{
		public var width:Number;
		public var height:Number;
		public function Dimension2D(width:Number=0,height:Number=0)
		{
			this.width=width;
			this.height=height;
		}
		public function toRect():Rectangle
		{
			return new Rectangle(0,0,width,height);
		}
		public function toString () : String
		{
			return "[Dimension2D(width: " + width + ", height: " + height + ")]\n";
		}

	}
}
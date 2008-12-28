package linda.math;

	import flash.geom.Rectangle;
	
	class Dimension2D
	{
		public var width:Int;
		public var height:Int;
		public function new(?width:Int=0,?height:Int=0)
		{
			this.width=width;
			this.height=height;
		}
		public inline function toRect():Rectangle
		{
			return new Rectangle(0,0,width,height);
		}
		public function toString () : String
		{
			return "[Dimension2D(" + width + "," + height + ")";
		}
		public inline function clone():Dimension2D
		{
			return new Dimension2D(width, height);
		}

	}
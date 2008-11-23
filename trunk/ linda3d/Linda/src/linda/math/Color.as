package linda.math
{
	public class Color
	{
		public var r : int ;
		public var g : int ;
		public var b : int ;
		public function Color (r : int = 0, g : int = 0, b : int = 0)
		{
			this.r = r;
			this.g = g;
			this.b = b;
		}
		public function get color () : uint
		{
			return uint (r << 16 | g << 8 | b);
		}
		public function set color (color : uint) : void
		{
			r = color >> 16 & 0xFF ;
			g = color >> 8 & 0xFF ;
			b = color & 0xFF ;
		}
		public function toString () : String
		{
			return "Color = " + color + " ,r= " + r + " ,g= " + g + " ,b= " + b ;
		}
		public function setRGB (r : int, g : int, b : int) : void
		{
			color = (r << 16 | g << 8 | b);
			this.r = r;
			this.g = g;
			this.b = b;
		}
		public function clone () : Color
		{
			return new Color (r, g, b);
		}
		public function getLuminance():Number
		{
			return 0.3*r + 0.59*g + 0.11*b;
		}
		public function  getAverage():Number
		{
			return ( r + g + b ) * 0.333;
		}
		public function copy (other : Color) : void
		{
			r = other.r;
			g = other.g;
			b = other.b;
		}
		public function getInterpolated(other:Color,d:Number):Color
		{
			if(d < 0) d=0;
			if(d > 1) d=1;
			
			var inv:Number= 1-d;
			var c:Color=new Color();
			c.r=r*d+inv*other.r;
			c.g=g*d+inv*other.g;
			c.b=b*d+inv*other.b;
			return c;
		}
	}
}

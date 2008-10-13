package linda.math
{
	public class Color
	{
		public var a : int = 0;
		public var r : int = 0;
		public var g : int = 0;
		public var b : int = 0;
		public function Color (r : int = 0, g : int = 0, b : int = 0, a : int = 0xFF)
		{
			setRGBA (r, g, b, a );
		}
		public function setRGBA (r : int, g : int, b : int, a : int = 0xFF) : void
		{
			this.r = r;
			this.g = g;
			this.b = b;
			this.a = a;
		}
		public function get color () : uint
		{
			return uint (a << 24 | r << 16 | g << 8 | b);
		}
		public function set color (color : uint) : void
		{
			a = color >> 24 & 0xFF ;
			r = color >> 16 & 0xFF ;
			g = color >> 8 & 0xFF ;
			b = color & 0xFF ;
		}
		public function toString () : String
		{
			return "Color = " + color + " ,r= " + r + " ,g= " + g + " ,b= " + b + " ,a= " + a;
		}
		public function setRGB (r : int, g : int, b : int) : void
		{
			color = (r << 16 | g << 8 | b);
			a = 0xFF;
			this.r = r;
			this.g = g;
			this.b = b;
		}
		public function clone () : Color
		{
			return new Color (r, g, b, a);
		}
		public function getLuminance():Number
		{
			return 0.3*r + 0.59*g + 0.11*b;
		}
		public function  getAverage():Number
		{
			return ( r + g + b ) / 3;
		}
		public function copy (other : Color) : void
		{
			a = other.a;
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
			c.a=a*d+inv*other.a;
			c.r=r*d+inv*other.r;
			c.g=g*d+inv*other.g;
			c.b=b*d+inv*other.b;
			return c;
		}
	}
}

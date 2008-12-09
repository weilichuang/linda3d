package linda.math;

class Color
{
	public var r : Int ;
	public var g : Int ;
	public var b : Int ;
	
	public inline var color(getColor, setColor):UInt;
	
	public static inline var RED:Color   = new Color(255, 0, 0);
	public static inline var GREEN:Color = new Color(0, 255, 0);
	public static inline var BLUE:Color  = new Color(0, 0, 255);
	public static inline var WHITE:Color = new Color(255, 255, 255);
	public static inline var BLACK:Color = new Color(0, 0, 0);
	
	public function new (r : Int = 0, g : Int = 0, b : Int = 0)
	{
		this.r = r;
		this.g = g;
		this.b = b;
	}
	public inline function getColor () : UInt
	{
		return  (r << 16 | g << 8 | b);
	}
	public inline function setColor (color : UInt) : UInt
	{
		r = color >> 16 & 0xFF ;
		g = color >> 8 & 0xFF ;
		b = color & 0xFF ;
		return color;
	}
	public inline function clone () : Color
	{
		return new Color (r, g, b);
	}
	public inline function getLuminance():Float
	{
		return 0.3*r + 0.59*g + 0.11*b;
	}
	public inline function  getAverage():Float
	{
		return ( r + g + b ) * 0.333;
	}
	public inline function copy (other : Color) : Void
	{
		r = other.r;
		g = other.g;
		b = other.b;
	}
	public inline function getInterpolated(other:Color,d:Float):Color
	{
		if(d < 0) d=0;
		if(d > 1) d=1;
			
		var inv:Float= 1-d;
		var c:Color=new Color();
		c.r=Std.int(r*d+inv*other.r);
		c.g=Std.int(g*d+inv*other.g);
		c.b=Std.int(b*d+inv*other.b);
		return c;
	}
	public function toString () : String
	{
		return "[Color(" + color + "," + r + "," + g + "," + b + ")]";
	}
}

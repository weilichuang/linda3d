package linda.math
{
	public class Vector2D
	{
		public var x : Number;
		public var y : Number;
		public function Vector2D (x : Number = 0, y : Number = 0)
		{
			this.x = x;
			this.y = y;
		}
		public function add(other : Vector2D) : Vector2D
		{
			return new Vector2D (x + other.x, y + other.y);
		}
		public function subtract (other : Vector2D) : Vector2D
		{
			return new Vector2D (x - other.x, y - other.y);
		}
		public function getLength () : Number
		{
			return Math.sqrt (x * x + y * y);
		}
		public function toString () : String
		{
			return "[Vector2D(x: " + int (x * 1000) / 1000 + ", y: " + int (y * 1000) / 1000 + ")]\n";
		}
		public function clone () : Vector2D
		{
			return new Vector2D (x, y);
		}
		public function copy (other : Vector2D) : void
		{
			x = other.x;
			y = other.y;
		}
		public function normalize () : void
		{
			var n : Number = Math.sqrt (x * x + y * y);
			n = (n < 0.0001) ? 0 : 1/n;
			x *= n;
			y *= n;
		}
	}
}

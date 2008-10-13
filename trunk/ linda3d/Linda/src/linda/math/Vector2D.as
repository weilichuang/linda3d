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
		public function setXY (x : Number, y : Number) : void
		{
			this.x = x;
			this.y = y;
		}
		public function addE (other : Vector2D) : void
		{
			x += other.x;
			y += other.y;
		}
		public function add (other : Vector2D) : Vector2D
		{
			return new Vector2D (x + other.x, y + other.y);
		}
		public function subtract (other : Vector2D) : Vector2D
		{
			return new Vector2D (x - other.x, y - other.y);
		}
		public function subtractE (other : Vector2D) : void
		{
			x -= other.x;
			y -= other.y;
		}
		/**
		* cos=(a.b)/(|a||b|)
		* 有时候并不需要求出夹角的具体值，可能只需要用余弦(或正弦)来和某个数相比较就行了。
		* 提高速度。
		* @return Number 两个向量的夹角的余弦
		*/
		public function cosTh (other : Vector2D) : Number
		{
			return (x * other.x + y * other.y) / Math.sqrt ((x * x + y * y) * (other.x * other.x + other.y * other.y));
		}
		public function equals (other : Vector2D) : Boolean
		{
			return (x == other.x && y == other.y );
		}
		/**
		*返回向量的模
		*/
		public function getLength () : Number
		{
			return Math.sqrt (x * x + y * y);
		}
		public function toString () : String
		{
			return "[Vector2D(x: " + int (x * 1000) / 1000 + ", y: " + int (y * 1000) / 1000 + ")]\n";
		}
		//克隆该向量的值
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
			var n : Number = getLength ();
			if (n == 0) return ;
			n = 1.0 / n;
			x *= n;
			y *= n;
		}
	}
}

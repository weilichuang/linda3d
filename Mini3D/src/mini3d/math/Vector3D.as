package mini3d.math
{
	public class Vector3D
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function Vector3D(x:Number=0,y:Number=0,z:Number=0)
		{
			this.x=x;
			this.y=y;
			this.z=z;
		}
		public function subtract(other:Vector3D):Vector3D
		{
			return new Vector3D(x-other.x,y-other.y,z-other.z);
		}
		public function add(other:Vector3D):Vector3D
		{
			return new Vector3D(x+other.x,y+other.y,z+other.z);
		}
		
		public function decrementBy(other:Vector3D):void
		{
			x-=other.x;
			y-=other.y;
			z==other.z;
		}
		
		public function incrementBy(other:Vector3D):void
		{
			x-=other.x;
			y-=other.y;
			z==other.z;
		}
		
		public function negate():void
		{
			x=-x;
			y=-y;
			z=-z;
		}

		public function scale(s:Number):Vector3D
		{
			return new Vector3D(s*x,s*y,s*z); 
		}
		public function scaleBy(s:Number):void
		{
			x*=s;
			y*=s;
			z*=s;
		}
		public function normalize():void
		{
			var n : Number = Math.sqrt (x * x + y * y + z * z);
			if (n == 0) return;
			n = 1 / n;
			x *= n;
			y *= n;
			z *= n;
		}
		/**
		*点乘dotProduct（a.b）,点乘满足交换率a.b=b.a，点乘可求两个向量间的夹角。
		*公式：a.b=|a||b|cos(i)
		*|a|表示a的模，cos（i）表示Math.cos(i),
		*所以 夹角i为: i=Math.acos((a.b)/(|a||b|));
		*结论: a.b          i              a和b
		*      >0      0<=i<90           方向基本相同
		*      >0      i<=90             正交（即垂直）
		*      <0      90<i<=180         方向基本相反
		*/
		public function dotProduct(other : Vector3D) : Number
		{
			return (x * other.x + y * other.y + z * other.z);
		}
		/**
		*叉乘crossProduct（aXb），满足反交换律:aXb=-(bXa),叉乘得到的向量垂直于原来的两个向量，常用来求平面的法向量。
		*  |x1|      |x2|     | y1*z2-z1*y2 |
		*  |y1|  X   |y2|  =  | z1*x2-x1*z2 |
		*  |z1|      |z2|     | x1*y2-y1*x2 |
		*/
		public function crossProduct (other : Vector3D) : Vector3D
		{
			return new Vector3D (y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other.x);
		}
		public function get length() : Number
		{
			return Math.sqrt (x * x + y * y + z * z);
		}
		public function get lengthSquared() : Number
		{
			return (x * x + y * y + z * z);
		}
		public static function distance(v0:Vector3D,v1:Vector3D):Number
		{
			var vx : Number = v0.x - v1.x;
			var vy : Number = v0.y - v1.y;
			var vz : Number = v0.z - v1.z;
			return Math.sqrt(vx * vx + vy * vy + vz * vz);
		}
		public function copy(other:Vector3D):void
		{
			this.x=other.x;
			this.y=other.y;
			this.z=other.z;
		}
		public function clone():Vector3D
		{
			return new Vector3D(x,y,z);
		}

	}
}
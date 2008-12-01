package linda.math;

	class Vector3
	{
		public var x:Float;
		public var y:Float;
		public var z:Float;

		public function new(?x:Float=0.,?y:Float=0.,?z:Float=0.)
		{
			this.x=x;
			this.y=y;
			this.z=z;
		}
		public inline function subtract(other:Vector3):Vector3
		{
			return new Vector3(x-other.x,y-other.y,z-other.z);
		}
		public inline function add(other:Vector3):Vector3
		{
			return new Vector3(x+other.x,y+other.y,z+other.z);
		}
		public inline function decrementBy(other:Vector3):Void
		{
			x -= other.x;
			y -= other.y;
			z -= other.z;
		}
		public inline function incrementBy(other:Vector3):Void
		{
			x += other.x;
			y += other.y;
			z += other.z;
		}
		public inline function negate():Void
		{
			x = -x;
			y = -y;
			z = -z;
		}
		public inline function scale(s:Float):Vector3
		{
			return new Vector3(s*x,s*y,s*z); 
		}
		public inline function scaleBy(s:Float):Void
		{
			x *= s;
			y *= s;
			z *= s;
		}
		public inline function normalize():Void
		{
			var sq:Float = getLengthSquared();
			if ( sq < MathUtil.ROUNDING_ERROR ) sq = 0 else sq = MathUtil.invSqrt(sq);
			x *= sq;
			y *= sq;
			z *= sq;
		}
		public inline function dotProduct(other : Vector3) : Float
		{
			return (x * other.x + y * other.y + z * other.z);
		}
		public inline function crossProduct (other : Vector3) : Vector3
		{
			return new Vector3 (y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other.x);
		}
		public inline function getLength() : Float
		{
			return MathUtil.sqrt (x * x + y * y + z * z);
		}
		public inline function getLengthSquared() : Float
		{
			return (x * x + y * y + z * z);
		}
		public static inline function distance(v0:Vector3,v1:Vector3):Float
		{
			var vx : Float = v0.x - v1.x;
			var vy : Float = v0.y - v1.y;
			var vz : Float = v0.z - v1.z;
			return MathUtil.sqrt(vx * vx + vy * vy + vz * vz);
		}
		public inline function copy(other:Vector3):Void
		{
			this.x = other.x;
			this.y = other.y;
			this.z = other.z;
		}
		public inline function clone():Vector3
		{
			return new Vector3(x,y,z);
		}
		public function toString () : String
		{
			return "[Vector3(" + x + "," + y + "," + z + ")";
		}
	}
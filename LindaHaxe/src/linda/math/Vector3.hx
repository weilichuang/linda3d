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
		public inline function equals(other:Vector3):Bool 
		{
			return x == other.x && y == other.y && z == other.z;
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
		public static inline function distanceSquared(v0:Vector3,v1:Vector3):Float
		{
			var vx : Float = v0.x - v1.x;
			var vy : Float = v0.y - v1.y;
			var vz : Float = v0.z - v1.z;
			return (vx * vx + vy * vy + vz * vz);
		}
		public inline function getHorizontalAngle():Vector3
		{
			var angle:Vector3=new Vector3();

			angle.y = Math.atan2(x, z);

			if (angle.y < 0.0)
				angle.y += MathUtil.TWO_PI;
			if (angle.y >= MathUtil.TWO_PI)
				angle.y -= MathUtil.TWO_PI;

			var z1:Float = MathUtil.sqrt(x*x + z*z);

			angle.x = Math.atan2(z1, y)  - Math.PI/2;

			if (angle.x < 0.0)
				angle.x += MathUtil.TWO_PI;
			if (angle.x >= MathUtil.TWO_PI)
				angle.x -= MathUtil.TWO_PI;

			return angle;
		}

		/**
		 * 
		 * Builds a direction vector from (this) rotation vector.
		 * This vector is assumed to be a rotation vector composed of 3 Euler angle rotations, in degrees.
		 * The implementation performs the same calculations as using a matrix to do the rotation.

		 * @param[in] forwards  The direction representing "forwards" which will be rotated by this vector. 
		 * If you do not provide a direction, then the +Z axis (0, 0, 1) will be assumed to be forwards.
		 * @return A direction vector calculated by rotating the forwards direction by the 3 Euler angles 
		 * (in degrees) represented by this vector. 
		 */
		public inline function rotationToDirection(?forwards:Vector3=null):Vector3
		{
			if (forwards == null)
			{
				forwards = new Vector3(0, 0, 1);
			}
			var cr:Float = MathUtil.cos( MathUtil.DEGTORAD * x );
			var sr:Float = MathUtil.sin( MathUtil.DEGTORAD * x );
			var cp:Float = MathUtil.cos( MathUtil.DEGTORAD * y );
			var sp:Float = MathUtil.sin( MathUtil.DEGTORAD * y );
			var cy:Float = MathUtil.cos( MathUtil.DEGTORAD * z );
			var sy:Float = MathUtil.sin( MathUtil.DEGTORAD * z );

			var srsp:Float = sr*sp;
			var crsp:Float = cr * sp;
			
			return new Vector3(
				    (forwards.x * (cp*cy) +
					forwards.y * (srsp*cy-cr*sy) +
					forwards.z * (crsp*cy+sr*sy)),
				    (forwards.x * (cp*sy) +
					forwards.y * (srsp*sy+cr*cy) +
					forwards.z * (crsp*sy-sr*cy)),
				    (forwards.x * (-sp) +
					forwards.y * (sr*cp) +
					forwards.z * (cr * cp))
					);
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
			return "[Vector3(" + x + "," + y + "," + z + ")]";
		}
}
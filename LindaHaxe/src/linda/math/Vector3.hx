package linda.math;
import linda.video.ILineRenderer;

/** 
 * The vector3d class is used for three main purposes: 
 *	1) As a direction vector (most of the methods assume this).
 *	2) As a position in 3d space (which is synonymous with a direction vector from the origin to this position).
 *	3) To hold three Euler rotations, where X is pitch, Y is yaw and Z is roll.
 */
class Vector3
{
		public var x:Float;
		public var y:Float;
		public var z:Float;

		public function new(?x:Float=0.,?y:Float=0.,?z:Float=0.)
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		public inline function setXYZ(x:Float, y:Float, z:Float):Void 
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		public inline function subtract(other:Vector3):Vector3
		{
			return new Vector3(x - other.x, y - other.y, z - other.z);
		}
		public inline function add(other:Vector3):Vector3
		{
			return new Vector3(x + other.x, y + other.y, z + other.z);
		}
		public inline function subtractBy(other:Vector3):Void
		{
			x -= other.x;
			y -= other.y;
			z -= other.z;
		}
		public inline function addBy(other:Vector3):Void
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
			return new Vector3(s * x, s * y, s * z);
		}
		public inline function scaleBy(s:Float):Void
		{
			x *= s;
			y *= s;
			z *= s;
		}

		/** 
		 * Returns if this vector interpreted as a point is on a line between two other points.
		 * It is assumed that the point is on the line.
		 * @param begin Beginning vector to compare between.
		 * @param end Ending vector to compare between.
		 * @return True if this vector is between begin and end, false if not.
		 */
		public inline function isBetweenPoints(begin:Vector3, end:Vector3):Bool
		{
			var f:Float = Vector3.distanceSquared(begin, end);
			return getDistanceFromSquared(begin) <= f && getDistanceFromSquared(end) <= f;
		}
		
		/**Normalizes the vector.
		 * In case of the 0 vector the result is still 0, otherwise
		 * the length of the vector will be 1.
		 * @return Reference to this vector after normalization. 
		 */
		public inline function normalize():Vector3
		{
			var sq:Float = MathUtil.invSqrt(getLengthSquared());
			x *= sq;
			y *= sq;
			z *= sq;
			return this;
		}
		//Get the dot product with another vector.
		public inline function dotProduct(other : Vector3) : Float
		{
			return (x * other.x + y * other.y + z * other.z);
		}
		// Calculates the cross product with another vector.
		public inline function crossProduct (other : Vector3) : Vector3
		{
			return new Vector3 (y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other.x);
		}
		// Get length of the vector.
		public inline function getLength() : Float
		{
			return MathUtil.sqrt (x * x + y * y + z * z);
		}
		// Sets the length of the vector to a new value
		public inline function setLength(newlength:Float):Void 
		{
			normalize();
			scale(newlength);
		}
		// Get squared length of the vector.
		public inline function getLengthSquared() : Float
		{
			return (x * x + y * y + z * z);
		}
		
		//! Get distance from another point.
		/** Here, the vector is interpreted as point in 3 dimensional space. */
		public inline function getDistanceFrom(other:Vector3):Float
		{
			var vx : Float = x - other.x;
			var vy : Float = y - other.y;
			var vz : Float = z - other.z;
			return MathUtil.sqrt(vx * vx + vy * vy + vz * vz);
		}

		//! Returns squared distance from another point.
		/** Here, the vector is interpreted as point in 3 dimensional space. */
		public inline function getDistanceFromSquared(other:Vector3):Float
		{
			var vx : Float = x - other.x;
			var vy : Float = y - other.y;
			var vz : Float = z - other.z;
			return (vx * vx + vy * vy + vz * vz);
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

		/** 
		 * Get the rotations that would make a (0,0,1) direction vector point in the same direction as this direction vector.
		 * Thanks to Arras on the Irrlicht forums for this method.  This utility method is very useful for
		 *orienting scene nodes towards specific targets.  For example, if this vector represents the difference
		 *between two scene nodes, then applying the result of getHorizontalAngle() to one scene node will point
		 *it at the other one.
		 *Example code:
		 *Where target and seeker are of type ISceneNode
		 *var toTarget:Vector3=(target.getAbsolutePosition() - seeker.getAbsolutePosition());
		 *var requiredRotation:Vector3 = toTarget.getHorizontalAngle();
		 *seeker.setRotation(requiredRotation); 
		 *@return A rotation vector containing the X (pitch) and Y (raw) rotations (in degrees) that when applied to a 
		 *+Z (e.g. 0, 0, 1) direction vector would make it point in the same direction as this vector. The Z (roll) rotation 
		 *is always 0, since two Euler rotations are sufficient to point in any given direction. 
		 */
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
		
		
		
		/**Rotates the vector by a specified number of degrees around the Y axis and the specified center. 
		 * @param degrees Number of degrees to rotate around the Y axis.
		 * @param center The center of the rotation. 
		 */
		public inline function rotateXZBy(degrees:Float, center:Vector3):Void
		{
			degrees *= MathUtil.DEGTORAD;
			var cs:Float = MathUtil.cos(degrees);
			var sn:Float = MathUtil.sin(degrees);
			x -= center.x;
			z -= center.z;
			setXYZ((x * cs - z * sn), y, (x * sn + z * cs));
			x += center.x;
			z += center.z;
		}

		/** 
		 * Rotates the vector by a specified number of degrees around the Z axis and the specified center.
		 * @param degrees: Number of degrees to rotate around the Z axis.
		 * @param center: The center of the rotation. 
		 */
		public inline function  rotateXYBy(degrees:Float, center:Vector3):Void
		{
			degrees *= MathUtil.DEGTORAD;
			var cs:Float = MathUtil.cos(degrees);
			var sn:Float = MathUtil.sin(degrees);
			x -= center.x;
			y -= center.y;
			setXYZ((x*cs - y*sn), (x*sn + y*cs), z);
			x += center.x;
			y += center.y;
		}

		/** 
		 * Rotates the vector by a specified number of degrees around the X axis and the specified center.
		 * @param degrees: Number of degrees to rotate around the X axis.
		 * @param center: The center of the rotation. 
		 */
		public inline function  rotateYZBy(degrees:Float, center:Vector3):Void
		{
			degrees *= MathUtil.DEGTORAD;
			var cs:Float = MathUtil.cos(degrees);
			var sn:Float = MathUtil.sin(degrees);
			z -= center.z;
			y -= center.y;
			setXYZ(x, (y*cs - z*sn), (y*sn + z*cs));
			z += center.z;
			y += center.y;
		}

		//! Creates an interpolated vector between this vector and another vector.
		/** 
		 * \param other The other vector to interpolate with.
		 * \param d Interpolation value between 0.0f (all the other vector) and 1.0f (all this vector).
		 * Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
		 * \return An interpolated vector.  This vector is not modified. 
		 */
		public inline function getInterpolated(other:Vector3,d:Float):Vector3
		{
			var inv:Float = 1.0 - d;
			return new Vector3((other.x*inv + x*d), (other.y*inv + y*d), (other.z*inv + z*d));
		}

		/** 
		 * Creates a quadratically interpolated vector between this and two other vectors.
		 * @param v2 Second vector to interpolate with.
		 * @param v3 Third vector to interpolate with (maximum at 1.0f)
		 * @param d Interpolation value between 0.0f (all this vector) and 1.0f (all the 3rd vector).
		 * Note that this is the opposite direction of interpolation to getInterpolated() and interpolate()
		 * @return An interpolated vector. This vector is not modified. 
		 */
		public inline function getQuadraticInterpolated(v2:Vector3,v3:Vector3,d:Float):Vector3
		{
			// this*(1-d)*(1-d) + 2 * v2 * (1-d) + v3 * d * d;
			var inv:Float = 1.0 - d;
			var mul0:Float = inv * inv;
			var mul1:Float = 2.0 * d * inv;
			var mul2:Float = d * d;

			return new Vector3((x * mul0 + v2.x * mul1 + v3.x * mul2),
					           (y * mul0 + v2.y * mul1 + v3.y * mul2),
					           (z * mul0 + v2.z * mul1 + v3.z * mul2));
		}

		//! Sets this vector to the linearly interpolated vector between a and b.
		/** \param a first vector to interpolate with, maximum at 1.0f
		\param b second vector to interpolate with, maximum at 0.0f
		\param d Interpolation value between 0.0f (all vector b) and 1.0f (all vector a)
		Note that this is the opposite direction of interpolation to getInterpolated_quadratic()
		*/
		public inline function interpolate(a:Vector3,b:Vector3,d:Float):Void
		{
			x = (b.x + ( a.x - b.x ) * d );
			y = (b.y + ( a.y - b.y ) * d );
			z = (b.z + ( a.z - b.z ) * d );
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
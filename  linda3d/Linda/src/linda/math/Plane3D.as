﻿package linda.math
{
	import flash.geom.Vector3D;
	
	public class Plane3D
	{
		public var normal : Vector3D ;
		public var d : Number;
		public static const IS_FRONT : int = 0;
		public static const IS_BACK : int = 1;
		public static const IS_PLANAR : int = 2;
		public static const IS_SPANNING : int = 3;
		public static const IS_CLIPPED : int = 4;
		public function Plane3D (n : Vector3D = null, d : Number = 0)
		{
			if (n)
			{
				normal = n;
			}else
			{
				normal= new Vector3D ();
			}
			this.d = d;
		}
		public function equals (other : Plane3D) : Boolean
		{
			return d == other.d && normal.equals (other.normal);
		}
		public function setPlane2 (point : Vector3D, nor : Vector3D) : void
		{
			if (point == null || nor == null) return;
			normal = nor;

			var n : Number = Math.sqrt (normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
			if (n == 0) return;
			n = 1 / n;
			normal.x *= n;
			normal.y *= n;
			normal.z *= n;
			d = - (normal.x * point.x + normal.y * point.y + normal.z * point.z);
		}
		public function setPlane (normal : Vector3D, d : Number) : void
		{
			this.normal = normal;
			this.d = d;
		}
		public function setPlane3 (p1 : Vector3D, p2 : Vector3D, p3 : Vector3D) : void
		{
			var sp0 : Vector3D = new Vector3D ();
			sp0.x = p2.x - p1.x;
			sp0.y = p2.y - p1.y;
			sp0.z = p2.z - p1.z;
			var sp1 : Vector3D = new Vector3D ();
			sp1.x = p3.x - p1.x;
			sp1.y = p3.y - p1.y;
			sp1.z = p3.z - p1.z;
			normal.x = sp0.y * sp1.z - sp0.z * sp1.y;
			normal.y = sp0.z * sp1.x - sp0.x * sp1.z;
			normal.z = sp0.x * sp1.y - sp0.y * sp1.x
			//normal.normalize();
			var n : Number = Math.sqrt (normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
			if (n == 0) return;
			n = 1 / n;
			normal.x *= n;
			normal.y *= n;
			normal.z *= n;
			//recalculateD(p1);
			d = - (normal.x * p1.x + normal.y * p1.y + normal.z * p1.z);
		}
		/** 返回与直线的交点
		* @param lineVect: Vector of the line to intersect with.直线的向量
		* @param linePoint: Point of the line to intersect with.直线上的一个点
		* @param outIntersection: Place to store the intersection point, if there is one.交点，如果存在的话
		* @return Returns true if there was an intersection, false if there was not.如果交点存在，返回true
		*/
		/**
		* 直线的参数方程为p=p0+v*t;//p0(x0,y0,z0)为直线的点,v(vx,vy,vz)为直线的方向
		
		平面的通用方程a*x+b*y+c*z+d=0;//假设平面的法向量为normal(a,b,c)
		
		把直线带入平面方程中：
		
		a*(x0+vx*t)+b*(y0+vy*t)+c*(z0+vz*t)+d=0
		
		t=-(a*x0+b*y0+c*z0+d)/(a*vx+b*vy+c*vz);
		
		即t=-(normal.dot(p0)+d)/normal.dot(v);
		
		再带入直线的参数方程即可求得交点：
		
		x=x0+vx*t;
		
		y=y0+vy*t;
		
		z=z0+vz*t;
		*/
		public function getIntersectionWithLine (linePoint : Vector3D, lineVect : Vector3D, outIntersection : Vector3D) : Boolean
		{
			var t2 : Number = normal.x * lineVect.x + normal.y * lineVect.y + normal.z * lineVect.z;
			//normal.dot(lineVect);//两个向量垂直，说明直线与平面平行或者被包含
			if (t2 == 0)
			{
				return false;
			}
			//var t:Number = -(normal.dot (linePoint)+d)/t2;
			var t : Number = - (normal.x * linePoint.x + normal.y * linePoint.y + normal.z * linePoint.z + d) / t2;
			//outIntersection = linePoint.add(lineVect.multiplyN(t));
			outIntersection.x = linePoint.x + (lineVect.x * t);
			outIntersection.y = linePoint.y + (lineVect.y * t);
			outIntersection.z = linePoint.z + (lineVect.z * t);
			return true;
		}
		/**
		 * Returns where on a line between two points an intersection with this plane happened.
		 * Only useful if known that there is an intersection.//事先已经知道有交点了
		 * @param linePoint1: Point1 of the line to intersect with.
		 * @param linePoint2: Point2 of the line to intersect with.
		 * @return Returns where on a line between two points an intersection with this plane happened.
		 * For example, 0.5 is returned if the intersection happened exectly in the middle of the two points.
		 */
		public function getKnownIntersectionWithLine (point1 : Vector3D, point2 : Vector3D) : Number 
		{
			//var vect:Vector3D = point2.subtract(point1);
			//var t2:Number = normal.dotProduct(vect);
			//return -((normal.dot (point1)+d)/t2);
			var t2 : Number = (point2.x - point1.x) * normal.x + (point2.y - point1.y) * normal.y + (point2.z - point1.z) * normal.z;
			return - (normal.x * point1.x + normal.y * point1.y + normal.z * point1.z + d) / t2;
		}
		/**
		 * Classifies the relation of a point to this plane.
		 * @param point: Point to classify its relation.
		 * @return Returns ISREL3D_FRONT if the point is in front of the plane,
		 * ISREL3D_BACK if the point is behind of the plane, and
		 * ISREL3D_PLANAR if the point is within the plane.
		 */
		public function classifyPointRelation (point : Vector3D) : int
		{
			//var  t:Number= normal.dot(point) + d;
			var t : Number = normal.x * point.x + normal.y * point.y + normal.z * point.z + d;
			//当点无限接近平面时，我们就认为它在平面上了，这个系数可以调整的
			if (t < - 0.0001) return IS_BACK;
			if (t > 0.0001) return IS_FRONT;
			return IS_PLANAR;
		}
		/**
		 * Recalculates the distance from origin by applying
		 * a new member point to the plane.
		 */
		public function recalculateD (mPoint : Vector3D) : void
		{
			d = - (normal.x * mPoint.x + normal.y * mPoint.y + normal.z * mPoint.z);
		}
		public function getMemberPoint () : Vector3D
		{
			var _memberPoint:Vector3D=new Vector3D();
			_memberPoint.x=- normal.x * d;
			_memberPoint.y=- normal.y * d;
			_memberPoint.z=- normal.z * d;
			return _memberPoint;
		}
		/**
		 * Tests if there is a intersection between this plane and another 是否与其它平面相交
		 * @return Returns true if there is a intersection.
		 */
		public function existsInterSection (other : Plane3D) : Boolean
		{
			var _cross:Vector3D=new Vector3D();
			//var cross:Vector3D = other.normal.cross(normal);
			//return cross.getLength()>0.00000001;
			_cross.x=other.normal.y * normal.z - other.normal.z * normal.y;
			_cross.y=other.normal.z * normal.x - other.normal.x * normal.z;
			_cross.z=other.normal.x * normal.y - other.normal.y * normal.x;
			return (_cross.x * _cross.x + _cross.y * _cross.y + _cross.z * _cross.z) > 0.00000001 ;
		}
		/**
		* @other
		* @outLinePoint  相交直线上的一个点
		* @outLineVect 相交直线的向量
		* @return Returns true if there is a intersection, false if not.
		*/
		public function getIntersectionWithPlane (other : Plane3D, outLinePoint : Vector3D, outLineVect : Vector3D) : Boolean
		{
			// get lengths
			var fn00 : Number = Math.sqrt (normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
			//normal.getLength();
			var fn01 : Number = normal.x * other.normal.x + normal.y * other.normal.y + normal.z * other.normal.z;
			//normal.dot(other.normal);
			var fn11 : Number = Math.sqrt (other.normal.x * other.normal.x + other.normal.y * other.normal.y + other.normal.z * other.normal.z);
			//other.normal.getLength();
			var det : Number = (fn00 * fn11) - (fn01 * fn01);
			// check det
			det = det > 0 ? det : -det;
			if (det < 0.00000001)
			{
				return false;
			}
			det = 1.0 / det;
			var fc0 : Number = ((fn11 * - d) + (fn01 * other.d)) * det;
			var fc1 : Number = ((fn00 * - other.d) + (fn01 * d)) * det;
			outLineVect.x = (normal.y * other.normal.z) - (normal.z * other.normal.y);
			outLineVect.y = (normal.z * other.normal.x) - (normal.x * other.normal.z);
			outLineVect.z = (normal.x * other.normal.y) - (normal.y * other.normal.x);
			outLinePoint.x = (normal.x * fc0) + (other.normal.x * fc1);
			outLinePoint.y = (normal.y * fc0) + (other.normal.y * fc1);
			outLinePoint.z = (normal.z * fc0) + (other.normal.z * fc1);
			// return that we found an intersection
			return true;
		}
		/**
		 *计算3个平面的交点
		 * Returns the intersection point with two other planes if there is one.
		 */
		public function getIntersectionWithPlanes (o1 : Plane3D, o2 : Plane3D, outPoint : Vector3D) : Boolean
		{
			var _linePoint : Vector3D = new Vector3D ();
			var _lineVect : Vector3D = new Vector3D ();
			if (getIntersectionWithPlane (o1, _linePoint, _lineVect))
			{
				return o2.getIntersectionWithLine (_linePoint, _lineVect, outPoint);
			}
			return false;
		}
		/**
		 * Returns if the plane is front of backfacing. Note that this only
		 * works if the normal is Normalized.
		 * @param lookDirection: Look direction.
		 * @return Returns true if the plane is front facing, which mean it would
		 * be visible, and false if it is backfacing.
		 */
		public function isFrontFacing (lookDirection : Vector3D) : Boolean
		{
			//return normal.dotProduct(lookDirection) <= 0.0;
			return (normal.x * lookDirection.x + normal.x * lookDirection.x + normal.x * lookDirection.x) <= 0;
		}
		/**
		 * Returns the distance to a point.  Note that this only
		 * works if the normal is Normalized.
		 */
		public function getDistanceTo (point : Vector3D) : Number
		{
			return normal.x * point.x + normal.y * point.y + normal.z * point.z + d;
		}
	}
}

package linda.math;
import flash.geom.Vector3D;
import flash.Vector;

class Line3D
{
		public var start : Vector3;
		public var end : Vector3;
		public function new (?s : Vector3 = null, ?e : Vector3 = null)
		{
			if (s!=null)
			{
				start = s;
			}else
			{
				start = new Vector3 (0., 0., 0.);
			}
			if (e!=null)
			{
				end = e;
			}else
			{
				end = new Vector3 (0., 0., 0.);
			}
		}
		public function setLine (s : Vector3, e : Vector3) : Void
		{
			start = s;
			end = e;
		}
		public inline function getLength () : Float
		{
			var x : Float = (end.x - start.x);
			var y : Float = (end.y - start.y);
			var z : Float = (end.z - start.z);
			return MathUtil.sqrt (x * x + y * y + z * z);
		}
		public inline function getLengthSQ () : Float
		{
			var x : Float = (end.x - start.x);
			var y : Float = (end.y - start.y);
			var z : Float = (end.z - start.z);
			return (x * x + y * y + z * z);
		}
		public inline function getMiddle () : Vector3
		{
			return new Vector3 ((start.x + end.x) * 0.5, (start.y + end.y) * 0.5, (start.z + end.z) * 0.5);
		}
		public inline function getVector () : Vector3
		{
			return new Vector3 (end.x - start.x, end.y - start.y, end.z - start.z);
		}
		//前提条件是该点已经在直线上
		public inline function isPointBetweenStartAndEnd (point : Vector3) : Bool
		{
			return point.isBetweenPoints (start, end);
		}
		/**
		* 返回到point最近的直线上的点
		*
		*/
		public inline function getClosestPoint (point : Vector3) : Vector3
		{
			var c : Vector3 = point.subtract(start);
			var v : Vector3 = end.subtract(start);
			var d : Float = v.getLength();
			v.scaleBy(1 / d);
			var t:Float=v.dotProduct(c);
			if (t < 0)
			{
				return start;
			}else if (t > d) {
				return end;
			}else
			{
				v.scaleBy(t);
				return start.add(v);
			}
		}
		
		/** 
		 * Check if the line intersects with a shpere
		 * @param sorigin: Origin of the shpere.
		 * @param sradius: Radius of the sphere.
		 * @param outdistance: The distance to the first intersection point.
		 * @return True if there is an intersection.
		 * If there is one, the distance to the first intersection point
		 * is stored in outdistance. 
		 */
		public function getIntersectionWithSphere(origin:Vector3,radius:Float,outdistances:Vector<Float>):Bool
		{
			var q:Vector3 = origin.subtract(start);
			var c:Float = q.getLength();
			var v:Float = q.dotProduct(getVector().normalize());
			var d:Float = radius * radius - (c*c - v*v);

			if (d < 0.0) 
			{
				return false;
			}else
			{
				outdistances[0] = v - Math.sqrt(d);
				return true;
			}
		}
		
		public inline function equals (other : Line3D) : Bool
		{
			return (start.equals (other.start) && end.equals (other.end));
		}
	}

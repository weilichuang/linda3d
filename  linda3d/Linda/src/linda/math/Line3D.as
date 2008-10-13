package linda.math
{
	import flash.geom.Vector3D;
	
	//Todo medium optimization
	public class Line3D
	{
		public var start : Vector3D = new Vector3D (0., 0., 0.);
		public var end : Vector3D = new Vector3D (1., 1., 1.);
		public function Line3D (s : Vector3D = null, e : Vector3D = null)
		{
			if (s) start = s;
			if (e) end = e;
		}
		public function setLineXYZ (sx : Number, sy : Number, sz : Number, ex : Number, ey : Number, ez : Number) : void
		{
			start.x=sx;start.y=sy;start.z=sz;
			end.x=ex;end.y=ey;end.z=ez;
		}
		public function setLine (s : Vector3D, e : Vector3D) : void
		{
			start = s;
			end = e;
		}
		public function getLength () : Number
		{
			var x : Number = (end.x - start.x);
			var y : Number = (end.y - start.y);
			var z : Number = (end.z - start.z);
			return Math.sqrt (x * x + y * y + z * z);
		}
		public function getLengthSQ () : Number
		{
			var x : Number = (end.x - start.x);
			var y : Number = (end.y - start.y);
			var z : Number = (end.z - start.z);
			return (x * x + y * y + z * z);
		}
		public function getMiddle () : Vector3D
		{
			return new Vector3D ((start.x + end.x) * 0.5, (start.y + end.y) * 0.5, (start.z + end.z) * 0.5);
		}
		public function getVector () : Vector3D
		{
			return new Vector3D (end.x - start.x, end.y - start.y, end.z - start.z);
		}
		//前提条件是该点已经在直线上
		public function isPointBetweenStartAndEnd (point : Vector3D) : Boolean
		{
			return false;
			//return point.isBetweenPoints (start, end);
		}
		/**
		* 返回到point最近的直线上的点
		*
		*/
		//todo 怎么算的？
		public function getClosestPoint (point : Vector3D) : Vector3D
		{
			var c : Vector3D = new Vector3D (point.x - start.x, point.y - start.y, point.z - start.z);
			var v : Vector3D = new Vector3D (end.x - start.x, end.y - start.y, end.z - start.z);
			var d : Number = Math.sqrt (v.x * v.x + v.y * v.y + v.z * v.z);
			//v.getLength();
			//v.multiplyNE(1/d);
			v.x /= d;
			v.y /= d;
			v.z /= d;
			//var t:Number=v.dot(c);
			var t : Number = v.x * c.x + v.y * c.y + v.z * c.z;
			if (t < 0) return start;
			if (t > d) return end;
			//v.multiplyNE(t);
			v.x *= t;
			v.y *= t;
			v.z *= t;
			return new Vector3D (start.x + v.x, start.y + v.y, start.z + v.z);
		}
		//判断直线是否与球相交
		//outdistance: The distance to the first intersection point.
		public function getIntersectionWithSphere (origin : Vector3D, radius : Number, outdistance : Number) : Boolean
		{
			var q : Vector3D = new Vector3D (origin.x - start.x, origin.y - start.y, origin.z - start.z);
			var c : Number = Math.sqrt(q.x*q.x+q.y*q.y+q.z*q.z);//q.getLength ();
			var n : Vector3D = getVector ();
			n.normalize ();
			var v : Number = q.x * n.x + q.y * n.y + q.z * n.z;
			//q.dot(n);
			var d : Number = radius * radius - (c * c - v * v);
			if (d < 0) return false;
			outdistance = v - d;
			return true;
		}
		public function equals (other : Line3D) : Boolean
		{
			if (start.equals (other.start) && end.equals (other.end)) return true;
			return false;
		}
	}
}

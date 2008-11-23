package linda.math
{
	import flash.geom.Vector3D;
	
	//Todo medium optimization
	public class Triangle3D
	{
		public var pointA : Vector3D;
		public var pointB : Vector3D;
		public var pointC : Vector3D;
		public function Triangle3D (a : Vector3D, b : Vector3D, c : Vector3D)
		{
			pointA = a;
			pointB = b;
			pointC = c;
		}
		public function setTriangle (a : Vector3D, b : Vector3D, c : Vector3D) : void
		{
			pointA = a;
			pointB = b;
			pointC = c;
		}
		public function getArea () : Number
		{
			return pointB.subtract (pointA).crossProduct(pointC.subtract (pointA)).length * 0.5;
		}
		private var _plane:Plane3D=new Plane3D();
		public function getPlane () : Plane3D
		{
			_plane.setPlane3 (pointA, pointB, pointC);
			return _plane;
		}
		//public function getIntersectionWithLimitedLine (line : Line3D, outIntersection : Vector3D) : Boolean
		//{
		//	return getIntersectionWithLine (line.start,
		//	line.getVector () , outIntersection) &&
		//	outIntersection.isBetweenPoints (line.start, line.end);
		//}
		public function getIntersectionWithLine (linePoint : Vector3D, lineVect : Vector3D, outIntersection : Vector3D) : Boolean
		{
			if (getIntersectionOfPlaneWithLine (linePoint, lineVect, outIntersection))
			return isPointInside (outIntersection);
			return false;
		}
		/**
		*
		*/
		public function getIntersectionOfPlaneWithLine (linePoint : Vector3D, lineVect : Vector3D, outIntersection : Vector3D) : Boolean
		{
			var normal : Vector3D = getNormal ();
			normal.normalize ();
			var t2 : Number = normal.dotProduct(lineVect);
			if (t2 == 0 ) return false;
			var d : Number = pointA.dotProduct (normal);
			var t : Number = - (normal.dotProduct (linePoint) - d) / t2;
			var vect:Vector3D=lineVect.clone();
			vect.scaleBy(t);
			outIntersection = linePoint.add (vect);
			return true;
		}
		/**
		* @return 返回该三角形的法向量，该法向量没有归一化
		*/
		public function getNormal () : Vector3D
		{
			var p0 : Vector3D = new Vector3D ();
			p0.x = pointB.x - pointA.x;
			p0.y = pointB.y - pointA.y;
			p0.z = pointB.z - pointA.z;
			var p1 : Vector3D = new Vector3D ();
			p1.x = pointC.x - pointA.x;
			p1.y = pointC.y - pointA.y;
			p1.z = pointC.z - pointA.z;
			//p0.cross(p1);
			return new Vector3D (p0.y * p1.z - p0.z * p1.y, p0.z * p1.x - p0.x * p1.z, p0.x * p1.y - p0.y * p1.x);
		}
		public function isOnSameSide (p1 : Vector3D, p2 : Vector3D, a : Vector3D, b : Vector3D) : Boolean
		{
			var bminusa : Vector3D = b.subtract (a);
			var cp1 : Vector3D = bminusa.crossProduct (p1.subtract (a));
			var cp2 : Vector3D = bminusa.crossProduct (p2.subtract (a));
			return (cp1.dotProduct (cp2) >= 0.0);
		}
		public function isTotalInsideBox (box : AABBox3D) : Boolean
		{
			return box.isPointInside (pointA) && box.isPointInside (pointB) && box.isPointInside (pointC);
		}
		public function isPointInside (p : Vector3D) : Boolean
		{
			return (isOnSameSide (p, pointA, pointB, pointC) &&
			isOnSameSide (p, pointB, pointA, pointC) &&
			isOnSameSide (p, pointC, pointA, pointB));
		}
		public function isFrontFacing (direction : Vector3D) : Boolean
		{
			var n : Vector3D = getNormal ();
			n.normalize ();
			var d : Number = n.x * direction.x + n.y * direction.y + n.z * direction.z;
			//n.dot(lookDirection);
			if (d > 0 ) return true;
			return false;
		}
	}
}

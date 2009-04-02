package linda.math;


//TODO 优化
class Triangle3D
{
		public var pointA : Vector3;
		public var pointB : Vector3;
		public var pointC : Vector3;
		public function new (a : Vector3, b : Vector3, c : Vector3)
		{
			pointA = a;
			pointB = b;
			pointC = c;
		}
		public inline function setTriangle (a : Vector3, b : Vector3, c : Vector3) : Void
		{
			pointA = a;
			pointB = b;
			pointC = c;
		}
		
		public inline function equals(other:Triangle3D):Bool 
		{
			return pointA.equals(other.pointA) && pointB.equals(other.pointB) && pointC.equals(other.pointC);
		}
		
		public inline function getArea () : Float
		{
			return pointB.subtract (pointA).crossProduct (pointC.subtract (pointA)).getLength() * 0.5;
		}
		public inline function getPlane () : Plane3D
		{
			var plane:Plane3D=new Plane3D();
			plane.setPlane3 (pointA, pointB, pointC);
			return plane;
		}
		
		//! Get an intersection with a 3d line.
		/** \param line Line to intersect with.
		\param outIntersection Place to store the intersection point, if there is one.
		\return True if there was an intersection, false if not. */
		public inline function getIntersectionWithLimitedLine (line : Line3D, outIntersection : Vector3) : Bool
		{
			return getIntersectionWithLine (line.start, line.getVector () , outIntersection) &&
			       outIntersection.isBetweenPoints (line.start, line.end);
		}
		
		//! Get an intersection with a 3d line.
		/** Please note that also points are returned as intersection which
		are on the line, but not between the start and end point of the line.
		If you want the returned point be between start and end
		use getIntersectionWithLimitedLine().
		\param linePoint Point of the line to intersect with.
		\param lineVect Vector of the line to intersect with.
		\param outIntersection Place to store the intersection point, if there is one.
		\return True if there was an intersection, false if there was not. */
		public inline function getIntersectionWithLine (linePoint : Vector3, lineVect : Vector3, outIntersection : Vector3) : Bool
		{
			if (getIntersectionOfPlaneWithLine (linePoint, lineVect, outIntersection))
			{
				return isPointInside (outIntersection);
			}else
			{
				return false;
			}
		}
		//! Calculates the intersection between a 3d line and the plane the triangle is on.
		/** \param lineVect Vector of the line to intersect with.
		\param linePoint Point of the line to intersect with.
		\param outIntersection Place to store the intersection point, if there is one.
		\return True if there was an intersection, else false. */
		public inline function getIntersectionOfPlaneWithLine (linePoint : Vector3, lineVect : Vector3, outIntersection : Vector3) : Bool
		{
			var normal : Vector3 = getNormal ();
			normal.normalize ();
			var t2 : Float = normal.dotProduct (lineVect);
			if (t2 == 0 )
			{
				return false;
			}else
			{
				var d : Float = pointA.dotProduct (normal);
				var t : Float = - (normal.dotProduct (linePoint) - d) / t2;
				outIntersection = linePoint.add (lineVect.scale (t));
				return true;
			}
		}
		//! Get the normal of the triangle.
		/** Please note: The normal is not always normalized. */
		public inline function getNormal () : Vector3
		{
			var p0x:Float = pointB.x - pointA.x;
			var p0y:Float = pointB.y - pointA.y;
			var p0z:Float = pointB.z - pointA.z;
			var p1x:Float = pointC.x - pointA.x;
			var p1y:Float = pointC.y - pointA.y;
			var p1z:Float = pointC.z - pointA.z;
			//var p0 : Vector3 = pointB.subtract(pointA);
			//var p1 : Vector3 = pointC.subtract(pointA);
			//return pointB.subtract(pointA).crossProduct(pointC.subtract(pointA));
			return new Vector3 (p0y * p1z - p0z * p1y, p0z * p1x - p0x * p1z, p0x * p1y - p0y * p1x);
		}
		public inline function isOnSameSide (p1 : Vector3, p2 : Vector3, a : Vector3, b : Vector3) : Bool
		{
			var bminusa : Vector3 = b.subtract (a);
			var cp1 : Vector3 = bminusa.crossProduct (p1.subtract (a));
			var cp2 : Vector3 = bminusa.crossProduct (p2.subtract (a));
			return (cp1.dotProduct (cp2) >= 0.0);
		}
		public inline function isTotalInsideBox (box : AABBox3D) : Bool
		{
			return box.isPointInside (pointA) && box.isPointInside (pointB) && box.isPointInside (pointC);
		}
		//! Get the closest point on a triangle to a point on the same plane.
		//! \param p: Point which must be on the same plane as the triangle.
		//! \return The closest point of the triangle
		public inline function closestPointOnTriangle (p : Vector3) : Vector3
		{
			var rab : Vector3 = new Line3D (pointA, pointB).getClosestPoint (p);
			var rbc : Vector3 = new Line3D (pointB, pointC).getClosestPoint (p);
			var rca : Vector3 = new Line3D (pointC, pointA).getClosestPoint (p);
			var d1 : Float = Vector3.distance(rab, p);
			var d2 : Float = Vector3.distance(rbc, p);
			var d3 : Float = Vector3.distance(rca, p);
			if (d1 < d2)
			{
				return d1 < d3 ? rab : rca;
			}else
			{
				return d2 < d3 ? rbc : rca;
			}
		}
		public inline function isPointInside (p : Vector3) : Bool
		{
			return (isOnSameSide (p, pointA, pointB, pointC) &&
			        isOnSameSide (p, pointB, pointA, pointC) &&
			        isOnSameSide (p, pointC, pointA, pointB));
		}
		
		//! Test if the triangle would be front or backfacing from any point.
		/** Thus, this method assumes a camera position from which the
		triangle is definitely visible when looking at the given direction.
		Do not use this method with points as it will give wrong results!
		\param lookDirection Look direction.
		\return True if the plane is front facing and false if it is backfacing. */
		public inline function isFrontFacing (direction : Vector3) : Bool
		{
			var n : Vector3 = getNormal();
			n.normalize ();
			var d : Float = n.dotProduct(direction);
			if (d > 0 )
			{
				return true;
			}else
			{
				return false;
			}
		}
}


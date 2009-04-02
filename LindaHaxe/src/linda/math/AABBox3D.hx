package linda.math;

	import flash.Vector;
	
	class AABBox3D
	{
		public var minX : Float;
		public var minY : Float;
		public var minZ : Float;
		public var maxX : Float;
		public var maxY : Float;
		public var maxZ : Float;
		public function new (?min : Vector3 = null, ?max : Vector3 = null)
		{
			if (min == null || max == null)
			{
				minX = 0.;
				minY = 0.;
				minZ = 0.;
				maxX = 0.;
				maxY = 0.;
				maxZ = 0.;
			} 
			else
			{
				minX = min.x;
				minY = min.y;
				minZ = min.z;
				maxX = max.x;
				maxY = max.y;
				maxZ = max.z;
			}
		}
		public inline function identity():Void 
		{
			minX = 0.;
			minY = 0.;
			minZ = 0.;
			maxX = 0.;
			maxY = 0.;
			maxZ = 0.;
		}
		public inline function reset (x : Float, y : Float, z : Float) : Void
		{
			minX = x;
			minY = y;
			minZ = z;
			maxX = x;
			maxY = y;
			maxZ = z;
		}
		public inline function resetVector (v : Vector3) : Void
		{
			minX = v.x;
			minY = v.y;
			minZ = v.z;
			maxX = v.x;
			maxY = v.y;
			maxZ = v.z;
		}
		public inline function resetVertex (v : Vertex) : Void
		{
			minX = v.x;
			minY = v.y;
			minZ = v.z;
			maxX = v.x;
			maxY = v.y;
			maxZ = v.z;
		}
		public inline function resetAABBox (box : AABBox3D) : Void
		{
			minX = box.minX;
			minY = box.minY;
			minZ = box.minZ;
			maxX = box.maxX;
			maxY = box.maxY;
			maxZ = box.maxZ;
		}
		public inline function copy (other : AABBox3D) : Void
		{
			minX = other.minX;
			minY = other.minY;
			minZ = other.minZ;
			maxX = other.maxX;
			maxY = other.maxY;
			maxZ = other.maxZ;
		}
		public inline function equals (other : AABBox3D) : Bool
		{
			return (minX == other.minX && minY == other.minY && minZ == other.minZ &&
			       maxX == other.maxX && maxY == other.maxY && maxZ == other.maxZ);
		}
		public inline function addVector (point : Vector3) : Void
		{
			addXYZ(point.x, point.y, point.z);
		}
		public inline function addVertex (point : Vertex) : Void
		{
			addXYZ(point.x, point.y, point.z);
		}
		public inline function addXYZ (x : Float, y : Float, z : Float) : Void
		{
			if (x > maxX) maxX = x;
			if (y > maxY) maxY = y;
			if (z > maxZ) maxZ = z;
			if (x < minX) minX = x;
			if (y < minY) minY = y;
			if (z < minZ) minZ = z;
		}
		public inline function addAABBox (box : AABBox3D) : Void
		{
			addXYZ(box.maxX, box.maxY, box.maxZ);
			addXYZ(box.minX, box.minY, box.minZ);
		}
		public inline function isPointInside (point : Vector3) : Bool
		{
			return (point.x >= minX && point.x <= maxX && point.y >= minY &&
			        point.y <= maxY && point.z >= minZ && point.z <= maxZ);
		}
		public inline function isPointTotalInside (point : Vector3) : Bool
		{
			return (point.x > minX && point.x < maxX && point.y > minY &&
			        point.y < maxY && point.z > minZ && point.z < maxZ);
		} 

		/** 
		 * Tests if the box intersects with a line
		 * @param linemiddle Center of the line.
		 * @param linevect Vector of the line.
		 * @param halflength Half length of the line.
		 * @return True if there is an intersection, else false. 
		 */
		public inline function intersectsWithLine (linemiddle : Vector3, linevect : Vector3, halflength : Float) : Bool
		{
			var e : Vector3 = getExtent ();
			e.scaleBy (0.5);
			var t : Vector3 = getCenter().subtract (linemiddle);
			if ((MathUtil.abs(t.x) > e.x + halflength * MathUtil.abs(linevect.x)) ||
			    (MathUtil.abs(t.y) > e.y + halflength * MathUtil.abs(linevect.y)) ||
			    (MathUtil.abs(t.z) > e.z + halflength * MathUtil.abs(linevect.z)))
			{
				return false;
			}else
			{
				var r : Float = e.y * Math.abs(linevect.z) + e.z * Math.abs(linevect.y);
				if (MathUtil.abs (t.y * linevect.z - t.z * linevect.y) > r) return false;
				r = e.x * MathUtil.abs(linevect.z) + e.z * MathUtil.abs(linevect.x);
				if (MathUtil.abs (t.z * linevect.x - t.x * linevect.z) > r) return false;
				r = e.x * MathUtil.abs(linevect.y) + e.y * MathUtil.abs(linevect.x);
				if (MathUtil.abs (t.x * linevect.y - t.y * linevect.x) > r) return false;
				return true;
			}
		}
		public inline function intersectsWithBox (box : AABBox3D) : Bool
		{
			return (minX <= box.maxX && minY <= box.maxY && minZ <= box.maxZ &&
			        maxX >= box.minX && maxY >= box.minY && maxZ >= box.minZ);
		}
		public inline function isFullInside(box:AABBox3D):Bool
		{
			return (minX >= box.minX && minY >= box.minY && minZ >= box.minZ &&
			        maxX <= box.maxX && maxY <= box.maxY && maxZ <= box.maxZ);
		}

		/** 
		 * Classifies a relation with a plane.
		 * @param plane Plane to classify relation to.
		 * @return Returns IS_FRONT if the box is in front of the plane,
		 * IS_BACK if the box is behind the plane, and
		 * IS_CLIPPED if it is on both sides of the plane. 
		 */
		public inline function classifyPlaneRelation(plane:Plane3D):Int
		{
			var nearPoint:Vector3 = new Vector3(maxX, maxY, maxZ);
			var farPoint:Vector3 = new Vector3(minX, minY, minZ);

			if (plane.normal.x > 0)
			{
				nearPoint.x = minX;
				farPoint.x = maxX;
			}

			if (plane.normal.y > 0)
			{
				nearPoint.y = minY;
				farPoint.y = maxY;
			}

			if (plane.normal.z > 0)
			{
				nearPoint.z = minZ;
				farPoint.z = maxZ;
			}

			if (plane.normal.dotProduct(nearPoint) + plane.d > 0)
			{
				return IntersectionRelation3D.IS_FRONT;
			}else if (plane.normal.dotProduct(farPoint) + plane.d > 0)
			{
				return IntersectionRelation3D.IS_CLIPPED;
			}else
			{
				return IntersectionRelation3D.IS_BACK;
			}
		}
		
		public inline function getCenter () : Vector3
		{
			var center:Vector3 = new Vector3();
			center.x=(maxX + minX) * 0.5;
			center.y=(maxY + minY) * 0.5;
			center.z=(maxZ + minZ) * 0.5;
			return center;
		}
		public inline function getExtent () : Vector3
		{
			var extent:Vector3=new Vector3();
			extent.x=(maxX - minX) * 0.5;
			extent.y=(maxY - minY) * 0.5;
			extent.z=(maxZ - minZ) * 0.5;
			return extent;
		}
		
		public inline function getEdges () : Vector<Vector3>
		{
			var _edges:Vector<Vector3>=new Vector<Vector3>(8,true);
			for(i in 0...8)
			{
				_edges[i] = new Vector3();
			}
			var centerX : Float = (maxX + minX) * 0.5;
			var centerY : Float = (maxY + minY) * 0.5;
			var centerZ : Float = (maxZ + minZ) * 0.5;
			var diagX : Float = centerX - maxX;
			var diagY : Float = centerY - maxY;
			var diagZ : Float = centerZ - maxZ;

			var v : Vector3 = _edges[0];
			v.x=centerX + diagX;
			v.y=centerY + diagY;
			v.z=centerZ + diagZ;
			
			v = _edges[1];
			v.x=centerX + diagX;
			v.y=centerY - diagY;
			v.z=centerZ + diagZ;
			
			v = _edges[2];
			v.x=centerX + diagX;
			v.y=centerY + diagY;
			v.z=centerZ - diagZ;
			
			v = _edges[3];
			v.x=centerX + diagX;
			v.y=centerY - diagY;
			v.z=centerZ - diagZ;
			
			v = _edges[4];
			v.x=centerX - diagX;
			v.y=centerY + diagY;
			v.z=centerZ + diagZ;

			v = _edges[5];
			v.x=centerX - diagX;
			v.y=centerY - diagY;
			v.z=centerZ + diagZ;

			v = _edges[6];
			v.x=centerX - diagX;
			v.y=centerY + diagY;
			v.z=centerZ - diagZ;
			
			v = _edges[7];
			v.x=centerX - diagX;
			v.y=centerY - diagY;
			v.z=centerZ - diagZ;

			return _edges;
		}
		public inline function isEmpty () : Bool
		{
			var dX : Float = maxX - minX;
			var dY : Float = maxY - minY;
			var dZ : Float = maxZ - minZ;
			
			if (dX < 0) dX = - dX;
			if (dY < 0) dY = - dY;
			if (dZ < 0) dZ = - dZ;

			return (dX < MathUtil.ROUNDING_ERROR &&
			        dY < MathUtil.ROUNDING_ERROR &&
			        dZ < MathUtil.ROUNDING_ERROR);
		}
		
		// Get the volume enclosed by the box in cubed units
		public inline function getVolume():Float
		{
			var e:Vector3 = getExtent();
			return e.x * e.y * e.z;
		}
		
		// Get the surface area of the box in squared units
		public inline function getArea():Float
		{
			var e:Vector3 = getExtent();
			return 2*(e.x*e.y + e.x*e.z + e.y*e.z);
		}
		
		public inline function repair () : Void
		{
			var t : Float;
			if (minX > maxX)
			{
				t = minX; minX = maxX; maxX = t;
			}
			if (minY > maxY)
			{
				t = minY; minY = maxY; maxY = t;
			}
			if (minZ > maxZ)
			{
				t = minZ; minZ = maxZ; maxZ = t;
			}
		}
		public inline function interpolate(a:AABBox3D, b:AABBox3D, div:Float):Void 
		{
			var inv : Float = 1.0 - div;
			minX = a.minX * div + b.minX * inv;
			minY = a.minY * div + b.minY * inv;
			minZ = a.minZ * div + b.minZ * inv;
			maxX = a.maxX * div + b.maxX * inv;
			maxY = a.maxY * div + b.maxY * inv;
			maxZ = a.maxZ * div + b.maxZ * inv;
			repair();
		}
		public inline function getInterpolated (other : AABBox3D, div : Float) : AABBox3D
		{
			var box : AABBox3D = new AABBox3D ();
			var inv : Float = 1.0 - div;
			box.minX = other.minX * inv + minX * div;
			box.minY = other.minY * inv + minY * div;
			box.minZ = other.minZ * inv + minZ * div;
			box.maxX = other.maxX * inv + maxX * div;
			box.maxY = other.maxY * inv + maxY * div;
			box.maxZ = other.maxZ * inv + maxZ * div;
			box.repair();
			return box;
		}
		public inline function clone () : AABBox3D
		{
			return new AABBox3D (new Vector3 (minX, minY, minZ) , new Vector3 (maxX, maxY, maxZ));
		}
		public function toString () : String
		{
			var s : String = new String ("AABBox3D :\n");
			s += (Std.int (maxX * 1000) / 1000) + "\t" + (Std.int (maxY * 1000) / 1000) + "\t" + (Std.int (maxZ * 1000) / 1000) + "\n";
			s += (Std.int (minX * 1000) / 1000) + "\t" + (Std.int (minY * 1000) / 1000) + "\t" + (Std.int (minZ * 1000) / 1000) + "\n";
			return s;
		}
	}

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
		public var center:Vector3;
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
			center=new Vector3();
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
			if (point.x > maxX)
			{
				maxX = point.x;
			}
			if (point.y > maxY)
			{
				maxY = point.y;
			}
			if (point.z > maxZ)
			{
				maxZ = point.z;
			}
			if (point.x < minX)
			{
				minX = point.x;
			}
			if (point.y < minY)
			{
				minY = point.y;
			}
			if (point.z < minZ)
			{
				minZ = point.z;
			}
		}
		public inline function addVertex (point : Vertex) : Void
		{
			if (point.x > maxX)
			{
				maxX = point.x;
			}
			if (point.y > maxY)
			{
				maxY = point.y;
			}
			if (point.z > maxZ)
			{
				maxZ = point.z;
			}
			if (point.x < minX)
			{
				minX = point.x;
			}
			if (point.y < minY)
			{
				minY = point.y;
			}
			if (point.z < minZ)
			{
				minZ = point.z;
			}
		}
		public inline function addXYZ (x : Float, y : Float, z : Float) : Void
		{
			if (x > maxX)
			{
				maxX = x;
			}
			if (y > maxY)
			{
				maxY = y;
			}
			if (z > maxZ)
			{
				maxZ = z;
			}
			if (x < minX)
			{
				minX = x;
			}
			if (y < minY)
			{
				minY = y;
			}
			if (z < minZ)
			{
				minZ = z;
			}
		}
		public inline function addAABBox (box : AABBox3D) : Void
		{
			addXYZ (box.maxX, box.maxY, box.maxZ);
			addXYZ (box.minX, box.minY, box.minZ);
		}
		public inline function isPointInside (point : Vector3) : Bool
		{
			return (point.x >= minX &&
			point.x <= maxX &&
			point.y >= minY &&
			point.y <= maxY &&
			point.z >= minZ &&
			point.z <= maxZ);
		}
		public inline function isPointTotalInside (point : Vector3) : Bool
		{
			return (point.x > minX &&
			point.x < maxX &&
			point.y > minY &&
			point.y < maxY &&
			point.z > minZ &&
			point.z < maxZ);
		} 
		public inline function intersectsWithLine (linemiddle : Vector3, linevect : Vector3, halflength : Float) : Bool
		{
			var e : Vector3 = getExtent ();
			e.scaleBy (0.5);
			var t : Vector3 = getCenter ().subtract (linemiddle);
			if ((MathUtil.abs (t.x) > e.x + halflength * MathUtil.abs (linevect.x)) ||
			    (MathUtil.abs (t.y) > e.y + halflength * MathUtil.abs (linevect.y)) ||
			    (MathUtil.abs (t.z) > e.z + halflength * MathUtil.abs (linevect.z)))
			e=null;
			return false;
			var r : Float = e.y * Math.abs (linevect.z) + e.z * Math.abs (linevect.y);
			if (MathUtil.abs (t.y * linevect.z - t.z * linevect.y) > r) return false;
			r = e.x * MathUtil.abs (linevect.z) + e.z * MathUtil.abs (linevect.x);
			if (MathUtil.abs (t.z * linevect.x - t.x * linevect.z) > r) return false;
			r = e.x * MathUtil.abs (linevect.y) + e.y * MathUtil.abs (linevect.x);
			if (MathUtil.abs (t.x * linevect.y - t.y * linevect.x) > r) return false;
			e=null;
			return true;
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
		public inline function getCenter () : Vector3
		{
			center.x=(maxX + minX) * 0.5;
			center.y=(maxY + minY) * 0.5;
			center.z=(maxZ + minZ) * 0.5;
			return center;
		}
		public inline function getExtent () : Vector3
		{
			var _extent:Vector3=new Vector3();
			_extent.x=(maxX - minX) * 0.5;
			_extent.y=(maxY - minY) * 0.5;
			_extent.z=(maxZ - minZ) * 0.5;
			return _extent;
		}
		
		public inline function getEdges () : Vector<Vector3>
		{
			var _edges:Vector<Vector3>=new Vector<Vector3>();
			for(i in 0...8)
			{
				_edges.push(new Vector3());
			}
			var centerX : Float = (maxX + minX) / 2;
			var centerY : Float = (maxY + minY) / 2;
			var centerZ : Float = (maxZ + minZ) / 2;
			var diagX : Float = centerX - maxX;
			var diagY : Float = centerY - maxY;
			var diagZ : Float = centerZ - maxZ;
			//			/*
			//			Edges are stored in this way:
			//                  /1--------/3
			//                 /  |      / |
			//                /   |     /  |
			//                5---------7  |
			//                |   0- - -| -2
			//                |  /      |  /
			//                |/        | /
			//                4---------6/
			//			*/
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
			if (dX < 0)
			{
				dX = - dX;
			}
			if (dY < 0)
			{
				dY = - dY;
			}
			if (dZ < 0)
			{
				dZ = - dZ;
			}
			return (dX < MathUtil.ROUNDING_ERROR &&
			        dY < MathUtil.ROUNDING_ERROR &&
			        dZ < MathUtil.ROUNDING_ERROR);
		}
		public inline function repair () : Void
		{
			var t : Float;
			if (minX > maxX)
			{
				t = minX;
				minX = maxX;
				maxX = t;
			}
			if (minY > maxY)
			{
				t = minY;
				minY = maxY;
				maxY = t;
			}
			if (minZ > maxZ)
			{
				t = minZ;
				minZ = maxZ;
				maxZ = t;
			}
		}
		public inline function getInterpolated (other : AABBox3D, d : Float) : AABBox3D
		{
			var box : AABBox3D = new AABBox3D ();
			var inv : Float = 1.0 - d;
			box.minX = other.minX * inv + minX * d;
			box.minY = other.minY * inv + minY * d;
			box.minZ = other.minZ * inv + minZ * d;
			box.maxX = other.maxX * inv + maxX * d;
			box.maxY = other.maxY * inv + maxY * d;
			box.maxZ = other.maxZ * inv + maxZ * d;
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

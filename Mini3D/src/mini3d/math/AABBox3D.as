package mini3d.math
{
	import mini3d.core.Vertex;
	
	public class AABBox3D
	{
		public var minX : Number;
		public var minY : Number;
		public var minZ : Number;
		public var maxX : Number;
		public var maxY : Number;
		public var maxZ : Number;
		public function AABBox3D (min : Vector3D = null, max : Vector3D = null)
		{
			if (min == null || max == null)
			{
				minX = 0;
				minY = 0;
				minZ = 0;
				maxX = 0;
				maxY = 0;
				maxZ = 0;
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
		public function reset (x : Number, y : Number, z : Number) : void
		{
			minX = x;
			minY = y;
			minZ = z;
			maxX = x;
			maxY = y;
			maxZ = z;
		}
		public function resetVector (v : Vector3D) : void
		{
			minX = v.x;
			minY = v.y;
			minZ = v.z;
			maxX = v.x;
			maxY = v.y;
			maxZ = v.z;
		}
		public function resetVertex (v : Vertex) : void
		{
			minX = v.x;
			minY = v.y;
			minZ = v.z;
			maxX = v.x;
			maxY = v.y;
			maxZ = v.z;
		}
		public function copy (other : AABBox3D) : void
		{
			minX = other.minX;
			minY = other.minY;
			minZ = other.minZ;
			maxX = other.maxX;
			maxY = other.maxY;
			maxZ = other.maxZ;
		}
		public function equals (other : AABBox3D) : Boolean
		{
			return minX == other.minX &&
			minY == other.minY &&
			minZ == other.minZ &&
			maxX == other.maxX &&
			maxY == other.maxY &&
			maxZ == other.maxZ;
		}
		public function addPoint (point : Vector3D) : void
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
		public function addVertex (point : Vertex) : void
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
		public function addXYZ (x : Number, y : Number, z : Number) : void
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
		public function addBox (box : AABBox3D) : void
		{
			addXYZ (box.maxX, box.maxY, box.maxZ);
			addXYZ (box.minX, box.minY, box.minZ);
		}
		public function resetBox (box : AABBox3D) : void
		{
			minX = box.minX;
			minY = box.minY;
			minZ = box.minZ;
			maxX = box.maxX;
			maxY = box.maxY;
			maxZ = box.maxZ;
		}
		public function isPointInside (point : Vector3D) : Boolean
		{
			return (point.x >= minX &&
			point.x <= maxX &&
			point.y >= minY &&
			point.y <= maxY &&
			point.z >= minZ &&
			point.z <= maxZ);
		}
		public function isPointTotalInside (point : Vector3D) : Boolean
		{
			return (point.x > minX &&
			point.x < maxX &&
			point.y > minY &&
			point.y < maxY &&
			point.z > minZ &&
			point.z < maxZ);
		}

		public function intersectsWithLine (linemiddle : Vector3D, linevect : Vector3D, halflength : Number) : Boolean
		{
			var e : Vector3D = getExtent ().scale (0.5);
			var t : Vector3D = getCenter ().subtract (linemiddle);
			if ((Math.abs (t.x) > e.x + halflength * Math.abs (linevect.x)) ||
			    (Math.abs (t.y) > e.y + halflength * Math.abs (linevect.y)) ||
			    (Math.abs (t.z) > e.z + halflength * Math.abs (linevect.z)))
			return false;
			var r : Number = e.y * Math.abs (linevect.z) + e.z * Math.abs (linevect.y);
			if (Math.abs (t.y * linevect.z - t.z * linevect.y) > r) return false;
			r = e.x * Math.abs (linevect.z) + e.z * Math.abs (linevect.x);
			if (Math.abs (t.z * linevect.x - t.x * linevect.z) > r) return false;
			r = e.x * Math.abs (linevect.y) + e.y * Math.abs (linevect.x);
			if (Math.abs (t.x * linevect.y - t.y * linevect.x) > r) return false;
			return true;
		}
		public function intersectsWithBox (box : AABBox3D) : Boolean
		{
			return (minX <= box.maxX && minY <= box.maxY && minZ <= box.maxZ &&
			        maxX >= box.minX && maxY >= box.minY && maxZ >= box.minZ);
		}
		public function isFullInside(box:AABBox3D):Boolean
		{
			return (minX >= box.minX && minY >= box.minY && minZ >= box.minZ &&
			        maxX <= box.maxX && maxY <= box.maxY && maxZ <= box.maxZ);
		}
		public function getCenter () : Vector3D
		{
			var center:Vector3D=new Vector3D();
			center.x=(maxX + minX) * 0.5;
			center.y=(maxY + minY) * 0.5;
			center.z=(maxZ + minZ) * 0.5;
			return center;
		}
		public function getRadius():Number
		{
			var x:Number=(maxX-minX);
			var y:Number=(maxY-minY);
			var z:Number=(maxZ-minZ);
			
			return Math.sqrt(x*x+y*y+z*z);
		}
		public function getExtent () : Vector3D
		{
			var _extent:Vector3D=new Vector3D();
			_extent.x=(maxX - minX) * 0.5;
			_extent.y=(maxY - minY) * 0.5;
			_extent.z=(maxZ - minZ) * 0.5;
			return _extent;
		}
		public function getEdges () : Array
		{
			var _edges:Array=new Array();
			for(var i:int=0;i<8;i++)
			{
				_edges.push(new Vector3D());
			}
			var centerX : Number = (maxX + minX) / 2;
			var centerY : Number = (maxY + minY) / 2;
			var centerZ : Number = (maxZ + minZ) / 2;
			var diagX : Number = centerX - maxX;
			var diagY : Number = centerY - maxY;
			var diagZ : Number = centerZ - maxZ;
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
			var v : Vector3D = _edges[0];
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
		/**
		 * error 容许误差系数
		 */
		public function isEmpty (error:Number=0.0001) : Boolean
		{
			var dX : Number = maxX - minX;
			var dY : Number = maxY - minY;
			var dZ : Number = maxZ - minZ;
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
			return (dX < error && dY < error && dZ < error);
		}
		public function repair () : void
		{
			var t : Number;
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
		public function getInterpolated (other : AABBox3D, d : Number) : AABBox3D
		{
			var box : AABBox3D = new AABBox3D ();
			var inv : Number = 1.0 - d;
			box.minX = other.minX * inv + minX * d;
			box.minY = other.minY * inv + minY * d;
			box.minZ = other.minZ * inv + minZ * d;
			box.maxX = other.maxX * inv + maxX * d;
			box.maxY = other.maxY * inv + maxY * d;
			box.maxZ = other.maxZ * inv + maxZ * d;
			return box;
		}
		public function clone () : AABBox3D
		{
			return new AABBox3D (new Vector3D (minX, minY, minZ) , new Vector3D (maxX, maxY, maxZ));
		}
		public function toString () : String
		{
			var s : String = new String ("AABBox3D :\n");
			s += (int (maxX * 1000) / 1000) + "\t" + (int (maxY * 1000) / 1000) + "\t" + (int (maxZ * 1000) / 1000) + "\n";
			s += (int (minX * 1000) / 1000) + "\t" + (int (minY * 1000) / 1000) + "\t" + (int (minZ * 1000) / 1000) + "\n";
			return s;
		}
	}
}

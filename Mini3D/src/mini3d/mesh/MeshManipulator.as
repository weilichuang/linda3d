package mini3d.mesh
{
	import flash.geom.Rectangle;
	
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	import mini3d.math.Plane3D;
	import mini3d.math.Vector3D;
	public class MeshManipulator
	{
		/**
		* Flips the direction of surfaces. Changes backfacing triangles to frontfacing
		* triangles and vice versa.
		* @param mesh: Mesh on which the operation is performed.
		*/
		public static function flipSurfaces (mesh : IMesh) : void
		{
			if ( ! mesh) return;
			var bcount : int = mesh.getMeshBufferCount ();
			for (var b : int = 0; b < bcount; b ++)
			{
				var buffer : IMeshBuffer = mesh.getMeshBuffer (b);
				var idxcnt : int = buffer.getIndexCount ();
				var idx : Array = buffer.getIndices ();
				var tmp : int;
				for (var i : int = 0; i < idxcnt; i += 3)
				{
					tmp = idx [i + 1];
					idx [i + 1] = idx [i + 2];
					idx [i + 2] = tmp;
				}
			}
		}

		
		//首先确保IMeshBuffer的包围盒已经计算
		public static function unwrapUV (mesh : IMesh) : void
		{
			if ( ! mesh) return;
			mesh.recalculateBoundingBox ();
			var box : AABBox3D = mesh.getBoundingBox ();
			box.repair ();
			if (box.isEmpty ()) return;
			var rect : Rectangle = new Rectangle (box.minX, box.minY, (box.maxX - box.minX) , (box.maxY - box.minY));
			var bcount : int = mesh.getMeshBufferCount ();
			for (var i : int = 0; i < bcount; i ++)
			{
				var buffer : IMeshBuffer = mesh.getMeshBuffer (i);
				var vtx_cnt : int = buffer.getVertexCount ();
				var vertices : Array = buffer.getVertices ();
				for (var j : int = 0; j < vtx_cnt; j ++)
				{
					var v : Vertex = vertices [j];
					v.u = (v.x - rect.x) / rect.width;
					v.v = (v.y - rect.y) / rect.height;
				}
			}
		}
		public static function unwrapUVMeshBuffer (buffer : IMeshBuffer) : void
		{
			if ( ! buffer) return;
			buffer.recalculateBoundingBox ();
			var box : AABBox3D = buffer.getBoundingBox ();
			box.repair ();
			if (box.isEmpty ()) return;
			var rect : Rectangle = new Rectangle (box.minX, box.minY, (box.maxX - box.minX) , (box.maxY - box.minY));
			var vtx_cnt : int = buffer.getVertexCount ();
			var vertices : Array = buffer.getVertices ();
			for (var j : int = 0; j < vtx_cnt; j ++)
			{
				var v : Vertex = vertices [j];
				v.u = (v.x - rect.x) / rect.width;
				v.v = (v.y - rect.y) / rect.height;
			}
		}
		private static var plane : Plane3D = new Plane3D ();
		public static function makePlanarTextureMapping (mesh : IMesh, resolution : Number = 0.01) : void
		{
			if ( ! mesh) return;
			var bcount : int = mesh.getMeshBufferCount ();
			for (var i : int = 0; i < bcount; i ++)
			{
				var buffer : IMeshBuffer = mesh.getMeshBuffer (i);
				var vtx_cnt : int = buffer.getVertexCount ();
				var idx_cnt : int = buffer.getIndexCount ();
				var indices : Array = buffer.getIndices ();
				var vertices : Array = buffer.getVertices ();
				for (var j : int = 0; j < idx_cnt; j += 3)
				{
					var v0 : Vertex = vertices [indices [j]];
					var v1 : Vertex = vertices [indices [j + 1]];
					var v2 : Vertex = vertices [indices [j + 2]];
					plane.setPlane3 (v0.position , v1.position , v2.position);
					var normal : Vector3D = plane.normal;
					normal.x = Math.abs (normal.x);
					normal.y = Math.abs (normal.y);
					normal.z = Math.abs (normal.z);
					// calculate planar mapping worldspace coordinates
					if (normal.x > normal.y && normal.x > normal.z)
					{
						v0.u = v0.y * resolution;
						v0.v = v0.z * resolution;
						v1.u = v1.y * resolution;
						v1.v = v1.z * resolution;
						v2.u = v2.y * resolution;
						v2.v = v2.z * resolution;
					} 
					else if (normal.y > normal.x && normal.y > normal.z)
					{
						v0.u = v0.x * resolution;
						v0.v = v0.z * resolution;
						v1.u = v1.x * resolution;
						v1.v = v1.z * resolution;
						v2.u = v2.x * resolution;
						v2.v = v2.z * resolution;
					} 
					else
					{
						v0.u = v0.x * resolution;
						v0.v = v0.y * resolution;
						v1.u = v1.x * resolution;
						v1.v = v1.y * resolution;
						v2.u = v2.x * resolution;
						v2.v = v2.y * resolution;
					}
				}
			}
		}
		public static function makeMeshBufferPlanarTextureMapping (buffer : IMeshBuffer, resolution : Number = 0.01) : void
		{
			var vtx_cnt : int = buffer.getVertexCount ();
			var idx_cnt : int = buffer.getIndexCount ();
			var indices : Array = buffer.getIndices ();
			var vertices : Array = buffer.getVertices ();
			for (var j : int = 0; j < idx_cnt; j += 3)
			{
				var v0 : Vertex = vertices [indices [j]];
				var v1 : Vertex = vertices [indices [j + 1]];
				var v2 : Vertex = vertices [indices [j + 2]];
				plane.setPlane3 (v0.position , v1.position , v2.position);
				var normal : Vector3D = plane.normal;
				normal.x = Math.abs (normal.x);
				normal.y = Math.abs (normal.y);
				normal.z = Math.abs (normal.z);
				// calculate planar mapping worldspace coordinates
				if (normal.x > normal.y && normal.x > normal.z)
				{
					v0.u = v0.y * resolution;
					v0.v = v0.z * resolution;
					v1.u = v1.y * resolution;
					v1.v = v1.z * resolution;
					v2.u = v2.y * resolution;
					v2.v = v2.z * resolution;
				} 
				else if (normal.y > normal.x && normal.y > normal.z)
				{
					v0.u = v0.x * resolution;
					v0.v = v0.z * resolution;
					v1.u = v1.x * resolution;
					v1.v = v1.z * resolution;
					v2.u = v2.x * resolution;
					v2.v = v2.z * resolution;
				} 
				else
				{
					v0.u = v0.x * resolution;
					v0.v = v0.y * resolution;
					v1.u = v1.x * resolution;
					v1.v = v1.y * resolution;
					v2.u = v2.x * resolution;
					v2.v = v2.y * resolution;
				}
				v0.u = v0.u > 0 ? v0.u : - v0.u;
				v1.u = v1.u > 0 ? v1.u : - v1.u;
				v2.u = v2.u > 0 ? v2.u : - v2.u;
				v0.v = v0.v > 0 ? v0.v : - v0.v;
				v1.v = v1.v > 0 ? v1.v : - v1.v;
				v2.v = v2.v > 0 ? v2.v : - v2.v;
			}
		}
	}
}

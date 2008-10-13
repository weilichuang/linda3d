package linda.mesh.utils
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import linda.math.AABBox3D;
	import linda.math.Plane3D;
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.IMeshBuffer;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
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
				var idx : Vector.<int> = buffer.getIndices ();
				var tmp : int;
				for (var i : int = 0; i < idxcnt; i += 3)
				{
					tmp = idx [i + 1];
					idx [i + 1] = idx [i + 2];
					idx [i + 2] = tmp;
				}
			}
		}
		public static function setVertexColorRGB (mesh : IMesh, color : uint) : void
		{
			if ( ! mesh) return;
			var r : int = color >> 16 & 0xFF;
			var g : int = color >> 8 & 0xFF;
			var b : int = color & 0xFF;
			var bcount : int = mesh.getMeshBufferCount ();
			for (var i : int = 0; i < bcount; i ++)
			{
				var buffer : IMeshBuffer = mesh.getMeshBuffer (i);
				var v : Vector.<Vertex> = buffer.getVertices ();
				var vdxcnt : int = buffer.getVertexCount ();
				for (var j : int = 0; j < vdxcnt; j ++)
				{
					v [j].r = r;
					v [j].g = g;
					v [j].b = b;
				}
			}
		}
		// Recalculates all normals of the mesh buffer.
		//@param buffer: Mesh buffer on which the operation is performed.
		private static var plane : Plane3D = new Plane3D ();
		public static function recalculateNormals (buffer : IMeshBuffer, smooth : Boolean) : void
		{
			if ( ! buffer) return;
			var v0 : Vertex;
			var v1 : Vertex;
			var v2 : Vertex;
			var vtx_cnt : int = buffer.getVertexCount ();
			var idx_cnt : int = buffer.getIndexCount ();
			var indices : Vector.<int> = buffer.getIndices ();
			var vertices : Vector.<Vertex> = buffer.getVertices ()
			if ( ! smooth)
			{
				// flat normals
				for (var i : int = 0; i < idx_cnt; i += 3)
				{
					v0 = vertices [indices [i]];
					v1 = vertices [indices [i + 1]];
					v2 = vertices [indices [i + 2]];
					plane.setPlane3 (v0.position , v1.position , v2.position);
					var normal : Vector3D = plane.normal;
					v0.nx = normal.x;
					v0.ny = normal.y;
					v0.nz = normal.z;
					v1.nx = normal.x;
					v1.ny = normal.y;
					v1.nz = normal.z;
					v2.nx = normal.x;
					v2.ny = normal.y;
					v2.nz = normal.z;
				}
			} 
			else
			{
				// smooth normals
				for (i = 0; i < vtx_cnt; i ++)
				{
					v0 = vertices [i]
					v0.nx = 0;
					v0.ny = 0;
					v0.nz = 0;
				}
				for (i = 0; i < idx_cnt; i += 3)
				{
					v0 = vertices [indices [i]];
					v1 = vertices [indices [i + 1]];
					v2 = vertices [indices [i + 2]];
					plane.setPlane3 (v0.position , v1.position , v2.position);
					normal = plane.normal;
					v0.nx = v0.nx + normal.x;
					v0.ny = v0.ny + normal.y;
					v0.nz = v0.nz + normal.z;
					v1.nx = v1.nx + normal.x;
					v1.ny = v1.ny + normal.y;
					v1.nz = v1.nz + normal.z;
					v2.nx = v2.nx + normal.x;
					v2.ny = v2.ny + normal.y;
					v2.nz = v2.nz + normal.z;
				}
				for (i = 0; i < vtx_cnt; i ++)
				{
					v0 = vertices [i];
					var n : Number = Math.sqrt (v0.nx * v0.nx + v0.ny * v0.ny + v0.nz * v0.nz);
					if (n == 0) continue;
					n = 1 / n;
					v0.nx *= n;
					v0.ny *= n;
					v0.nz *= n;
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
				var vertices : Vector.<Vertex> = buffer.getVertices ();
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
			var vertices : Vector.<Vertex> = buffer.getVertices ();
			for (var j : int = 0; j < vtx_cnt; j ++)
			{
				var v : Vertex = vertices [j];
				v.u = (v.x - rect.x) / rect.width;
				v.v = (v.y - rect.y) / rect.height;
			}
		}
		//Fixme 目前的会出现错乱,需要修正...................
		// Creates a planar texture mapping on the mesh
		// @param mesh: Mesh on which the operation is performed.
		// @param resolution: resolution of the planar mapping. This is the value
		// specifying which is the releation between world space and
		// texture coordinate space.
		public static function makePlanarTextureMapping (mesh : IMesh, resolution : Number = 0.01) : void
		{
			if ( ! mesh) return;
			var bcount : int = mesh.getMeshBufferCount ();
			for (var i : int = 0; i < bcount; i ++)
			{
				var buffer : IMeshBuffer = mesh.getMeshBuffer (i);
				var vtx_cnt : int = buffer.getVertexCount ();
				var idx_cnt : int = buffer.getIndexCount ();
				var indices : Vector.<int> = buffer.getIndices ();
				var vertices : Vector.<Vertex> = buffer.getVertices ();
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
			var indices : Vector.<int> = buffer.getIndices ();
			var vertices : Vector.<Vertex> = buffer.getVertices ();
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
		// Clones a static IMesh into a modifyable Mesh.
		public static function cloneMesh (mesh : IMesh) : Mesh
		{
			if ( ! mesh) return null;
			var clone : Mesh = new Mesh ();
			var count : int = mesh.getMeshBufferCount ();
			var _tmpBuffer : IMeshBuffer;
			var vtxCnt : int;
			var idxCnt : int;
			var idx : Vector.<int>;
			var vertices : Vector.<Vertex>;
			var buffer : MeshBuffer;
			var i : int;
			var j : int;
			for (i = 0; i < count; i ++)
			{
				_tmpBuffer = mesh.getMeshBuffer (i);
				vtxCnt = _tmpBuffer.getVertexCount ();
				idxCnt = _tmpBuffer.getIndexCount ();
				idx = _tmpBuffer.getIndices ();
				buffer = new MeshBuffer ();
				buffer.name = (_tmpBuffer as MeshBuffer).name;
				buffer.setMaterial (_tmpBuffer.getMaterial ().clone ());
				//buffer.boundingBox=_tmpBuffer.getBoundingBox().clone();
				vertices = _tmpBuffer.getVertices ();
				for (j = 0; j < vtxCnt; j ++)
				{
					var vertex : Vertex = vertices [j];
					buffer.vertices [j] = vertex.clone ();
				}
				for (j = 0; j < idxCnt; j ++)
				{
					buffer.indices [j] = idx [j];
				}
				buffer.recalculateBoundingBox ();
				clone.addMeshBuffer (buffer);
			}
			clone.recalculateBoundingBox ();
			return clone;
		}
		//只拷贝点的信息，不复制材质
		public static function cloneMeshNoMaterials (mesh : IMesh) : Mesh
		{
			if ( ! mesh) return null;
			var clone : Mesh = new Mesh ();
			var count : int = mesh.getMeshBufferCount ();
			var _tmpBuffer : IMeshBuffer;
			var vtxCnt : int;
			var idxCnt : int;
			var idx : Vector.<int>;
			var vertices : Vector.<Vertex>;
			var buffer : MeshBuffer;
			var i : int;
			var j : int;
			for (i = 0; i < count; i ++)
			{
				_tmpBuffer = mesh.getMeshBuffer (i);
				vtxCnt = _tmpBuffer.getVertexCount ();
				idxCnt = _tmpBuffer.getIndexCount ();
				idx = _tmpBuffer.getIndices ();
				buffer = new MeshBuffer ();
				buffer.name = (_tmpBuffer as MeshBuffer).name;
				//buffer.boundingBox=_tmpBuffer.getBoundingBox().clone();
				vertices = _tmpBuffer.getVertices ();
				for (j = 0; j < vtxCnt; j ++)
				{
					var vertex : Vertex = vertices [j];
					buffer.vertices [j] = vertex.clone ();
				}
				for (j = 0; j < idxCnt; j ++)
				{
					buffer.indices [j] = idx [j];
				}
				buffer.recalculateBoundingBox ();
				clone.addMeshBuffer (buffer);
			}
			clone.recalculateBoundingBox ();
			return clone;
		}
	}
}

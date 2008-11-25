package linda.mesh
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import linda.math.AABBox3D;
	import linda.math.Plane3D;
	import linda.math.Vertex;
	public class MeshManipulator
	{
		public static function flipSurfaces (mesh : IMesh) : void
		{
			if ( ! mesh) return;
			var bcount : int = mesh.getMeshBufferCount ();
			for (var b : int = 0; b < bcount; b+=1)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer(b);
				var idxcnt : int = buffer.indices.length;
				var idx : Vector.<int> = buffer.indices;
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
				var buffer : MeshBuffer = mesh.getMeshBuffer (i);
				var v : Vector.<Vertex> = buffer.vertices;
				var vdxcnt : int = v.length;;
				for (var j : int = 0; j < vdxcnt; j ++)
				{
					v [j].r = r;
					v [j].g = g;
					v [j].b = b;
				}
			}
		}
		public static function recalculateNormals (buffer : MeshBuffer, smooth : Boolean) : void
		{
			if ( ! buffer) return;
			var v0 : Vertex;
			var v1 : Vertex;
			var v2 : Vertex;
			var vtx_cnt : int = buffer.vertices.length;
			var idx_cnt : int = buffer.indices.length;
			var indices : Vector.<int> = buffer.indices;
			var vertices : Vector.<Vertex> = buffer.vertices;
			var plane:Plane3D=new Plane3D();
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
			plane=null;
		}
		//首先确保MeshBuffer的包围盒已经计算
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
				var buffer : MeshBuffer = mesh.getMeshBuffer (i);
				
				var vertices : Vector.<Vertex> = buffer.vertices;
				var vtx_cnt : int = vertices.length;
				
				for (var j : int = 0; j < vtx_cnt; j ++)
				{
					var v : Vertex = vertices [j];
					v.u = (v.x - rect.x) / rect.width;
					v.v = (v.y - rect.y) / rect.height;
				}
			}
		}
		public static function unwrapUVMeshBuffer (buffer : MeshBuffer) : void
		{
			if ( ! buffer) return;
			buffer.recalculateBoundingBox ();
			var box : AABBox3D = buffer.boundingBox;
			box.repair ();
			if (box.isEmpty ()) return;
			var rect : Rectangle = new Rectangle (box.minX, box.minY, (box.maxX - box.minX) , (box.maxY - box.minY));
			var vtx_cnt : int = buffer.vertices.length;
			var vertices : Vector.<Vertex> = buffer.vertices;
			for (var j : int = 0; j < vtx_cnt; j ++)
			{
				var v : Vertex = vertices [j];
				v.u = (v.x - rect.x) / rect.width;
				v.v = (v.y - rect.y) / rect.height;
			}
		}

		public static function makePlanarTextureMapping (mesh : IMesh, resolution : Number = 0.01) : void
		{
			if ( ! mesh) return;
			var plane:Plane3D=new Plane3D();
			var bcount : int = mesh.getMeshBufferCount ();
			for (var i : int = 0; i < bcount; i ++)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer (i);
				var vtx_cnt : int = buffer.vertices.length;
				var idx_cnt : int = buffer.indices.length;
				var indices : Vector.<int> = buffer.indices;
				var vertices : Vector.<Vertex> = buffer.vertices;
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
			plane=null;
		}
		public static function makeMeshBufferPlanarTextureMapping (buffer : MeshBuffer, resolution : Number = 0.01) : void
		{
			var vtx_cnt : int = buffer.vertices.length;
			var idx_cnt : int = buffer.indices.length;
			var indices : Vector.<int> = buffer.indices;
			var vertices : Vector.<Vertex> = buffer.vertices;
			var plane:Plane3D=new Plane3D();
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
			plane=null;
		}
		public static function cloneMesh (mesh : IMesh) : Mesh
		{
			if ( ! mesh) return null;
			var clone : Mesh = new Mesh ();
			var count : int = mesh.getMeshBufferCount ();
			var _tmpBuffer : MeshBuffer;
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
				vtxCnt = _tmpBuffer.vertices.length;
				idxCnt = _tmpBuffer.indices.length;
				idx = _tmpBuffer.indices;
				buffer = new MeshBuffer ();
				buffer.material= _tmpBuffer.material.clone();
				vertices = _tmpBuffer.vertices;
				for (j = 0; j < vtxCnt; j ++)
				{
					var vertex : Vertex = vertices[j];
					buffer.vertices[j] = vertex.clone();
				}
				for (j = 0; j < idxCnt; j ++)
				{
					buffer.indices[j] = idx [j];
				}
				buffer.recalculateBoundingBox ();
				clone.addMeshBuffer(buffer);
			}
			clone.recalculateBoundingBox ();
			return clone;
		}
		public static function cloneMeshWithoutMaterial (mesh : IMesh) : Mesh
		{
			if ( ! mesh) return null;
			var clone : Mesh = new Mesh ();
			var count : int = mesh.getMeshBufferCount ();
			var _tmpBuffer : MeshBuffer;
			var vtxCnt : int;
			var idxCnt : int;
			var idx : Vector.<int>;
			var vertices : Vector.<Vertex>;
			var buffer : MeshBuffer;
			var i : int;
			var j : int;
			for (i = 0; i < count; i ++)
			{
				_tmpBuffer = mesh.getMeshBuffer(i);
				vtxCnt = _tmpBuffer.vertices.length;
				idxCnt = _tmpBuffer.indices.length;
				idx = _tmpBuffer.indices;
				buffer = new MeshBuffer ();
				vertices = _tmpBuffer.vertices;
				for (j = 0; j < vtxCnt; j ++)
				{
					var vertex : Vertex = vertices [j];
					buffer.vertices[j] = vertex.clone ();
				}
				for (j = 0; j < idxCnt; j ++)
				{
					buffer.indices[j] = idx[j];
				}
				buffer.recalculateBoundingBox();
				clone.addMeshBuffer(buffer);
			}
			clone.recalculateBoundingBox();
			return clone;
		}
	}
}

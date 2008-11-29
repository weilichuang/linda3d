package linda.mesh;

	import flash.Vector;
	
	import flash.geom.Rectangle;
	
	import linda.math.MathUtil;
	import linda.math.Vector3;
	import linda.math.AABBox3D;
	import linda.math.Plane3D;
	import linda.math.Vertex;
	class MeshManipulator
	{
		public function new()
		{
			
		}
		public static inline function flipSurfaces (mesh : IMesh) : Void
		{
			var bcount : Int = mesh.getMeshBufferCount ();
			for (b in 0...bcount)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer(b);
				var idxcnt : Int = buffer.indices.length;
				var idx : Vector<Int> = buffer.indices;
				var tmp : Int;
				var i : Int = 0;
				while (i < idxcnt)
				{
					tmp = idx [i + 1];
					idx [i + 1] = idx [i + 2];
					idx [i + 2] = tmp;
					i += 3;
				}
			}
		}
		public static inline function setVertexColorRGB (mesh : IMesh, color : UInt) : Void
		{
			var r : Int = color >> 16 & 0xFF;
			var g : Int = color >> 8 & 0xFF;
			var b : Int = color & 0xFF;
			var bcount : Int = mesh.getMeshBufferCount ();
			for ( i in 0...bcount)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer (i);
				var v : Vector<Vertex> = buffer.vertices;
				var vdxcnt : Int = v.length;
				for ( j in 0...vdxcnt)
				{
					var vx:Vertex = v[j];
					vx.r = r;
					vx.g = g;
					vx.b = b;
				}
			}
		}
		public static inline function recalculateNormals (buffer : MeshBuffer, smooth : Bool) : Void
		{
			var normal:Vector3;
			var v0 : Vertex;
			var v1 : Vertex;
			var v2 : Vertex;
			var vtx_cnt : Int = buffer.vertices.length;
			var idx_cnt : Int = buffer.indices.length;
			var indices : Vector<Int> = buffer.indices;
			var vertices : Vector<Vertex> = buffer.vertices;
			var plane:Plane3D=new Plane3D();
			if ( ! smooth)
			{
				// flat normals
				var i:Int = 0;
				while ( i < idx_cnt)
				{
					v0 = vertices [indices [i]];
					v1 = vertices [indices [i + 1]];
					v2 = vertices [indices [i + 2]];
					plane.setPlane3 (v0.position , v1.position , v2.position);
					normal = plane.normal;
					v0.nx = normal.x;
					v0.ny = normal.y;
					v0.nz = normal.z;
					v1.nx = normal.x;
					v1.ny = normal.y;
					v1.nz = normal.z;
					v2.nx = normal.x;
					v2.ny = normal.y;
					v2.nz = normal.z;
					
					i += 3;
				}
			} 
			else
			{
				// smooth normals
				for (i in 0...vtx_cnt)
				{
					v0 = vertices[i];
					v0.nx = 0;
					v0.ny = 0;
					v0.nz = 0;
				}
				var i:Int = 0;
				while ( i < idx_cnt)
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
					
					i += 3;
				}
				for (i in 0...vtx_cnt)
				{
					v0 = vertices[i];
					v0.normalize();
				}
			}
			plane=null;
		}
		//首先确保MeshBuffer的包围盒已经计算
		public static inline function unwrapUV (mesh : IMesh) : Void
		{
			mesh.recalculateBoundingBox ();
			var box : AABBox3D = mesh.getBoundingBox ();
			box.repair ();
			if (box.isEmpty ()) return;
			var rect : Rectangle = new Rectangle (box.minX, box.minY, (box.maxX - box.minX) , (box.maxY - box.minY));
			var bcount : Int = mesh.getMeshBufferCount ();
			for ( i in 0...bcount)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer (i);
				
				var vertices : Vector<Vertex> = buffer.vertices;
				var vtx_cnt : Int = vertices.length;
				
				for ( j in 0...vtx_cnt)
				{
					var v : Vertex = vertices[j];
					v.u = (v.x - rect.x) / rect.width;
					v.v = (v.y - rect.y) / rect.height;
				}
			}
		}
		public static inline function unwrapUVMeshBuffer (buffer : MeshBuffer) : Void
		{
			buffer.recalculateBoundingBox ();
			var box : AABBox3D = buffer.boundingBox;
			box.repair ();
			if (box.isEmpty ()) return;
			var rect : Rectangle = new Rectangle (box.minX, box.minY, (box.maxX - box.minX) , (box.maxY - box.minY));
			var vtx_cnt : Int = buffer.vertices.length;
			var vertices : Vector<Vertex> = buffer.vertices;
			for (j in 0...vtx_cnt)
			{
				var v : Vertex = vertices [j];
				v.u = (v.x - rect.x) / rect.width;
				v.v = (v.y - rect.y) / rect.height;
			}
		}

		public static inline function makePlanarTextureMapping (mesh : IMesh, ?resolution : Float = 0.01) : Void
		{
			var plane:Plane3D=new Plane3D();
			var bcount : Int = mesh.getMeshBufferCount ();
			var i:Int = 0;
			while (i < bcount)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer (i);
				var vtx_cnt : Int = buffer.vertices.length;
				var idx_cnt : Int = buffer.indices.length;
				var indices : Vector<Int> = buffer.indices;
				var vertices : Vector<Vertex> = buffer.vertices;
				
				var j:Int = 0;
				while (j < idx_cnt)
				{
					var v0 : Vertex = vertices [indices [j]];
					var v1 : Vertex = vertices [indices [j + 1]];
					var v2 : Vertex = vertices [indices [j + 2]];
					plane.setPlane3 (v0.position , v1.position , v2.position);
					var normal : Vector3 = plane.normal;
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
					
					j += 3;
				}
				i++;
			}
			plane=null;
		}
		public static inline function makeMeshBufferPlanarTextureMapping (buffer : MeshBuffer, ?resolution : Float = 0.01) : Void
		{
			var vtx_cnt : Int = buffer.vertices.length;
			var idx_cnt : Int = buffer.indices.length;
			var indices : Vector<Int> = buffer.indices;
			var vertices : Vector<Vertex> = buffer.vertices;
			var plane:Plane3D = new Plane3D();
			var j:Int = 0;
			while (j < idx_cnt)
			{
				var v0 : Vertex = vertices [indices [j]];
				var v1 : Vertex = vertices [indices [j + 1]];
				var v2 : Vertex = vertices [indices [j + 2]];
				plane.setPlane3 (v0.position , v1.position , v2.position);
				var normal : Vector3 = plane.normal;
				normal.x = MathUtil.abs(normal.x);
				normal.y = MathUtil.abs(normal.y);
				normal.z = MathUtil.abs(normal.z);
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
				
				
				j += 3;
			}
			plane=null;
		}
		public static inline function cloneMesh (mesh : IMesh) : Mesh
		{
			var clone : Mesh = new Mesh ();
			var count : Int = mesh.getMeshBufferCount ();
			var _tmpBuffer : MeshBuffer;
			var vtxCnt : Int;
			var idxCnt : Int;
			var idx : Vector<Int>;
			var vertices : Vector<Vertex>;
			var buffer : MeshBuffer;
			for (i in 0...count)
			{
				_tmpBuffer = mesh.getMeshBuffer (i);
				vtxCnt = _tmpBuffer.vertices.length;
				idxCnt = _tmpBuffer.indices.length;
				idx = _tmpBuffer.indices;
				buffer = new MeshBuffer ();
				buffer.material= _tmpBuffer.material.clone();
				vertices = _tmpBuffer.vertices;
				for (j in 0...vtxCnt)
				{
					var vertex : Vertex = vertices[j];
					buffer.vertices[j] = vertex.clone();
				}
				for (j in 0...idxCnt)
				{
					buffer.indices[j] = idx [j];
				}
				buffer.recalculateBoundingBox ();
				clone.addMeshBuffer(buffer);
			}
			clone.recalculateBoundingBox ();
			return clone;
		}
		public static inline function cloneMeshWithoutMaterial (mesh : IMesh) : Mesh
		{
			var clone : Mesh = new Mesh ();
			var count : Int = mesh.getMeshBufferCount ();
			var _tmpBuffer : MeshBuffer;
			var vtxCnt : Int;
			var idxCnt : Int;
			var idx : Vector<Int>;
			var vertices : Vector<Vertex>;
			var buffer : MeshBuffer;
			for (i in 0...count)
			{
				_tmpBuffer = mesh.getMeshBuffer(i);
				vtxCnt = _tmpBuffer.vertices.length;
				idxCnt = _tmpBuffer.indices.length;
				idx = _tmpBuffer.indices;
				buffer = new MeshBuffer ();
				vertices = _tmpBuffer.vertices;
				for (j in 0...vtxCnt)
				{
					var vertex : Vertex = vertices [j];
					buffer.vertices[j] = vertex.clone ();
				}
				for (j in 0...idxCnt)
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


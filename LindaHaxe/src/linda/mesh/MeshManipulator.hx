package linda.mesh;

	import flash.geom.Matrix;
	import flash.Vector;
	import linda.math.Matrix4;
	import linda.mesh.IAnimatedMesh;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import linda.math.MathUtil;
	import linda.math.Vector3;
	import linda.math.AABBox3D;
	import linda.math.Plane3D;
	import linda.math.Vertex;
	
	
class MeshManipulator
{
		public static inline function setBufferColor (buffer:MeshBuffer,color : UInt) : Void
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			var r : Int = color >> 16 & 0xFF;
			var g : Int = color >> 8 & 0xFF;
			var b : Int = color & 0xFF;
			var len : Int = vertices.length;
			var vertex:Vertex;
			for (j in 0...len)
			{
				vertex=vertices[j];
				vertex.r = r;
				vertex.g = g;
				vertex.b = b;
			}
		}
		public static inline function transformBuffer(buffer:MeshBuffer,m:Matrix4):Void 
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			var boundingBox:AABBox3D = buffer.getBoundingBox();
			var len:Int = vertices.length;
			var vertex:Vertex = vertices[0];
			m.transformVertex(vertex,true);
			boundingBox.resetVertex(vertex);
			for (i in 1...len)
			{
				vertex = vertices[i];
				m.transformVertex(vertex,true);
				boundingBox.addVertex(vertex);
			}
		}
		
		private static var vp0:Vector3 = new Vector3();
		private static var vp1:Vector3 = new Vector3();
		private static var vp2:Vector3 = new Vector3();
		private static var plane:Plane3D = new Plane3D();
		public static inline function recalculateBufferNormals (buffer:MeshBuffer,?smooth : Bool=true,?angleWeighted:Bool=true) : Void
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			var indices:Vector<Int>=buffer.getIndices();
			var normal:Vector3;
			var v0 : Vertex;
			var v1 : Vertex;
			var v2 : Vertex;
			var vtx_count : Int = vertices.length;
			var idx_count : Int = indices.length;
			if ( ! smooth)
			{
				// flat normals
				var i:Int = 0;
				while ( i < idx_count)
				{
					v0 = vertices [indices [i]];
					v1 = vertices [indices [i + 1]];
					v2 = vertices [indices [i + 2]];
					vp0.x = v0.x; vp0.y = v0.y; vp0.z = v0.z;
					vp1.x = v1.x; vp1.y = v1.y; vp1.z = v1.z;
					vp2.x = v2.x; vp2.y = v2.y; vp2.z = v2.z;
					plane.setPlane3 (vp0 , vp1 , vp2);
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
			} else {
				// smooth normals
				for (i in 0...vtx_count)
				{
					v0 = vertices[i];
					v0.nx = 0;
					v0.ny = 0;
					v0.nz = 0;
				}
				var i:Int = 0;
				while ( i < idx_count)
				{
					v0 = vertices [indices [i]];
					v1 = vertices [indices [i + 1]];
					v2 = vertices [indices [i + 2]];
					vp0.x = v0.x; vp0.y = v0.y; vp0.z = v0.z;
					vp1.x = v1.x; vp1.y = v1.y; vp1.z = v1.z;
					vp2.x = v2.x; vp2.y = v2.y; vp2.z = v2.z;
					plane.setPlane3 (vp0 , vp1 , vp2);
					normal = plane.normal;
					if (angleWeighted)
					{
						var angle:Vector3 = MathUtil.getAngleWeight(vp0 , vp1 , vp2);
						normal.x *= angle.x;
						normal.y *= angle.y;
						normal.z *= angle.z;
					}
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
				for (i in 0...vtx_count)
				{
					vertices[i].normalize();
				}
			}
		}
		public static inline function scaleBufferTCoords(buffer:MeshBuffer,factor:Point):Void 
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			var len:Int = vertices.length;
			for (i in 0...len)
			{
				vertices[i].u *= factor.x;
				vertices[i].v *= factor.y;
			}
		}
		public static inline function makeBufferPlanarTextureMapping (buffer:MeshBuffer,?resolution : Float = 0.01) : Void
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			var indices:Vector<Int>=buffer.getIndices();
			var vtx_cnt : Int = vertices.length;
			var idx_cnt : Int = indices.length;
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
				} else if (normal.y > normal.x && normal.y > normal.z)
				{
					v0.u = v0.x * resolution;
					v0.v = v0.z * resolution;
					v1.u = v1.x * resolution;
					v1.v = v1.z * resolution;
					v2.u = v2.x * resolution;
					v2.v = v2.z * resolution;
				} else
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
		}
		/**
		 * this will change the center of MeshBuffer.
		 * @param	value
		 */
		public static inline function translateBuffer(buffer:MeshBuffer,value:Vector3):Void 
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			var x:Float = value.x;
			var y:Float = value.y;
			var z:Float = value.z;
			var len : Int = vertices.length;
			var i : Int = 0;
			while (i < len)
			{
				var vertex:Vertex = vertices[i];
				vertex.x += x;
				vertex.y += y;
				vertex.z += z;	
				i++;
			}
		}
		/**
		 * this will change the shape of MeshBuffer.
		 * @param	value
		 */
		public static inline function scaleBuffer(buffer:MeshBuffer,value:Vector3):Void 
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			var sx:Float = value.x;
			var sy:Float = value.y;
			var sz:Float = value.z;
			var len : Int = vertices.length;
			for( i in 0...len)
			{
				var vertex:Vertex = vertices[i];
				vertex.x *= sx;
				vertex.y *= sy;
				vertex.z *= sz;
			}
		}
		/**
		 * this will change the shape of MeshBuffer.
		 * @param	value
		 */
		private static var matrix:Matrix4 = new Matrix4();
		public static inline function rotateBuffer(buffer:MeshBuffer,value:Vector3):Void 
		{
			var vertices:Vector<Vertex>=buffer.getVertices();
			matrix.setRotation(value);
			var len : Int = vertices.length;
			for( i in 0...len)
			{
				matrix.rotateVertex(vertices[i],true);
			}
		}
		/**
		 * this will flip all faces of this MeshBuffer.
		 * @param	value
		 */
		public static inline function flipBufferSurfaces (buffer:MeshBuffer) : Void
		{
			var indices:Vector<Int>=buffer.getIndices();
			var len : Int = indices.length;
			var tmp : Int;
			var i : Int = 0;
			while (i < len)
			{
				tmp = indices [i + 1];
				indices [i + 1] = indices [i + 2];
				indices [i + 2] = tmp;
				i += 3;
			}
		}
		
		public static function scaleMesh(mesh:IMesh, value:Vector3):Void 
		{
			var count : Int = mesh.getMeshBufferCount();
			for (j in 0...count)
			{
				scaleBuffer(mesh.getMeshBuffer(j),value);
			}
		}
		
		public static function translateMesh(mesh:IMesh, value:Vector3):Void 
		{
			var count : Int = mesh.getMeshBufferCount();
			for (j in 0...count)
			{
				translateBuffer(mesh.getMeshBuffer(j),value);
			}
		}
		
		public static function setMeshColor(mesh : IMesh, color : UInt) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for ( i in 0...count)
			{
				setBufferColor(mesh.getMeshBuffer(i),color);
			}
		}

		public static function flipMeshSurfaces (mesh : IMesh) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				flipBufferSurfaces(mesh.getMeshBuffer(j));
			}
		}
		public static function recalculateMeshNormals (mesh : IMesh,?smooth=false,?angleWeighted:Bool=true) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				recalculateBufferNormals(mesh.getMeshBuffer(j),smooth,angleWeighted);
			}
		}
		
		public static function makeMeshPlanarTextureMapping (mesh : IMesh, ?resolution : Float = 0.01) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				makeBufferPlanarTextureMapping(mesh.getMeshBuffer(j),resolution);
			}
		}
		
		public static function transformMesh(mesh:IMesh,m:Matrix4):Void 
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				transformBuffer(mesh.getMeshBuffer(j),m);
			}
		}
		
		public static function cloneMesh (mesh : IMesh) : Mesh
		{
			var newMesh : Mesh = new Mesh ();
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				var buffer:MeshBuffer = mesh.getMeshBuffer(j).clone();
				newMesh.addMeshBuffer(buffer);
			}
			newMesh.recalculateBoundingBox ();
			return newMesh;
		}
		public static function getMeshPolyCount(mesh:IMesh):Int
		{
			var trianglecount:Int = 0;
            
			var count:Int = mesh.getMeshBufferCount();
			for (i in 0...count)
			{
				trianglecount += Std.int(mesh.getMeshBuffer(i).indices.length/3);
			}

			return trianglecount;
		}
		public static function getAnimateMeshPolyCount(mesh:IAnimatedMesh):Int
		{
			if (mesh != null && mesh.getFrameCount() != 0)
			{
			    return getMeshPolyCount(mesh.getMesh(0));
			}else
			{
				return 0;
			}
		}
}


package linda.mesh;

	import flash.geom.Point;
	import flash.Vector;
	import linda.math.MathUtil;
	import linda.math.Matrix4;
	import linda.math.Plane3D;
	import linda.math.Vector3;
	
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Vertex;

class MeshBuffer
{
		public var material : Material;
		public var vertices : Vector<Vertex>;
		public var indices : Vector<Int>;
		public var boundingBox : AABBox3D;
		public function new ()
		{
			vertices = new Vector<Vertex> ();
			indices = new Vector<Int> ();
			boundingBox = new AABBox3D ();
			material = new Material ();
		}
		/**
		 * 
		 * @param	color set All Vertexs color
		 */
		public inline function setColor (color : UInt) : Void
		{
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
		public inline function transform(m:Matrix4):Void 
		{
			var vtxcnt:Int = vertices.length;
			for (i in 0...vtxcnt)
			{
				var vertex:Vertex = vertices[i];
				m.transformVertex(vertex,true);
				if (i == 0)
				{
					boundingBox.resetVertex(vertex);
				}else 
				{
					boundingBox.addVertex(vertex);
				}
			}
		}
		public inline function recalculateNormals (?smooth : Bool=false) : Void
		{
			var normal:Vector3;
			var v0 : Vertex;
			var v1 : Vertex;
			var v2 : Vertex;
			var vtx_cnt : Int = vertices.length;
			var idx_cnt : Int = indices.length;
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
		public inline function scaleTCoords(factor:Point):Void 
		{
			var vtxcnt:Int = this.vertices.length;
			for (i in 0...vtxcnt)
			{
				var vertex:Vertex = vertices[i];
				vertex.u *= factor.x;
				vertex.v *= factor.y;
			}
		}
		public inline function makePlanarTextureMapping (?resolution : Float = 0.01) : Void
		{
			var vtx_cnt : Int = vertices.length;
			var idx_cnt : Int = indices.length;
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
		/**
		 * this will change the center of MeshBuffer.
		 * @param	value
		 */
		public inline function translate(value:Vector3):Void 
		{
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
		public inline function scale(value:Vector3):Void 
		{
			var sx:Float = value.x;
			var sy:Float = value.y;
			var sz:Float = value.z;
			var len : Int = vertices.length;
			var i : Int = 0;
			while (i < len)
			{
				var vertex:Vertex = vertices[i];
				vertex.x *= sx;
				vertex.y *= sy;
				vertex.z *= sz;
				i++;
			}
		}
		/**
		 * this will change the shape of MeshBuffer.
		 * @param	value
		 */
		public inline function rotate(value:Vector3):Void 
		{
			var matrix:Matrix4 = new Matrix4();
			matrix.setRotation(value);
			var len : Int = vertices.length;
			var i : Int = 0;
			while (i < len)
			{
				matrix.rotateVertex(vertices[i],true);
				i++;
			}
			matrix = null;
		}
		/**
		 * this will flip all faces of this MeshBuffer.
		 * @param	value
		 */
		public inline function flipSurfaces () : Void
		{
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
		
		public inline function getVertex(i:Int):Vertex
		{
			if ( i<0 || i >=vertices.length) return null;
			return vertices[i];
		}
		public inline function recalculateBoundingBox () : Void
		{
			boundingBox.identity();
			var len : Int = vertices.length;
			for (i in 0...len)
			{
				if (i == 0)
				{
					boundingBox.resetVertex(vertices[0]);
				}else
				{
					boundingBox.addVertex(vertices[i]);
				}
			}
		}
		public inline function append (verts : Vector<Vertex>, numVertices : Int, inds : Vector<Int>, numIndices : Int) : Void
		{
			var vertexCount : Int = vertices.length;
			var vertex:Vertex;
			for (i in 0...numVertices)
			{
				vertex = verts[i];
				vertices.push(vertex);
				boundingBox.addVertex(vertex);
			}
			for (i in 0...numIndices)
			{
				indices.push (inds[i] + vertexCount);
			}
		}
		public inline function appendMeshBuffer (other : MeshBuffer) : Void
		{
            //concat vertices;
			vertices.concat(other.vertices);
			
			var vertexCount : Int = vertices.length;
			var indexLen:Int=other.indices.length;
			for (i in 0...indexLen)
			{
				indices.push (other.indices[i] + vertexCount);
			}
			boundingBox.addAABBox (other.boundingBox);
		}
		public inline function clone():MeshBuffer
		{
			var buffer:MeshBuffer = new MeshBuffer();
			buffer.material = material.clone();
			buffer.indices = indices.concat(null);
			var len:Int = vertices.length;
			for (i in 0...len)
			{
				buffer.vertices[i].copy(vertices[i]);
			}
			buffer.boundingBox = this.boundingBox.clone();
			return buffer;
		}
}


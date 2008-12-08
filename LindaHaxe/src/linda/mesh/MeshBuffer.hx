package linda.mesh;

	import flash.Vector;
	import linda.math.Matrix4;
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
		 * @param	color set All Vertex color
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
			var x:Float = value.x;
			var y:Float = value.y;
			var z:Float = value.z;
			var len : Int = vertices.length;
			var i : Int = 0;
			while (i < len)
			{
				var vertex:Vertex = vertices[i];
				vertex.x *= x;
				vertex.y *= y;
				vertex.z *= z;
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
				matrix.rotateVertex(vertices[i]);
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
			var otherindexC:Int=other.indices.length;
			var otherIndices:Vector<Int>=other.indices;
			for (i in 0...otherindexC)
			{
				indices.push (otherIndices[i] + vertexCount);
			}
			boundingBox.addAABBox (other.boundingBox);
		}
	}


package linda.mesh;

	import flash.Vector;
	
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
		public inline function setVertexColor (color : UInt) : Void
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
		public function getVertex(i:Int):Vertex
		{
			if ( i<0 || i >=vertices.length) return null;
			return vertices[i];
		}
		public inline function recalculateBoundingBox () : Void
		{
			var len : Int = vertices.length;
			if(len > 0)
			{
			     // reset bounding box with first vertex
			     var vertex : Vertex = vertices [0];
			     boundingBox.resetVertex(vertex);
			     for (i in 1...len)
			     {
				     boundingBox.addVertex(vertices[i]);
			     }
			}
		}
		public function append (verts : Vector<Vertex>, numVertices : Int, inds : Vector<Int>, numIndices : Int) : Void
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
		public function appendMeshBuffer (other : MeshBuffer) : Void
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


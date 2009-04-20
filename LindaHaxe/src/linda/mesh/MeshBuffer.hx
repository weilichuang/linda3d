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
        public inline function getIndices():Vector<Int>
		{
			return indices;
		}
		public inline function getVertices():Vector<Vertex>
		{
			return vertices;
		}
		public inline function getBoundingBox():AABBox3D
		{
			return boundingBox;
		}
		public inline function getMaterial():Material
		{
			return material;
		}
		public inline function getVertex(i:Int):Vertex
		{
			if ( i<0 || i >=vertices.length) return null;
			return vertices[i];
		}
		public inline function recalculateBoundingBox () : Void
		{
			boundingBox.resetVertex(vertices[0]);
			var len : Int = vertices.length;
			for (i in 1...len)
			{
				boundingBox.addVertex(vertices[i]);
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
			buffer.boundingBox = boundingBox.clone();
			return buffer;
		}
}


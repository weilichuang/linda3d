package mini3d.mesh
{
	import mini3d.core.Material;
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	public class MeshBuffer
	{
		public var material : Material;
		public var vertices : Array;
		public var indices : Array;
		public var boundingBox : AABBox3D;
		public var name : String ;
		public function MeshBuffer ()
		{
			vertices = new Array ();
			indices = new Array ();
			boundingBox = new AABBox3D ();
			material = new Material ();
			name="";
		}
		public function getVertex(i:int):Vertex
		{
			if(i<0 || i>=vertices.length) return null;
			return vertices[i];
		}
		public function getVertexCount () : int
		{
			return vertices.length;
		}
		public function getIndexCount () : int
		{
			return indices.length;
		}
		public function recalculateBoundingBox () : void
		{
			var l : int = vertices.length;
			var i:int;
			if(l > 0)
			{
			     // reset bounding box with first vertex
			     var vertex : Vertex = vertices [0];
			     boundingBox.resetVertex(vertex);
			     for (i = 1; i < l; i+=1)
			     {
				     vertex = vertices [i];
				     boundingBox.addVertex(vertex);
			     }
			}
		}
		// append the vertices and indices to the current buffer
		public function append (verts : Array, numVertices : int, inds : Array, numIndices : int) : void
		{
			var vertexCount : int = getVertexCount ();
			var i:int;
			var vertex:Vertex;
			for (i = 0; i < numVertices; i+=1)
			{
				vertex = verts [i];
				vertices.push (vertex);
				boundingBox.addVertex(vertex);
			}
			for (i = 0; i < numIndices; i+=1)
			{
				indices.push (int(inds [i] + vertexCount));
			}
		}
		public function appendMeshBuffer (other : MeshBuffer) : void
		{
			
            //concat vertices;
			vertices.concat(other.vertices);
			
			//concat indices ,should add getVertexCount ();
			var i:int;
			var vertexCount : int = getVertexCount ();
			var otherindexC:int=other.getIndexCount();
			var otherIndices:Array=other.indices;
			for (i = 0; i < otherindexC; i+=1)
			{
				var index:int=otherIndices[i];
				indices.push (index + vertexCount);
			}
			boundingBox.addBox (other.boundingBox);
		}
		public function toString():String
		{
			return name;
		}
	}
}

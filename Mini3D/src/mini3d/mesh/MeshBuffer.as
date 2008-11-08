package mini3d.mesh
{
	import mini3d.core.Material;
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	public class MeshBuffer implements IMeshBuffer
	{
		private var material : Material;
		private var vertices : Array;
		private var indices : Array;
		private var boundingBox : AABBox3D;
		public var name : String ;
		public function MeshBuffer ()
		{
			vertices = new Array ();
			indices = new Array ();
			boundingBox = new AABBox3D ();
			material = new Material ();
			name="";
		}
		public function getMaterial () : Material
		{
			return material;
		}
		public function setMaterial (mat : Material) : void
		{
			material = mat;
		}
		public function getVertices () : Array
		{
			return vertices;
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
		public function getIndices () : Array
		{
			return indices;
		}
		public function getIndexCount () : int
		{
			return indices.length;
		}
		public function setBoundingBox (box : AABBox3D) : void
		{
			boundingBox = box;
		}
		public function getBoundingBox () : AABBox3D
		{
			return boundingBox;
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
				     boundingBox.addXYZ (vertex.x, vertex.y, vertex.z);
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
				boundingBox.addXYZ (vertex.x, vertex.y, vertex.z);
			}
			for (i = 0; i < numIndices; i+=1)
			{
				indices.push (int(inds [i] + vertexCount));
			}
		}
		public function appendMeshBuffer (other : IMeshBuffer) : void
		{
			
            //concat vertices;
			vertices.concat(other.getVertices());
			
			//concat indices ,should add getVertexCount ();
			var i:int;
			var vertexCount : int = getVertexCount ();
			var otherindexC:int=other.getIndexCount();
			var otherIndices:Array=other.getIndices ();
			for (i = 0; i < otherindexC; i+=1)
			{
				var index:int=otherIndices[i];
				indices.push (index + vertexCount);
			}
			boundingBox.addBox (other.getBoundingBox ());
		}
		public function toString():String
		{
			return name;
		}
	}
}

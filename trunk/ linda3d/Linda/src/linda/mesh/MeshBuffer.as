package linda.mesh
{
	import __AS3__.vec.Vector;
	
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Vertex;
	public class MeshBuffer implements IMeshBuffer
	{
		public var material : Material;
		public var vertices : Vector.<Vertex>;
		public var indices : Vector.<int>;
		public var boundingBox : AABBox3D;
		public function MeshBuffer ()
		{
			vertices = new Vector.<Vertex> ();
			indices = new Vector.<int> ();
			boundingBox = new AABBox3D ();
			material = new Material ();
		}
		public function setVertexColor (color : uint) : void
		{
			var r : int = color >> 16 & 0xFF;
			var g : int = color >> 8 & 0xFF;
			var b : int = color & 0xFF;
			var vdxcnt : int = vertices.length;
			var j:int;
			var vertex:Vertex;
			for (j = 0; j < vdxcnt; j+=1)
			{
				vertex=vertices [j];
				vertex.r = r;
				vertex.g = g;
				vertex.b = b;
			}
		}
		public function getMaterial () : Material
		{
			return material;
		}
		public function setMaterial (mat : Material) : void
		{
			material = mat;
		}
		public function getVertices () : Vector.<Vertex>
		{
			return vertices;
		}
		public function getVertex(i:int):Vertex
		{
			return vertices[i];
		}
		public function getVertexCount () : int
		{
			return vertices.length;
		}
		public function getIndices () : Vector.<int>
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
		public function append (verts : Vector.<Vertex>, numVertices : int, inds : Vector.<int>, numIndices : int) : void
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
			
			var i:int;
			var vertexCount : int = getVertexCount ();
			var otherindexC:int=other.getIndexCount();
			var otherIndices:Vector.<int>=other.getIndices ();
			for (i = 0; i < otherindexC; i+=1)
			{
				var index:int=otherIndices[i];
				indices.push (index + vertexCount);
			}
			boundingBox.addAABBox (other.getBoundingBox ());
		}
	}
}

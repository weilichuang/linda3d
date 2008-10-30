package linda.mesh.objects
{
	import __AS3__.vec.Vector;
	
	import linda.math.AABBox3D;
	import linda.math.Vertex;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.utils.MeshManipulator;
	public class Cube extends Mesh
	{
		private var meshBuffer : MeshBuffer;
		public function Cube (len : Number = 100, width : Number = 100, height : Number = 100)
		{
			super ();
			meshBuffer = new MeshBuffer ();
			createCube (len, width, height);
			MeshManipulator.recalculateNormals (meshBuffer, true);
			meshBuffers.push (meshBuffer);
			recalculateBoundingBox ();
		}
		private function createCube (len : Number, width : Number, height : Number) : void
		{
			var indices : Vector.<int> = new Vector.<int>(36,true);
			indices.push(0, 2, 1, 0, 3, 2, 1, 5, 4, 1, 2, 5, 4, 6, 7, 4, 5, 6,
			             7, 3, 0, 7, 6, 3, 9, 5, 2, 9, 8, 5, 0, 11, 10, 0, 10, 7);
			var color : uint = 0xffffff;
			var vertices : Vector.<Vertex> = new Vector.<Vertex>(12,true);
			vertices [0] = new Vertex (0, 0, 0, -1, -1, -1, color, 0, 1);
			vertices [1] = new Vertex (1, 0, 0,  1, -1, -1, color, 1, 1);
			vertices [2] = new Vertex (1, 1, 0,  1,  1, -1, color, 1, 0);
			vertices [3] = new Vertex (0, 1, 0, -1,  1, -1, color, 0, 0);
			vertices [4] = new Vertex (1, 0, 1,  1, -1,  1, color, 0, 1);
			vertices [5] = new Vertex (1, 1, 1,  1,  1,  1, color, 0, 0);
			vertices [6] = new Vertex (0, 1, 1, -1,  1,  1, color, 1, 0);
			vertices [7] = new Vertex (0, 0, 1, -1, -1,  1, color, 1, 1);
			vertices [8] = new Vertex (0, 1, 1, -1,  1,  1, color, 0, 1);
			vertices [9] = new Vertex (0, 1, 0, -1,  1, -1, color, 1, 1);
			vertices [10]= new Vertex (1, 0, 1,  1, -1,  1, color, 1, 0);
			vertices [11]= new Vertex (1, 0, 0,  1, -1, -1, color, 0, 0);
			var box : AABBox3D = new AABBox3D ();
			for (var i : int = 0; i < 12; i ++)
			{
				var vertex : Vertex = vertices [i];
				vertex.x -= 0.5;
				vertex.y -= 0.5;
				vertex.z -= 0.5;
				vertex.x *= width;
				vertex.y *= height;
				vertex.z *= len;
				box.addInternalPointXYZ (vertex.x, vertex.y, vertex.z);
			}
			meshBuffer.indices = indices;
			meshBuffer.vertices = vertices;
			meshBuffer.boundingBox = box;
		}
	}
}

package linda.mesh.objects
{
	import __AS3__.vec.Vector;
	
	import linda.math.Vertex;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.utils.MeshManipulator;
	public class Plane extends Mesh
	{
		private var meshBuffer : MeshBuffer;
		public function Plane (height : Number = 200, width : Number = 200, segsH : int = 1, segsW : int = 1, backface : Boolean = false)
		{
			super ();
			meshBuffer = new MeshBuffer ();
			meshBuffer.getMaterial ().backfaceCulling = backface;
			createPlane (height, width, segsH, segsW);
			MeshManipulator.recalculateNormals (meshBuffer, true);
			meshBuffers.push (meshBuffer);
			meshBuffer.recalculateBoundingBox();
			recalculateBoundingBox ();
		}
		private function createPlane (height : Number, width : Number, segsH : int, segsW : int) : void
		{
			var vertices : Vector.<Vertex> = meshBuffer.vertices;
			var indices : Vector.<int> = meshBuffer.indices;
			if (segsH < 1) segsH = 1;
			if (segsW < 1) segsW = 1;
			var perH : Number = height / segsH;
			var perW : Number = width / segsW;
			var wid2 : Number = width * 0.5;
			var hei2 : Number = height * 0.5;
			//All vertex.z = 0
			//vertices
			for (var i : int = 0; i <= segsH; i ++)
			{
				for (var j : int = 0; j <= segsW; j ++)
				{
					var vertex : Vertex = new Vertex ();
					vertex.x = j * perW - wid2;
					vertex.y = i * perH - hei2;
					vertex.z = 0;
					vertex.u = 1 - j / segsW;
					vertex.v = 1 - i / segsH;
					vertex.nx = vertex.x;
					vertex.ny = vertex.y;
					vertex.nz = vertex.z;
					vertex.normalize ();
					vertices.push (vertex);
				}
			}
			// indices
			var segsH1 : int = segsH + 1;
			for (i = 0; i < segsH; i ++)
			{
				for (j = 0; j < segsW; j ++)
				{
					indices.push (i * segsH1 + j, (i) * segsH1 + j + 1, (i + 1) * segsH1 + j + 1);
					indices.push (i * segsH1 + j, (i + 1) * segsH1 + j + 1, (i + 1) * segsH1 + j);
				}
			}
		}
	}
}

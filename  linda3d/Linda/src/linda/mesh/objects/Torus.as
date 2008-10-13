package linda.mesh.objects
{
	import __AS3__.vec.Vector;
	
	import linda.math.Vector2D;
	import linda.math.Vertex;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.utils.MeshManipulator;
	public class Torus extends Mesh
	{
		private var meshBuffer : MeshBuffer;
		public function Torus (radius : Number = 100, tube : Number = 10, segsR : int = 5, segsT : int = 5)
		{
			super ();
			meshBuffer = new MeshBuffer ();
			createTorus (radius, tube, segsR, segsT);
			MeshManipulator.recalculateNormals (meshBuffer, true);
			meshBuffer.recalculateBoundingBox();
			meshBuffers.push (meshBuffer);
			recalculateBoundingBox ();
		}
		private function createTorus (radius : Number, tube : Number, segsR : int, segsT : int) : void
		{
			var vertices : Vector.<Vertex> = meshBuffer.vertices;
			var indices : Vector.<int> = meshBuffer.indices;
			var i : int;
			var j : int;
			var gridVertices : Array = new Array (segsR);
			for (i = 0; i < segsR; i ++)
			{
				gridVertices [i] = new Array (segsT);
				for (j = 0; j < segsT; j ++)
				{
					var u : Number = i / segsR * 2 * Math.PI;
					var v : Number = j / segsT * 2 * Math.PI;
					gridVertices [i][j] = new Vertex ((radius + tube * Math.cos (v)) * Math.cos (u) , -(radius + tube*Math.cos(v))*Math.sin(u), tube*Math.sin(v));
				}
			}
			var indexCount : int = 0;
			for (i = 0; i < segsR; i ++)
			{
				for (j = 0; j < segsT; j ++)
				{
					var ip : int = (i + 1) % segsR;
					var jp : int = (j + 1) % segsT;
					var a : Vertex = gridVertices [i ][j];
					var b : Vertex = gridVertices [ip][j];
					var c : Vertex = gridVertices [i ][jp];
					var d : Vertex = gridVertices [ip][jp];
					var uva : Vector2D = new Vector2D (i / segsR, j / segsT);
					var uvb : Vector2D = new Vector2D ((i + 1) / segsR, j / segsT);
					var uvc : Vector2D = new Vector2D (i / segsR, (j + 1) / segsT);
					var uvd : Vector2D = new Vector2D ((i + 1) / segsR, (j + 1) / segsT);
					a.u = uva.x, a.v = uva.y;
					b.u = uvb.x, b.v = uvb.y;
					c.u = uvc.x, c.v = uvc.y;
					d.u = uvd.x, d.v = uvd.y;
					vertices.push (a, b, c, d);
					indices.push (indexCount + 2, indexCount + 1, indexCount);
					indices.push (indexCount + 1, indexCount + 2, indexCount + 3);
					indexCount += 4;
				}
			}
		}
	}
}

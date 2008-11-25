package linda.mesh.objects
{
	import __AS3__.vec.Vector;
	
	import linda.math.Vector2D;
	import linda.math.Vertex;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.MeshManipulator;
	public class Cylinder extends Mesh
	{
		private var meshBuffer : MeshBuffer;
		public function Cylinder (radius : Number = 100, height : Number = 100, segmentsW : int = 8, segmentsH : int = 6, topRadius : Number = - 1)
		{
			super ();
			meshBuffer = new MeshBuffer ();
			createCylinder (radius, height, segmentsW, segmentsH, topRadius);
			MeshManipulator.recalculateNormals (meshBuffer, true);
			meshBuffers.push (meshBuffer);
			meshBuffer.recalculateBoundingBox();
			recalculateBoundingBox ();
		}
		private function createCylinder (radius : Number, height : Number, segmentsW : int, segmentsH : int, topRadius : Number) : void
		{
			var vertices : Vector.<Vertex> = meshBuffer.vertices;
			var indices : Vector.<int> = meshBuffer.indices;
			if (topRadius == - 1) topRadius = radius;
			var i : int, j : int, k : Number;
			var indexCount : int = 0;
			var segW : int = Math.max (3, segmentsW);
			var segH : int = Math.max (2, segmentsH);
			var aVertice : Vector.<Vertex> = new Vector.<Vertex> ()
			var tmpVertices : Vector.<Vector.<Vertex>> = new Vector.<Vector.<Vertex>> ();
			for (j = 0; j < (segH + 1); j+=1)
			{
				// vertical
				var fRad1 : Number = Number (j / segH);
				var fZ : Number = height * (j / (segH + 0)) - height / 2;
				var fRds : Number = topRadius + (radius - topRadius) * (1 - j / (segH));
				var aRow : Vector.<Vertex> = new Vector.<Vertex> ();
				var oVtx : Vertex;
				for (i = 0; i < segW; i+=1)
				{
					// horizontal
					var fRad2 : Number = Number (2 * i / segW);
					var fX : Number = fRds * Math.sin (fRad2 * Math.PI);
					var fY : Number = fRds * Math.cos (fRad2 * Math.PI);
					oVtx = new Vertex (fY, fZ, fX);
					aVertice.push (oVtx);
					aRow.push (oVtx);
				}
				tmpVertices.push (aRow);
			}
			var segHNum : int = tmpVertices.length;
			var v1 : Vertex, v2 : Vertex, v3 : Vertex, v4 : Vertex;
			var uv1 : Vector2D = new Vector2D ();
			var uv2 : Vector2D = new Vector2D ();
			var uv3 : Vector2D = new Vector2D ();
			for (j = 0; j < segHNum; j ++)
			{
				var segWNum : int = tmpVertices [j].length;
				for (i = 0; i < segWNum; i ++)
				{
					if (j > 0&&i >= 0)
					{
						// select vertices
						var bEnd : Boolean = i == (segWNum - 0);
						v1 = tmpVertices [j][bEnd?0 : i];
						v2 = tmpVertices [j][(i == 0?segWNum : i) - 1];
						v3 = tmpVertices [j - 1][(i == 0?segWNum : i) - 1];
						v4 = tmpVertices [j - 1][bEnd?0 : i];
						// uv
						var uj0 : Number = j	/ segHNum;
						var uj1 : Number = (j - 1) / segHNum;
						var ui0 : Number = (i + 1) / segWNum;
						var ui1 : Number = i	/ segWNum;
						v1.u = ui0;
						v1.v = uj1;
						v2.u = ui0;
						v2.v = uj0;
						v3.u = ui1;
						v3.v = uj0;
						v4.u = ui1;
						v4.v = uj1;
						vertices.push (v1, v2, v3, v4);
						indices.push (indexCount + 2, indexCount + 1, indexCount+0);
						indices.push (indexCount + 3, indexCount + 2, indexCount+0);
						indexCount += 4;
					}
				}
				if (j == 0 || j == (segHNum - 1))
				{
					for (i = 0; i < (segWNum - 2); i ++)
					{
						// uv
						var iI : int = Math.floor (i / 2);
						v1 = tmpVertices [j][iI];
						v2 = (i % 2 == 0) ? (tmpVertices [j][segWNum - 2 - iI]) : (tmpVertices [j][iI + 1]);
						v3 = (i % 2 == 0) ? (tmpVertices [j][segWNum - 1 - iI]) : (tmpVertices [j][segWNum - 2 - iI]);
						var bTop : Boolean = (j == 0);
						if (bTop)
						{
							uv1.x = 0;
							uv1.y = v1.z / radius / 2 +.5;
							uv2.x = 0;
							uv2.y = v2.z / radius / 2 +.5;
							uv3.x = 0;
							uv3.y = v3.z / radius / 2 +.5;
						} else
						{
							uv1.x = v1.x / radius / 2 +.5;
							uv1.y = v1.z / radius / 2 +.5;
							uv2.x = v2.x / radius / 2 +.5;
							uv2.y = v2.z / radius / 2 +.5;
							uv3.x = v3.x / radius / 2 +.5;
							uv3.y = v3.z / radius / 2 +.5;
						}
						v1.u = uv1.x;
						v1.v = uv1.y;
						v2.u = uv2.x;
						v2.v = uv2.y;
						v3.u = uv3.x;
						v3.v = uv3.y;
						vertices.push (v1, v2, v3);
						if (j == 0)
						{
							indices.push (indexCount + 1, indexCount + 2, indexCount+0);
							indexCount += 3;
						} else
						{
							indices.push (indexCount + 2, indexCount + 1, indexCount+0);
							indexCount += 3;
						}
					}
				}
			}
			tmpVertices = null;
		}
	}
}

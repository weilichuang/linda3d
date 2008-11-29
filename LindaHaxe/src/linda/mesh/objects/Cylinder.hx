package linda.mesh.objects;

	import flash.Vector;
	
	import flash.geom.Point;
	import linda.math.MathUtil;
	import linda.math.Vertex;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.MeshManipulator;
	class Cylinder extends Mesh
	{
		private var meshBuffer : MeshBuffer;
		public function new (?radius : Float = 100., ?height : Float = 100., ?segmentsW : Int = 8, ?segmentsH : Int = 6, ?topRadius : Float = 0.)
		{
			super ();
			meshBuffer = new MeshBuffer ();
			createCylinder (radius, height, segmentsW, segmentsH, topRadius);
			MeshManipulator.recalculateNormals (meshBuffer, true);
			meshBuffers.push (meshBuffer);
			meshBuffer.recalculateBoundingBox();
			recalculateBoundingBox ();
		}
		private function createCylinder (radius : Float, height : Float, segmentsW : Int, segmentsH : Int, topRadius : Float) : Void
		{
			var vertices : Vector<Vertex> = meshBuffer.vertices;
			var indices : Vector<Int> = meshBuffer.indices;
			if (topRadius == - 1) topRadius = radius;
			var k : Float;
			var indexCount : Int = 0;
			var segW : Int = MathUtil.maxInt(3, segmentsW);
			var segH : Int = MathUtil.maxInt(2, segmentsH);
			var aVertice : Vector<Vertex> = new Vector<Vertex> ();
			var tmpVertices : Vector<Vector<Vertex>> = new Vector<Vector<Vertex>> ();
			for (j in 0...(segH + 1))
			{
				// vertical
				var fRad1 : Float =  (j / segH);
				var fZ : Float = height * (j / (segH + 0)) - height / 2;
				var fRds : Float = topRadius + (radius - topRadius) * (1 - j / (segH));
				var aRow : Vector<Vertex> = new Vector<Vertex> ();
				var oVtx : Vertex;
				for (i in 0...segW)
				{
					// horizontal
					var fRad2 : Float =  (2 * i / segW);
					var fX : Float = fRds * MathUtil.sin (fRad2 * Math.PI);
					var fY : Float = fRds * MathUtil.cos (fRad2 * Math.PI);
					oVtx = new Vertex (fY, fZ, fX);
					aVertice.push (oVtx);
					aRow.push (oVtx);
				}
				tmpVertices.push (aRow);
			}
			var segHNum : Int = tmpVertices.length;
			var v1 : Vertex, v2 : Vertex, v3 : Vertex, v4 : Vertex;
			var uv1 : Point = new Point ();
			var uv2 : Point = new Point ();
			var uv3 : Point = new Point ();
			for (j in 0...segHNum)
			{
				var segWNum : Int = tmpVertices [j].length;
				for (i in 0...segWNum)
				{
					if (j > 0 && i >= 0)
					{
						// select vertices
						var bEnd : Bool = i == (segWNum - 0);
						v1 = tmpVertices [j][bEnd?0 : i];
						v2 = tmpVertices [j][(i == 0?segWNum : i) - 1];
						v3 = tmpVertices [j - 1][(i == 0?segWNum : i) - 1];
						v4 = tmpVertices [j - 1][bEnd?0 : i];
						// uv
						var uj0 : Float = j	/ segHNum;
						var uj1 : Float = (j - 1) / segHNum;
						var ui0 : Float = (i + 1) / segWNum;
						var ui1 : Float = i	/ segWNum;
						v1.u = ui0;
						v1.v = uj1;
						v2.u = ui0;
						v2.v = uj0;
						v3.u = ui1;
						v3.v = uj0;
						v4.u = ui1;
						v4.v = uj1;
						vertices.push(v1);
						vertices.push(v2);
						vertices.push(v3);
						vertices.push(v4);
                        indices.push(indexCount + 2); indices.push(indexCount + 1); indices.push(indexCount);
						indices.push(indexCount + 3); indices.push(indexCount + 2); indices.push(indexCount);
						indexCount += 4;
					}
				}
				if (j == 0 || j == (segHNum - 1))
				{
					for (i in 0...(segWNum - 2))
					{
						// uv
						var iI : Int = Math.floor (i / 2);
						v1 = tmpVertices [j][iI];
						v2 = (i % 2 == 0) ? (tmpVertices [j][segWNum - 2 - iI]) : (tmpVertices [j][iI + 1]);
						v3 = (i % 2 == 0) ? (tmpVertices [j][segWNum - 1 - iI]) : (tmpVertices [j][segWNum - 2 - iI]);
						var bTop : Bool = (j == 0);
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
						vertices.push(v1);
						vertices.push(v2);
						vertices.push(v3);
						if (j == 0)
						{
							indices.push(indexCount + 1); indices.push(indexCount + 2); indices.push(indexCount);
							indexCount += 3;
						} else
						{
							indices.push(indexCount + 2); indices.push(indexCount + 1); indices.push(indexCount);
							indexCount += 3;
						}
					}
				}
			}
			tmpVertices = null;
		}
	}


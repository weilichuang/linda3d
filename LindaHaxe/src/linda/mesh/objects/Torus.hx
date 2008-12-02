package linda.mesh.objects;

	import flash.Vector;
	
	import flash.geom.Point;
	
	import linda.math.Vertex;
	import linda.mesh.MeshBuffer;
	import linda.mesh.MeshManipulator;
	class Torus extends MeshBuffer
	{
		public function new (?radius : Float = 100., ?tube : Float = 10., ?segsR : Int = 5, ?segsT : Int = 5)
		{
			super();
			createTorus (radius, tube, segsR, segsT);
			recalculateBoundingBox();
			MeshManipulator.recalculateNormals (this, true);
		}
		private function createTorus (radius : Float, tube : Float, segsR : Int, segsT : Int) : Void
		{
			vertices.length = 0;
			indices.length  = 0;

			var gridVertices : Vector<Vector<Vertex>> = new Vector<Vector<Vertex>>(segsR);
			for (i in 0...segsR)
			{
				gridVertices [i] = new Vector<Vertex> (segsT);
				for (j in 0...segsT)
				{
					var u : Float = i / segsR * 2 * Math.PI;
					var v : Float = j / segsT * 2 * Math.PI;
					gridVertices [i][j] = new Vertex ((radius + tube * Math.cos (v)) * Math.cos (u) , -(radius + tube*Math.cos(v))*Math.sin(u), tube*Math.sin(v));
				}
			}
			var indexCount : Int = 0;
			for (i in 0...segsR)
			{
				for (j in 0...segsT)
				{
					var ip : Int = (i + 1) % segsR;
					var jp : Int = (j + 1) % segsT;
					var a : Vertex = gridVertices [i ][j];
					var b : Vertex = gridVertices [ip][j];
					var c : Vertex = gridVertices [i ][jp];
					var d : Vertex = gridVertices [ip][jp];
					var uva : Point = new Point (i / segsR, j / segsT);
					var uvb : Point = new Point ((i + 1) / segsR, j / segsT);
					var uvc : Point = new Point (i / segsR, (j + 1) / segsT);
					var uvd : Point = new Point ((i + 1) / segsR, (j + 1) / segsT);
					a.u = uva.x; a.v = uva.y;
					b.u = uvb.x; b.v = uvb.y;
					c.u = uvc.x; c.v = uvc.y;
					d.u = uvd.x; d.v = uvd.y;
					vertices.push(a);
					vertices.push(b);
					vertices.push(c);
					vertices.push(d);
					indices.push (indexCount + 2);
					indices.push (indexCount + 1);
					indices.push (indexCount );
					indices.push (indexCount + 1);
					indices.push (indexCount + 2);
					indices.push (indexCount + 3);
					
					indexCount += 4;
				}
			}
		}
	}


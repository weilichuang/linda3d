package linda.mesh.objects;

	import flash.Vector;
	
	import flash.geom.Point;
	import linda.math.Vector3;
	
	import linda.math.Vertex;
	import linda.mesh.MeshBuffer;
	import linda.mesh.MeshManipulator;
	class RegularPolygon extends MeshBuffer
	{
		public function new (?radius : Float = 100., ?sides : Int = 5, ?subdivision : Int = 1, ?backface : Bool = false)
		{
			super ();
			build (radius, sides, subdivision);
		}
		public inline function build (radius : Float, sides : Int, subdivision : Int) : Void
		{
			vertices.length = 0;
			indices.length  = 0;
			if (sides < 3) sides = 3;
			if (subdivision < 1 ) subdivision = 1;
			var tmpPoints : Vector<Vector3> = new Vector<Vector3> ();
			var innerstep : Float = radius / subdivision;
			var radstep : Float = 360 / sides;
			var ang : Float = 0;
			var ang_inc : Float = radstep;
			var uva : Point = new Point ();
			var uvb : Point = new Point ();
			var uvc : Point = new Point ();
			var uvd : Point = new Point ();
			var va : Vertex;
			var vb : Vertex;
			var vc : Vertex;
			var vd : Vertex;
			for (i in 0...(subdivision+1))
			{
				tmpPoints.push (new Vector3 (i * innerstep, 0., 0.));
			}
			var base : Vector3 = new Vector3 (0., 0., 0.);
			var zerouv : Point = new Point (0.5, 0.5);
			var indexCount : Int = 0;
			for (i in 0...sides)
			{
				for (j in 0...(tmpPoints.length - 1))
				{
					uva.x = (Math.cos ( - ang_inc / 180 * Math.PI) / ((subdivision * 2) / j)) +.5;
					uva.y = (Math.sin (ang_inc / 180 * Math.PI) / ((subdivision * 2) / j)) +.5 ;
					uvb.x = (Math.cos ( - ang / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) +.5;
					uvb.y = (Math.sin (ang / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) +.5;
					uvc.x = (Math.cos ( - ang_inc / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) +.5;
					uvc.y = (Math.sin (ang_inc / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) +.5;
					uvd.x = (Math.cos ( - ang / 180 * Math.PI) / ((subdivision * 2) / j)) +.5;
					uvd.y = (Math.sin (ang / 180 * Math.PI) / ((subdivision * 2) / j)) +.5;
					if (j == 0)
					{
						va = new Vertex (0, 0, 0);
						va.u = va.v = 0.5;
						vb = new Vertex (Math.cos ( - ang / 180 * Math.PI) * tmpPoints [1].x, Math.sin(ang/180*Math.PI) * tmpPoints[1].x, base.z);
						vb.u = uvb.x;
						vb.v = uvb.y;
						vc = new Vertex (Math.cos ( - ang_inc / 180 * Math.PI) * tmpPoints [1].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[1].x,base.z);
						vc.u = uvc.x;
						vc.v = uvc.y;
						vertices.push(va);
						vertices.push(vb);
						vertices.push(vc);
						indices.push (indexCount ++);
						indices.push (indexCount ++);
						indices.push (indexCount ++);
					} else 
					{
						va = new Vertex (Math.cos ( - ang_inc / 180 * Math.PI) * tmpPoints [j].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j].x, base.z);
						va.u = uva.x; va.v = uva.y;
						vb = new Vertex (Math.cos ( - ang_inc / 180 * Math.PI) * tmpPoints [j + 1].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j+1].x, base.z);
						vb.u = uvc.x; vb.v = uvc.y;
						vc = new Vertex (Math.cos ( - ang / 180 * Math.PI) * tmpPoints [j + 1].x, Math.sin(ang/180*Math.PI) * tmpPoints[j+1].x, base.z);
						vc.u = uvb.x; vc.v = uvb.y;
						vd = new Vertex (Math.cos ( - ang / 180 * Math.PI) * tmpPoints [j].x, Math.sin(ang/180*Math.PI) * tmpPoints[j].x, base.z);
						vd.u = uvd.x; vd.v = uvd.y;
						vertices.push(va);
						vertices.push(vb);
						vertices.push(vc);
						vertices.push(vd);
						indices.push(indexCount); indices.push(indexCount + 1); indices.push(indexCount + 2);
						indices.push(indexCount + 3);indices.push(indexCount);indices.push(indexCount + 2);
						indexCount += 4;
					}
				}
				ang += radstep;
				ang_inc += radstep;
			}
			tmpPoints.length = 0;
			tmpPoints = null;
			recalculateBoundingBox();
			MeshManipulator.recalculateNormals (this, true);
		}
	}

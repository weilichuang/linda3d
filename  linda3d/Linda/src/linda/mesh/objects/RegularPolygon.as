package linda.mesh.objects
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	
	import linda.math.Vector2D;
	import linda.math.Vertex;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.MeshManipulator;
	public class RegularPolygon extends Mesh
	{
		private var meshBuffer : MeshBuffer;
		public function RegularPolygon (radius : Number = 100, sides : int = 5, subdivision : int = 1, backface : Boolean = false)
		{
			super ();
			meshBuffer = new MeshBuffer ();
			meshBuffer.material.backfaceCulling = backface;
			createRegularPolygon (radius, sides, subdivision);
			MeshManipulator.recalculateNormals (meshBuffer, true);
			meshBuffers.push (meshBuffer);
			meshBuffer.recalculateBoundingBox();
			recalculateBoundingBox ();
		}
		private function createRegularPolygon (radius : Number, sides : int, subdivision : int) : void
		{
			var vertices : Vector.<Vertex> = meshBuffer.vertices;
			var indices : Vector.<int> = meshBuffer.indices;
			if (sides < 3) sides = 3;
			if (subdivision < 1 ) subdivision = 1;
			var tmpPoints : Array = new Array ();
			var i : int = 0;
			var j : int = 0;
			var innerstep : Number = radius / subdivision;
			var radstep : Number = 360 / sides;
			var ang : Number = 0;
			var ang_inc : Number = radstep;
			var uva : Vector2D = new Vector2D ();
			var uvb : Vector2D = new Vector2D ();
			var uvc : Vector2D = new Vector2D ();
			var uvd : Vector2D = new Vector2D ();
			var va : Vertex;
			var vb : Vertex;
			var vc : Vertex;
			var vd : Vertex;
			for (i; i <= subdivision; i ++)
			{
				tmpPoints.push (new Vector3D (i * innerstep, 0, 0));
			}
			var base : Vector3D = new Vector3D (0, 0, 0);
			var zerouv : Vector2D = new Vector2D (0.5, 0.5);
			var indexCount : int = 0;
			for (i = 0; i < sides; i ++)
			{
				for (j = 0; j < tmpPoints.length - 1; j ++)
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
						vb.u = uvb.x, vb.v = uvb.y;
						vc = new Vertex (Math.cos ( - ang_inc / 180 * Math.PI) * tmpPoints [1].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[1].x,base.z);
						vc.u = uvc.x, vc.v = uvc.y;
						vertices.push (va, vb, vc);
						indices.push (indexCount ++);
						indices.push (indexCount ++);
						indices.push (indexCount ++);
					} else 
					{
						va = new Vertex (Math.cos ( - ang_inc / 180 * Math.PI) * tmpPoints [j].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j].x, base.z);
						va.u = uva.x, va.v = uva.y;
						vb = new Vertex (Math.cos ( - ang_inc / 180 * Math.PI) * tmpPoints [j + 1].x, Math.sin(ang_inc/180*Math.PI) * tmpPoints[j+1].x, base.z);
						vb.u = uvc.x, vb.v = uvc.y;
						vc = new Vertex (Math.cos ( - ang / 180 * Math.PI) * tmpPoints [j + 1].x, Math.sin(ang/180*Math.PI) * tmpPoints[j+1].x, base.z);
						vc.u = uvb.x, vc.v = uvb.y;
						vd = new Vertex (Math.cos ( - ang / 180 * Math.PI) * tmpPoints [j].x, Math.sin(ang/180*Math.PI) * tmpPoints[j].x, base.z);
						vd.u = uvd.x, vd.v = uvd.y;
						vertices.push (va, vb, vc, vd);
						indices.push (indexCount, indexCount + 1, indexCount + 2);
						indices.push (indexCount + 3, indexCount, indexCount + 2);
						indexCount += 4;
					}
				}
				ang += radstep;
				ang_inc += radstep;
			}
		}
	}
}

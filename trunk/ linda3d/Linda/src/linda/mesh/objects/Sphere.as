package linda.mesh.objects
{
	import flash.geom.Vector3D;
	
	import linda.math.AABBox3D;
	import linda.math.Vertex;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	public class Sphere extends Mesh
	{
		private var meshBuffer : MeshBuffer;
		public function Sphere (radius : Number = 100, polyCount : int = 6)
		{
			super ();
			meshBuffer = new MeshBuffer ();
			setSizeAndPolys (radius, polyCount);
			meshBuffers.push (meshBuffer);
			this.recalculateBoundingBox();
		}
		private function setSizeAndPolys (radius : Number, polyCount : int) : void
		{
			if (polyCount < 2 )
			{
				polyCount = 2;
			} 
			else if (polyCount > 181)
			{
				polyCount = 181;
			}
			var vertexCount : int = polyCount * polyCount + 2;
			var vertices : Vector.<Vertex> = new Vector.<Vertex> (vertexCount);
			var indexCount : int = polyCount * polyCount * 6;
			var indices : Vector.<int> = new Vector.<int> (indexCount);
			var clr : uint = 0xffffff;
			var level : int = 0;
			var n : int = 0;
			for (var i : int = 0; i < polyCount - 1; i ++)
			{
				level = i * polyCount;
				for (var j : int = 0; j < polyCount - 1; j ++)
				{
					indices [n ++] = level + j + polyCount;
					indices [n ++] = level + j;
					indices [n ++] = level + j + 1;
				}
				indices [n ++] = level + polyCount - 1 + polyCount;
				indices [n ++] = level + polyCount - 1;
				indices [n ++] = level;
				indices [n ++] = level + polyCount - 1 + polyCount;
				indices [n ++] = level;
				indices [n ++] = level + polyCount;
				for (j = 1; j <= polyCount - 1; j ++)
				{
					indices [n ++] = level + j - 1 + polyCount;
					indices [n ++] = level + j;
					indices [n ++] = level + j + polyCount;
				}
			}
			var polyCountSq : int = polyCount * polyCount;
			var polyCountSq1 : int = polyCountSq + 1;
			var polyCountSqM1 : int = (polyCount - 1) * polyCount;
			for (j = 0; j < polyCount - 1; j ++)
			{
				// create triangles which are at the top of the sphere
				indices [n ++] = polyCountSq;
				indices [n ++] = j + 1;
				indices [n ++] = j;
				// create triangles which are at the bottom of the sphere
				indices [n ++] = polyCountSqM1 + j;
				indices [n ++] = polyCountSqM1 + j + 1;
				indices [n ++] = polyCountSq1;
			}
			// create a triangle which is at the top of the sphere
			indices [n ++] = polyCountSq;
			indices [n ++] = 0;
			indices [n ++] = polyCount - 1;
			// create a triangle which is at the bottom of the sphere
			indices [n ++] = polyCountSqM1 + polyCount - 1;
			indices [n ++] = polyCountSqM1;
			indices [n ++] = polyCountSq1;
			// calculate the angle which separates all points in a circle
			var angle : Number = 2 * Math.PI / polyCount;
			var sinay : Number;
			var cosay : Number;
			var sinaxz : Number;
			var cosaxz : Number;
			n = 0;
			var axz : Number;
			// we don't start at 0.
			var ay : Number = - angle / 4;
			var normal:Vector3D=new Vector3D();
			for (var y : int = 0; y < polyCount; y ++)
			{
				ay += angle / 2;
				axz = 0;
				for (var xz : int = 0; xz < polyCount; xz ++)
				{
					// calculate points position
					axz += angle;
					sinay = Math.sin (ay) * radius;
					cosay = Math.cos (ay) * radius;
					cosaxz = Math.cos (axz);
					sinaxz = Math.sin (axz);
					var posx : Number = cosaxz * sinay;
					var posy : Number = cosay ;
					var posz : Number = sinaxz * sinay;
					normal.x=posx;
					normal.y=posy;
					normal.z=posz;
					normal.normalize ();
					vertices [n ++] = new Vertex (posx, posy, posz,
					                              normal.x, normal.y, normal.z,
					                              clr,
					                              Math.asin (normal.x) / (Math.PI * 2) * 2 + 0.5,
					                              Math.acos (normal.y) / (Math.PI * 2) * 2);
				}
			}
			// the vertex at the top of the sphere
			vertices [n ++] = new Vertex (0, radius, 0, 1, 1, 1, clr, 0.5, 0);
			// the vertex at the bottom of the sphere
			vertices [n] = new Vertex (0, - radius, 0, - 1, - 1, - 1, clr, 0.5, 1);
			// recalculate bounding box
			var box : AABBox3D = new AABBox3D ();
			box.addXYZ (vertices [n].x, vertices [n].y, vertices [n].z);
			box.addXYZ (vertices [n - 1].x, vertices [n - 1].y, vertices [n - 1].z);
			box.addXYZ (radius, 0, 0);
			box.addXYZ ( - radius, 0, 0);
			box.addXYZ (0, 0, radius);
			box.addXYZ (0, 0, - radius);
			meshBuffer.indices = indices;
			meshBuffer.vertices = vertices;
			meshBuffer.boundingBox = box;
		}
	}
}

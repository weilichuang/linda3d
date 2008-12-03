package linda.mesh.objects;

    import flash.Vector;

	import linda.math.Vector3;
	import linda.math.AABBox3D;
	import linda.math.Vertex;
	import linda.mesh.MeshBuffer;
	class Sphere extends MeshBuffer
	{
		public function new (?radius : Float = 100., ?polyCount : Int = 6)
		{
			super ();
			build(radius, polyCount);
		}
		public inline function build (radius : Float, polyCount : Int) : Void
		{
			vertices.length = 0;
			indices.length  = 0;
			if (polyCount < 2 )
			{
				polyCount = 2;
			} 
			else if (polyCount > 180)
			{
				polyCount = 180;
			}
			var vertexCount : Int = polyCount * polyCount + 2;
			vertices.length = vertexCount;
			var indexCount : Int = polyCount * polyCount * 6;
			indices.length = indexCount;
			var clr : UInt = 0xffffff;
			var level : Int = 0;
			var n : Int = 0;
			for (i in 0...(polyCount - 1))
			{
				level = i * polyCount;
				for ( j in 0...(polyCount - 1))
				{
					indices [n ++] = level + j + polyCount;
					indices [n ++] = level + j;
					indices [n ++] = level + j + 1;
				}
				indices [n++] = level + polyCount - 1 + polyCount;
				indices [n++] = level + polyCount - 1;
				indices [n++] = level;
				indices [n++] = level + polyCount - 1 + polyCount;
				indices [n++] = level;
				indices [n++] = level + polyCount;
				for (j in 1...polyCount)
				{
					indices [n ++] = level + j - 1 + polyCount;
					indices [n ++] = level + j;
					indices [n ++] = level + j + polyCount;
				}
			}
			var polyCountSq : Int = polyCount * polyCount;
			var polyCountSq1 : Int = polyCountSq + 1;
			var polyCountSqM1 : Int = (polyCount - 1) * polyCount;
			for (j in 0...(polyCount-1))
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
			var angle : Float = 2 * Math.PI / polyCount;
			var sinay : Float;
			var cosay : Float;
			var sinaxz : Float;
			var cosaxz : Float;
			n = 0;
			var axz : Float;
			var ay : Float = - angle / 4;
			var normal:Vector3=new Vector3();
			for ( y in 0...polyCount)
			{
				ay += angle / 2;
				axz = 0;
				for ( xz in 0...polyCount)
				{
					// calculate points position
					axz += angle;
					sinay = Math.sin (ay) * radius;
					cosay = Math.cos (ay) * radius;
					cosaxz = Math.cos (axz);
					sinaxz = Math.sin (axz);
					var posx : Float = cosaxz * sinay;
					var posy : Float = cosay ;
					var posz : Float = sinaxz * sinay;
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
			vertices[n ++] = new Vertex (0., radius, 0., 1., 1., 1., clr, 0.5, 0.);
			// the vertex at the bottom of the sphere
			vertices [n] = new Vertex (0., - radius, 0., - 1., - 1., - 1., clr, 0.5, 1.);
			
			// recalculate bounding box
			boundingBox.resetVertex(vertices[n]);
			boundingBox.addVertex(vertices[n - 1]);
			boundingBox.addXYZ (radius, 0., 0.);
			boundingBox.addXYZ ( - radius, 0., 0.);
			boundingBox.addXYZ (0., 0., radius);
			boundingBox.addXYZ (0., 0., - radius);
		}
	}


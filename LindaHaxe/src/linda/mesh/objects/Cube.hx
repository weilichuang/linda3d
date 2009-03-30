package linda.mesh.objects;

	import flash.geom.Vector3D;
	import flash.Lib;
	import flash.Vector;

	import linda.math.AABBox3D;
	import linda.math.Vertex;
	import linda.math.Vector3;
	import linda.math.Vertex;
	import linda.math.MathUtil;
	import linda.mesh.Mesh;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.MeshManipulator;
	class Cube extends MeshBuffer
	{
		/**
		 * 
		 * @param	len    x
		 * @param	height y
		 * @param	width  z
		 */
		public function new (?length : Float = 100.,?height : Float = 100.,?width : Float = 100.)
		{
			super ();
			build (length, width, height);
		}
		public inline function build (length : Float, width : Float, height : Float) : Void
		{
			vertices.length = 0;
			indices.length  = 0;
			indices=Lib.vectorOfArray([0, 2, 1, 0, 3, 2, 1, 5, 4, 1, 2, 5, 4, 6, 7, 4, 5, 6,
			                    7, 3, 0, 7, 6, 3, 9, 5, 2, 9, 8, 5, 0, 11, 10, 0, 10, 7]);
       
			var color : UInt = 0xffffff;
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
			for (i in 0...12)
			{
				var vertex : Vertex = vertices [i];
				vertex.x -= 0.5;
				vertex.y -= 0.5;
				vertex.z -= 0.5;
				vertex.x *= length;
				vertex.y *= height;
				vertex.z *= width;
				
				if (i == 0)
				{
					boundingBox.resetVertex(vertex);
				}else 
				{
					boundingBox.addVertex(vertex);
				}
			}
		}
		/**
		 * @param	colors Vector<UInt> colors.length >=12
		 */
		public inline function setColors(colors:Vector<UInt>):Void 
		{
			for (i in 0...12)
			{
				vertices[i].color = colors[i];
			}
		}
	}


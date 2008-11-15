package mini3d.scene
{
	import mini3d.core.Material;
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	import mini3d.math.Vector3D;
	import mini3d.render.RenderManager;
	
	public class SphereSceneNode extends SceneNode
	{
		private var indices:Array;
		private var vertices:Array;
		private var box:AABBox3D;
		private var material:Material;
		public function SphereSceneNode(mgr:SceneManager,radius : Number=50, polyCount : int=10)
		{
			super(mgr);
			
			material=new Material();
			if (polyCount < 2 )
			{
				polyCount = 2;
			} 
			else if (polyCount > 181)
			{
				polyCount = 181;
			}
			var vertexCount : int = polyCount * polyCount + 2;
			vertices = new Array (vertexCount);
			var indexCount : int = polyCount * polyCount * 6;
			indices = new Array (indexCount);

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
			var normal : Vector3D = new Vector3D ();
			var ay : Number = - angle / 4;
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
					                              Math.asin (normal.x) / (Math.PI * 2) * 2 + 0.5,
					                              Math.acos (normal.y) / (Math.PI * 2) * 2);
				}
			}
			// the vertex at the top of the sphere
			vertices [n ++] = new Vertex (0, radius, 0,  0.5, 0);
			// the vertex at the bottom of the sphere
			vertices [n] = new Vertex (0, - radius, 0,  0.5, 1);
			// recalculate bounding box
			box = new AABBox3D ();
			box.addXYZ (vertices [n].x, vertices [n].y, vertices [n].z);
			box.addXYZ (vertices [n - 1].x, vertices [n - 1].y, vertices [n - 1].z);
			box.addXYZ (radius, 0, 0);
			box.addXYZ ( - radius, 0, 0);
			box.addXYZ (0, 0, radius);
			box.addXYZ (0, 0, - radius);
		}
		override public function onPreRender():void
		{
			if(visible)
			{
				sceneManager.registerNodeForRendering(this,SceneNode.NODE);
				super.onPreRender();
			}
		}
		override public function render():void
		{
            var driver : RenderManager = sceneManager.getRenderManager ();
			driver.setMaterial(material);
			driver.setTransformWorld (_absoluteMatrix);
            driver.drawTriangleList (container,vertices,vertices.length,indices,indices.length);
		}
		override public function getMaterial(i:int=0):Material
		{
			return material;
		}
		override public function getMaterialCount():int
		{
			return 1;
		}
		override public function getBoundingBox():AABBox3D
		{
			return box;
		}

	}
}
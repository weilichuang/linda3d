package mini3d.scene
{
	import mini3d.core.Material;
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	import mini3d.math.Vector3D;
	import mini3d.render.RenderManager;
	
	public class CubeSceneNode extends SceneNode
	{
		private var indices:Array;
		private var vertices:Array;
		private var box:AABBox3D;
		private var material:Material;
		public function CubeSceneNode(mgr:SceneManager,size:Vector3D):void
		{
			super(mgr);
			material=new Material();
			indices = [0, 2, 1, 0, 3, 2, 1, 5, 4, 1, 2, 5, 4, 6, 7, 4, 5, 6,
			           7, 3, 0, 7, 6, 3, 9, 5, 2, 9, 8, 5, 0, 11, 10, 0, 10, 7];
			vertices = new Array (12);
			vertices [0] = new Vertex (0, 0, 0, 0, 1);
			vertices [1] = new Vertex (1, 0, 0, 1, 1);
			vertices [2] = new Vertex (1, 1, 0, 1, 0);
			vertices [3] = new Vertex (0, 1, 0, 0, 0);
			vertices [4] = new Vertex (1, 0, 1, 0, 1);
			vertices [5] = new Vertex (1, 1, 1, 0, 0);
			vertices [6] = new Vertex (0, 1, 1, 1, 0);
			vertices [7] = new Vertex (0, 0, 1, 1, 1);
			vertices [8] = new Vertex (0, 1, 1, 0, 1);
			vertices [9] = new Vertex (0, 1, 0, 1, 1);
			vertices [10] = new Vertex (1, 0, 1, 1, 0);
			vertices [11] = new Vertex (1, 0, 0, 0, 0);
			
			if(size==null)
			{
				size=new Vector3D(100,100,100);
			}
			box = new AABBox3D ();
			for (var i : int = 0; i < 12; i ++)
			{
				var vertex : Vertex = vertices [i];
				vertex.x -= 0.5;
				vertex.y -= 0.5;
				vertex.z -= 0.5;
				vertex.x *= size.x;
				vertex.y *= size.y;
				vertex.z *= size.z;
				box.addXYZ (vertex.x, vertex.y, vertex.z);
			}
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
            driver.drawTriangleList (container,vertices,12,indices,36);
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
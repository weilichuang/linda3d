package linda.scene;

	import flash.Vector;

	import linda.material.Material;
	
	import linda.math.AABBox3D;
	import linda.math.Vector3;
	import linda.math.Dimension2D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	
	import linda.video.IVideoDriver;

	class BillboardSceneNode extends SceneNode
	{
		public function new (mgr:SceneManager,?size :Dimension2D = null)
		{
			super (mgr);
			//indices and vertices
			indices = new Vector<Int>(6,true);
			indices[0] = 0;
			indices[1] = 2;
			indices[2] = 1;
			indices[3] = 0;
			indices[4] = 3;
			indices[5] = 2;
			
			vertices = new Vector<Vertex>(4,true);
			var vertex : Vertex = new Vertex ();
			vertex.u = 1.0;
			vertex.v = 1.0;
			vertices[0] = vertex;
			
			vertex = new Vertex ();
			vertex.u = 1.0;
			vertex.v = 0.0;
			vertices[1] = vertex;
			
			vertex = new Vertex ();
			vertex.u = 0.0;
			vertex.v = 0.0;
			vertices[2] = vertex;
			
			vertex = new Vertex ();
			vertex.u = 0.0;
			vertex.v = 1.0;
			vertices[3]=vertex;
			
			//material
			material = new Material ();
			//aabbox
			box = new AABBox3D ();
			
			setSize (size);
		}
		override public function onRegisterSceneNode () : Void
		{
			if (visible)
			{
				if (material.transparenting)
				{
					sceneManager.registerNodeForRendering (this, SceneNode.TRANSPARENT);
				} else
				{
					sceneManager.registerNodeForRendering (this, SceneNode.SOLID);
				}
				super.onRegisterSceneNode ();
			}
		}
		private var _tmpMatrix:Matrix4=new Matrix4();
		override public function render () : Void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			var camera : CameraSceneNode = sceneManager.getActiveCamera ();

			// make billboard look to camera
			var pos : Vector3 = this.getAbsolutePosition ();
			var campos : Vector3 = camera.getAbsolutePosition ();
			var target : Vector3 = camera.getTarget ();
			var up : Vector3 = camera.getUpVector ();
			
			var view : Vector3 = target.subtract (campos);
			
			view.normalize ();
			
			var horizontal : Vector3 = up.crossProduct (view);
			
			if (horizontal.length == 0 )
			{
				horizontal.x=up.x;
				horizontal.y=up.y;
				horizontal.z=up.z;
			}
			
			horizontal.normalize ();
			horizontal.scaleBy (0.5 * size.width);
			
			var vertical : Vector3 = horizontal.crossProduct (view);
			vertical.normalize ();
			vertical.scaleBy (0.5 * size.height);
			
			
			view.scaleBy ( - 1);
			
			var vertex : Vertex;
			for (i in 0...4)
			{
				vertex = vertices[i];
				vertex.nx = view.x;
				vertex.ny = view.y;
				vertex.nz = view.z;
			}
			vertex = vertices [0];
			vertex.x = pos.x + horizontal.x + vertical.x;
			vertex.y = pos.y + horizontal.y + vertical.y;
			vertex.z = pos.z + horizontal.z + vertical.z;
			vertex = vertices [1];
			vertex.x = pos.x + horizontal.x - vertical.x;
			vertex.y = pos.y + horizontal.y - vertical.y;
			vertex.z = pos.z + horizontal.z - vertical.z;
			vertex = vertices [2];
			vertex.x = pos.x - horizontal.x - vertical.x;
			vertex.y = pos.y - horizontal.y - vertical.y;
			vertex.z = pos.z - horizontal.z - vertical.z;
			vertex = vertices [3];
			vertex.x = pos.x - horizontal.x + vertical.x;
			vertex.y = pos.y - horizontal.y + vertical.y;
			vertex.z = pos.z - horizontal.z + vertical.z;
			
			_tmpMatrix.identity();
			driver.setMaterial (material);
			driver.setTransformWorld (_tmpMatrix);
			driver.drawIndexedTriangleList(vertices, 4, indices, 6);
			
			if(debug)
			{
				driver.draw3DBox(box,driver.getDebugColor());
			}
		}
		
		public function setSize (s : Dimension2D) : Void
		{
			if(s==null) s=new Dimension2D(100.,100.);
			size = s;
			var avg : Float = (size.width + size.height) / 6;
			box.reset ( - avg, - avg, - avg);
			box.addXYZ (avg, avg, avg);
		}
		public function getSize () : Dimension2D
		{
			return size;
		}

		override public function getMaterial (i : Int = 0) : Material
		{
			return material;
		}
		override public function getMaterialCount () : Int
		{
			return 1;
		}
		override public function getBoundingBox () : AABBox3D
		{
			return box;
		}
		private var size : Dimension2D;
		private var vertices : Vector<Vertex>;
		private var indices : Vector<Int>;
		private var box : AABBox3D;
		private var material : Material;
	}

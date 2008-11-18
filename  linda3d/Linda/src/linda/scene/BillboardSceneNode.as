package linda.scene
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Vector2D;
	import linda.math.Vertex;
	import linda.video.IVideoDriver;
	//广告牌
	public class BillboardSceneNode extends SceneNode
	{
		public function BillboardSceneNode (mgr:SceneManager,size : Vector2D = null, shade_top : uint = 0xFFFFFF, shade_down : uint = 0xFFFFFF)
		{
			super (mgr);
			//indices and vertices
			indices = new Vector.<int>(0, 2, 1, 0, 3, 2);
			vertices = new Vector.<Vertex>();
			var vertex : Vertex = new Vertex ();
			vertex.u = 1.0;
			vertex.v = 1.0;
			vertex.color = shade_down;
			vertices.push (vertex);
			vertex = new Vertex ();
			vertex.u = 1.0;
			vertex.v = 0.0;
			vertex.color = shade_top;
			vertices.push (vertex);
			vertex = new Vertex ();
			vertex.u = 0.0;
			vertex.v = 0.0;
			vertex.color = shade_top;
			vertices.push (vertex);
			vertex = new Vertex ();
			vertex.u = 0.0;
			vertex.v = 1.0;
			vertex.color = shade_down;
			vertices.push (vertex);
			//material
			material = new Material ();
			//aabbox
			box = new AABBox3D ();
			if (size)
			{
				setSize (size);
			}
		}
		override public function onPreRender () : void
		{
			if (visible)
			{
				if (material.transparenting)
				{
					sceneManager.registerNodeForRendering (this, TRANSPARENT);
				} else
				{
					sceneManager.registerNodeForRendering (this, SOLID);
				}
				super.onPreRender ();
			}
		}
		//TODO medium optimization
		private var _tmpMatrix:Matrix4=new Matrix4();
		override public function render () : void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			var camera : CameraSceneNode = sceneManager.getActiveCamera ();
			if ( ! camera || ! driver ) return;
			
			// make billboard look to camera
			var pos : Vector3D = this.getAbsolutePosition ();
			var campos : Vector3D = camera.getAbsolutePosition ();
			var target : Vector3D = camera.getTarget ();
			var up : Vector3D = camera.getUpVector ();
			
			var view : Vector3D = target.subtract (campos);
			
			view.normalize ();
			
			var horizontal : Vector3D = up.crossProduct (view);
			
			if (horizontal.length == 0 )
			{
				horizontal.x=up.x;
				horizontal.y=up.y;
				horizontal.z=up.z;
			}
			
			horizontal.normalize ();
			horizontal.scaleBy (0.5 * size.x);
			
			var vertical : Vector3D = horizontal.crossProduct (view);
			vertical.normalize ();
			vertical.scaleBy (0.5 * size.y);
			
			
			view.scaleBy ( - 1);
			
			var vertex : Vertex;
			for (var i : int = 0; i < 4; i+=1)
			{
				vertex = vertices [i];
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
			driver.drawIndexedTriangleList (vertices, 4, indices, 6);
			
			if(debug)
			{
				driver.draw3DBox(getBoundingBox(),driver.getDebugColor());
			}
		}
		
		public function setSize (s : Vector2D) : void
		{
			size = s;
			if (size.x == 0) size.x = 1;
			if (size.y == 0) size.y = 1;
			var avg : Number = (size.x + size.y) / 6;
			box.reset ( - avg, - avg, - avg);
			box.addXYZ (avg, avg, avg);
		}
		public function getSize () : Vector2D
		{
			return size;
		}
		public function setColor (top : uint, bottom : uint) : void
		{
			vertices [0].color = bottom;
			vertices [1].color = top;
			vertices [2].color = top;
			vertices [3].color = bottom;
		}
		public function getTopColor () : uint
		{
			return vertices [1].color ;
		}
		public function getBottomColor () : uint
		{
			return vertices [0].color ;
		}
		override public function getMaterial (i : int = 0) : Material
		{
			return material;
		}
		override public function getMaterialCount () : int
		{
			return 1;
		}
		override public function getBoundingBox () : AABBox3D
		{
			return box;
		}
		private var size : Vector2D;
		private var vertices : Vector.<Vertex>;
		private var indices : Vector.<int>;
		private var box : AABBox3D;
		private var material : Material;
	}
}

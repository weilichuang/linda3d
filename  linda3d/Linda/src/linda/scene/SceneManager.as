package linda.scene
{
	import flash.utils.getTimer;

	import linda.collision.ViewFrustum;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.mesh.MeshCache;
	import linda.scene.camera.CameraSceneNode;
	import linda.video.IVideoDriver;

	public class SceneManager extends SceneNode
	{
		private var _driver : IVideoDriver;
		private var _viewFrustum : ViewFrustum;
		private var _activeCamera : CameraSceneNode;
		private var _lightList : Array = [];
		private var _cameraList : Array = [];
		private var _skyBoxList : Array = [];
		private var _solidList : Array = [];
		private var _transparentList : Array = [];
		private var _shadowList : Array = [];
		
		private var _ambientColor:uint=0x0;
		public function SceneManager (driver : IVideoDriver = null)
		{
			super ();
			setVideoDriver(driver);
		}
		override public function destroy():void
		{
			super.destroy();
			_driver=null;
			_viewFrustum=null;
			_activeCamera=null;
			_lightList=null;
			_cameraList=null;
			_skyBoxList=null;
			_solidList=null;
			_transparentList=null;
			_shadowList=null;
		}
		public function getRootSceneNode () : SceneNode
		{
			return this;
		}
		override public function addChild (child : SceneNode) : SceneNode
		{
			if (!child) return null;
			if (child.parent)
			{
				child.parent.removeChild (child);
			}
			child.parent = this;
			child.sceneManager =this;
			children.push (child);
			child.updateAbsoluteMatrix ();
			
			return child;
		}
		public function getVideoDriver () : IVideoDriver
		{
			return _driver;
		}
		public function setVideoDriver (driver : IVideoDriver) : void
		{
			if (driver)
			{
				this._driver = driver;
			}
		}
		public function registerNodeForRendering (node : SceneNode, type : int) : void
		{
			switch (type)
			{
				case SceneNodeType.CAMERA :
				_cameraList.push (node);
				break;
				case SceneNodeType.LIGHT :
				_lightList.push (node);
				break;
				case SceneNodeType.SKYBOX :
				_skyBoxList.push (node);
				break;
				case SceneNodeType.SOLID :
				{
					if ( ! isCulled (node))
					{
						_solidList.push (node);
					}
				}
				break;
				case SceneNodeType.TRANSPARENT :
				{
					if ( ! isCulled (node))
					{
						_transparentList.push (node);
					}
				}
				break;
				case SceneNodeType.SHADOW :
				_shadowList.push (node);
				break;
			}
		}
		public function drawAll () : void
		{
			if ( ! _driver) return ;
			onPreRender ();
			if ( ! _activeCamera)
			{
				throw new Error ("需要指定活动的相机");
			}
			_activeCamera.render ();
			_cameraList = [];

			//render lights
			_driver.deleteAllDynamicLights ();
			
			var len : int = _lightList.length;
			for (var i : int = 0; i < len; i ++)
			{
				var node : SceneNode = _lightList [i];
				node.render ();
			}
			_lightList = [];
			
			
			// render skyboxes
			len = _skyBoxList.length;
			for (i = 0; i < len; i ++)
			{
				node = _skyBoxList [i];
				node.render ();
			}
			_skyBoxList = [];
			
			
			// render solids
			//Todo 升序排列，从前面向后绘制，当物体较多时，离相机较远的物体如果有被遮挡的部分
			//就不需要绘制了，应该可以部分提高速度,有待验证 ～～～～～～～～～～～～
			_solidList.sortOn ('distance', Array.NUMERIC );//| Array.DESCENDING);
			len = _solidList.length;
			for (i = 0; i < len; i ++)
			{
				node = _solidList [i];
				node.render ();
			}
			_solidList = [];
			
			
			//render shadow
			len = _shadowList.length;
			for (i = 0; i < len; i ++)
			{
				node = _shadowList [i];
				node.render ();
			}
			_shadowList = [];
			
			
			//render transparents
			//这里排序是为了让多个透明物体之间的透明度正确，否则可能出现透明度错乱
			//降序排列,这里无论降序还是升序都不会提高速度，但是升序的话，绘制时的透明度混合可能会出现错误
			//有待验证～～～～～～～～～～～～～
			_transparentList.sortOn ('distance', Array.NUMERIC); //| Array.DESCENDING);
			
			len = _transparentList.length;
			for (i = 0; i < len; i ++)
			{
				node = _transparentList [i];
				node.render ();
			}
			_transparentList = [];
			
			//shadow
			
			
			onAnimate (getTimer ());
		}
		public function getActiveCamera () : CameraSceneNode
		{
			return _activeCamera;
		}
		public function setActiveCamera (camera : CameraSceneNode) : void
		{
			if (camera)
			{
				_activeCamera = camera;
				_activeCamera.recalculateProjectionMatrix();
				_viewFrustum = _activeCamera.getViewFrustum ();
			}
		}
		private var tmpBox : AABBox3D=new AABBox3D();
		public function isCulled (node : SceneNode) : Boolean
		{
			if ( ! _activeCamera) return false;
			var frust : ViewFrustum = _activeCamera.getViewFrustum ();
			//transform the frustum to the node's current absolute transformation
			var node_matrix : Matrix4 = node.getAbsoluteMatrix ();

			//tmpBox.copy(node.getBoundingBox());
			//node_matrix.transformBox(tmpBox);
			var nodeBox:AABBox3D=node.getBoundingBox();
			tmpBox.minX = nodeBox.minX;
			tmpBox.minY = nodeBox.minY;
			tmpBox.minZ = nodeBox.minZ;
			tmpBox.maxX = nodeBox.maxX;
			tmpBox.maxY = nodeBox.maxY;
			tmpBox.maxZ = nodeBox.maxZ;
			
			var vx : Number, vy : Number, vz : Number;
			vx = node_matrix.m00 * tmpBox.minX + node_matrix.m10 * tmpBox.minY + node_matrix.m20 * tmpBox.minZ + node_matrix.m30;
			vy = node_matrix.m01 * tmpBox.minX + node_matrix.m11 * tmpBox.minY + node_matrix.m21 * tmpBox.minZ + node_matrix.m31;
			vz = node_matrix.m02 * tmpBox.minX + node_matrix.m12 * tmpBox.minY + node_matrix.m22 * tmpBox.minZ + node_matrix.m32;
			tmpBox.minX = vx;
			tmpBox.minY = vy;
			tmpBox.minZ = vz;
			vx = node_matrix.m00 * tmpBox.maxX + node_matrix.m10 * tmpBox.maxY + node_matrix.m20 * tmpBox.maxZ + node_matrix.m30;
			vy = node_matrix.m01 * tmpBox.maxX + node_matrix.m11 * tmpBox.maxY + node_matrix.m21 * tmpBox.maxZ + node_matrix.m31;
			vz = node_matrix.m02 * tmpBox.maxX + node_matrix.m12 * tmpBox.maxY + node_matrix.m22 * tmpBox.maxZ + node_matrix.m32;
			tmpBox.maxX = vx;
			tmpBox.maxY = vy;
			tmpBox.maxZ = vz;
			//box.repair ();
			var t : Number;
			if (tmpBox.minX > tmpBox.maxX) t = tmpBox.minX, tmpBox.minX = tmpBox.maxX, tmpBox.maxX = t;
			if (tmpBox.minY > tmpBox.maxY) t = tmpBox.minY, tmpBox.minY = tmpBox.maxY, tmpBox.maxY = t;
			if (tmpBox.minZ > tmpBox.maxZ) t = tmpBox.minZ, tmpBox.minZ = tmpBox.maxZ, tmpBox.maxZ = t;
			
			
			
			
			var fBox:AABBox3D=frust.getBoundingBox();


			//if(!(tmpBox.intersectsWithBox(fBox))) return true;
			
			if( !(tmpBox.minX <= fBox.maxX && tmpBox.minY <= fBox.maxY && tmpBox.minZ <= fBox.maxZ &&
			      tmpBox.maxX >= fBox.minX && tmpBox.maxY >= fBox.minY && tmpBox.maxZ >= fBox.minZ))
			return true;
			// set distance for render order purposes
			var camera_matrix : Matrix4 = _activeCamera.getAbsoluteMatrix ();
			vx  = node_matrix.m30 - camera_matrix.m30;
			vy  = node_matrix.m31 - camera_matrix.m31;
			vz  = node_matrix.m32 - camera_matrix.m32;
			node.distance = (vx * vx + vy * vy + vz * vz);
			return false;
		}
	    override public function removeAll():void
	    {
	    	super.removeAll();
	    	_activeCamera=null;
	    }
	    public function setAmbientColor(color:uint):void
	    {
	    	_ambientColor=color;
	    	if(_driver) _driver.setAmbientColor(_ambientColor);
	    }
	    public function getAmbientColor():uint
	    {
	    	return _ambientColor;
	    }
	}
}

package linda.scene;

	import flash.Vector;
	import flash.Lib;
	import haxe.Log;
	
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.MathUtil;
	import linda.video.IVideoDriver;

	class SceneManager extends SceneNode
	{
		private var _driver          : IVideoDriver;
		private var _viewFrustum     : ViewFrustum;
		private var _activeCamera    : CameraSceneNode;
		private var _lightList       : Vector<SceneNode>;
		private var _solidList       : Vector<SceneNode> ;
		private var _transparentList : Vector<SceneNode>;
		private var _skyboxList      : Vector<SceneNode>;
		private var _shadowList      : Vector<SceneNode>;
		
		private var _lightCount:Int;
		private var _solidCount:Int;
		private var _transparentCount:Int;
		private var _skyboxCount:Int;
		private var _shadowCount:Int;
		
		private var _ambient         : UInt;
		
		private var tmpBox           : AABBox3D;
		
		public function new (?driver : IVideoDriver = null)
		{
			super(null);
			_solidList       = new Vector<SceneNode>();
			_transparentList = new Vector<SceneNode>();
			_lightList       = new Vector<SceneNode>();
			_skyboxList      = new Vector<SceneNode>();
			_shadowList      = new Vector<SceneNode>();
			
			_lightCount = 0;
			_solidCount = 0;
			_transparentCount = 0;
			_skyboxCount = 0;
			_shadowCount = 0;
			
			_ambient = 0x0;
			
			sceneManager = this;
			
			tmpBox = new AABBox3D();
			
			setVideoDriver(driver);
		}
		override public function destroy():Void
		{
			super.destroy();
			_driver = null;
			_viewFrustum = null;
			_activeCamera = null;
			
			_lightList.length = 0;
			_solidList.length = 0;
			_skyboxList.length = 0;
			_transparentList.length = 0;
			_shadowList.length = 0;
			
			_lightList = null;
			_solidList = null;
			_skyboxList = null;
			_transparentList = null;
			_shadowList = null;
		}

		public function getRootSceneNode () : SceneNode
		{
			return this;
		}
		public function getVideoDriver () : IVideoDriver
		{
			return _driver;
		}
		public function setVideoDriver (driver : IVideoDriver) : Void
		{
			if (driver!=null)
			{
				_driver = driver;
			}
		}
		public inline function registerNodeForRendering (node : SceneNode, type : Int) : Void
		{
			switch (type)
			{
				case SceneNode.SOLID :
				{
					if (!isCulled(node))
					{
						_solidList[_solidCount++] = node;
					}
				}
				case SceneNode.TRANSPARENT :
				{
					if (!isCulled(node))
					{
						_transparentList[_transparentCount++] = node;
					}
				}
				case SceneNode.LIGHT :
				{
					_lightList[_lightCount++] = node;
				}
				case SceneNode.SKYBOX:
				{
					_skyboxList[_skyboxCount++] = node;
				}
				case SceneNode.SHADOW:
				{
					_shadowList[_shadowCount++] = node;
				}
			}
		}
		public function drawAll () : Void
		{
			onRegisterSceneNode ();

			_activeCamera.render();
			
			//render lights
			_driver.removeAllLights();
			
			for (i in 0..._lightCount)
			{
				_lightList[i].render ();
			}
			
			for (i in 0..._skyboxCount)
			{
				_skyboxList[i].render();
			}
			
			//先渲染近的，减少重复渲染同一点
            //render solidList
			_solidList.sort(sortSceneNode);
			for (i in 0..._solidCount)
			{
				_solidList[i].render();
			}
			
			for (i in 0..._shadowCount)
			{
				_shadowList[i].render();
			}

			//先渲染远处的，避免透明度错误
			//render transparentList
			_transparentList.sort(sortTransparentSceneNode);
			for (i in 0..._transparentCount)
			{
				_transparentList[i].render();
			}
			
			onAnimate (Lib.getTimer());
			
			_lightList.length = 0;
			_solidList.length = 0;
			_transparentList.length = 0;
			_skyboxList.length = 0;
			_shadowList.length = 0;
			
			_lightCount = 0;
			_solidCount = 0;
			_transparentCount = 0;
			_skyboxCount = 0;
			_shadowCount = 0;
		}
		private inline function sortTransparentSceneNode(a:SceneNode, b:SceneNode):Int 
		{
			if (a.distance > b.distance)
			{
				return -1;
			}else if (a.distance < b.distance)
			{
				return 1;
			}else
			{
				return 0;
			}
		}
		
		private inline function sortSceneNode(a:SceneNode, b:SceneNode):Int 
		{
			if (a.distance > b.distance)
			{
				return 1;
			}else if (a.distance < b.distance)
			{
				return -1;
			}else
			{
				return 0;
			}
		}
		public function getActiveCamera () : CameraSceneNode
		{
			return _activeCamera;
		}
		public function setActiveCamera (camera : CameraSceneNode) : Void
		{
			if (camera!=null)
			{
				_activeCamera = camera;
				_viewFrustum = _activeCamera.getViewFrustum ();
			}
		}
		
		public inline function isCulled (node : SceneNode) : Bool
		{
			var node_matrix : Matrix4 = node.getAbsoluteMatrix();

			tmpBox.copy(node.getBoundingBox());
			
			node_matrix.transformBox(tmpBox);

			var fBox:AABBox3D=_viewFrustum.getBoundingBox();
			if (tmpBox.intersectsWithBox(fBox) == false)
			{
				return true;
			}else
			{
				// set distance for render order purposes
				var camera_matrix : Matrix4 = _activeCamera.getAbsoluteMatrix ();
			
				var vx :Float = node_matrix.m30 - camera_matrix.m30;
				var vy :Float = node_matrix.m31 - camera_matrix.m31;
				var vz :Float = node_matrix.m32 - camera_matrix.m32;
			
				node.distance = MathUtil.sqrt(vx * vx + vy * vy + vz * vz);
			
				return false;
			}
		}
	    override public function removeAll():Void
	    {
	    	super.removeAll();
			_activeCamera=null;
	    }
	    public function setAmbient(color:UInt):Void
	    {
	    	_ambient=color;
	    	if(_driver!=null) _driver.setAmbient(_ambient);
	    }
	    public function getAmbientColor():UInt
	    {
	    	return _ambient;
	    }
	}

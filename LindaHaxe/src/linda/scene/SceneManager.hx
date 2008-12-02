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
		
		private var _ambient         : UInt;
		
		private var tmpBox           : AABBox3D;
		
		public function new (?driver : IVideoDriver = null)
		{
			super(null);
			_solidList       = new Vector<SceneNode>();
			_transparentList = new Vector<SceneNode>();
			_lightList       = new Vector<SceneNode>();
			
			_ambient = 0x0;
			
			tmpBox = new AABBox3D();
			
			setVideoDriver(driver);
		}
		override public function destroy():Void
		{
			super.destroy();
			_driver=null;
			_viewFrustum=null;
			_activeCamera=null;
			_lightList=null;
			_solidList=null;
			_transparentList=null;
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
				case SceneNode.LIGHT :
				{
					_lightList.push(node);
				}
				case SceneNode.SOLID :
				{
					if (!isCulled(node)) _solidList.push(node);
				}
				case SceneNode.TRANSPARENT :
				{
					if (!isCulled(node)) _transparentList.push(node);
				}
			}
		}
		public function drawAll () : Void
		{
			onRegisterSceneNode ();

			_activeCamera.render();
			
			//render lights
			_driver.removeAllLights();
			
			var len : Int = _lightList.length;
			for (i in 0...len)
			{
				_lightList[i].render ();
			}
			
            //render solidList
			_solidList.sort(sortSceneNode);
			len = _solidList.length;
			for (i in 0...len)
			{
				_solidList[i].render();
			}

			//render transparentList
			_transparentList.sort(sortSceneNode);
			len = _transparentList.length;
			for (i in 0...len)
			{
				_transparentList[i].render();
			}
			
			onAnimate (Lib.getTimer());
			
			_lightList.length = 0;
			_solidList.length = 0;
			_transparentList.length = 0;
		}
		private inline function sortSceneNode(a:SceneNode, b:SceneNode):Int 
		{
			if (a.distance == b.distance) return 0;
			if (a.distance > b.distance) return 1;
			return -1;
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

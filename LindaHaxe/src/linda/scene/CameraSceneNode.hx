package linda.scene;

	import haxe.Log;
	import linda.math.Vector3;
	
	import linda.math.AABBox3D;
	import linda.math.Dimension2D;
	import linda.math.Matrix4;
	import linda.video.IVideoDriver;
	class CameraSceneNode extends SceneNode
	{
		private var upVector : Vector3;
		private var target : Vector3;
		
		private var fovy : Float;
		private var aspect : Float;
		private var near : Float;
		private var far : Float;
		private var view : Matrix4;
		private var projection : Matrix4;
		private var view_projection : Matrix4;
		private var viewFrustum : ViewFrustum;

		private var box:AABBox3D;
		
		private var tgtv : Vector3 ;
		private var tmp_up : Vector3 ;
		private var _tmp_position : Vector3 ;
		public function new (mgr:SceneManager,?target:Vector3=null)
		{
			super (mgr);
			
			autoCulling     = false;
			
			view            = new Matrix4 ();
			projection      = new Matrix4 ();
			view_projection = new Matrix4 ();
			
			viewFrustum     = new ViewFrustum ();
			
			upVector        = new Vector3 (0., 1., 0.);

			if (target != null)
			{
				this.target=target;
			}else
			{
				this.target = new Vector3(0., 0., 0.);
			}
			
			tgtv            = new Vector3 ();
			tmp_up          = new Vector3 ();
			_tmp_position   = new Vector3 ();
			
			fovy = 120.;
			aspect = 4./3.;
			near = 1.;
			far = 2000.;

			recalculateProjectionMatrix ();
			
			box = new AABBox3D ();
			box.addXYZ (-5., -5., -5.);
			box.addXYZ (5., 5., 5.);
		}
		override public function destroy():Void
		{
			upVector=null;
			target=null;
			view=null;
			projection=null;
			view_projection=null;
			viewFrustum=null;
			box=null;
			tgtv=null;
			tmp_up=null;
			_tmp_position=null;
			super.destroy();
		}
		public function getViewFrustum () : ViewFrustum
		{
			return viewFrustum;
		}
		override public function onPreRender () : Void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			if (visible && sceneManager.getActiveCamera () == this)
			{
				_tmp_position.x = _absoluteMatrix.m30;
				_tmp_position.y = _absoluteMatrix.m31;
				_tmp_position.z = _absoluteMatrix.m32;
				
				tgtv.x = target.x - _tmp_position.x;
				tgtv.y = target.y - _tmp_position.y;
				tgtv.z = target.z - _tmp_position.z;
				tgtv.normalize();

				tmp_up.copy(upVector);
				tmp_up.normalize();
				
				

				var dp : Float = tgtv.dotProduct(tmp_up);
				if (dp < 0) dp = -dp;
				if (dp < 1.001 && dp > 0.999)
				{
					tmp_up.x += 0.5;
				}

				// create the new lookat matrix
				view.pointAt (_tmp_position, target, tmp_up);
				
				// multiply projection * view
				view_projection.copy(projection);

				view_projection.multiplyE (view);

				recalculateViewArea ();

				driver.setCameraPosition(_tmp_position);
				
				sceneManager.registerNodeForRendering (this, SceneNode.CAMERA);
				
				super.onPreRender ();
			}
		}
		override public function render() : Void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			driver.setTransformViewProjection (view_projection);
		}
		public function setTarget(t : Vector3) : Void
		{
			  target = t;
		}
		public function getTarget() : Vector3
		{
			return target;
		}
		public function getUpVector() : Vector3
		{
			return upVector;
		}
		public function setFOV(fov : Float) : Void
		{
			fovy = fov;
			recalculateProjectionMatrix();
		}
		public function setAspectRatio (asp : Float) : Void
		{
			aspect = asp;
			recalculateProjectionMatrix();
		}
		public function setNear (zn : Int) : Void
		{
			near = zn;
			recalculateProjectionMatrix();	
		}
		public function setFar (zf : Int) : Void
		{
			far = zf;
			recalculateProjectionMatrix();
		}
		public function getFOV() : Float
		{
			return fovy;
		}
		public function getAspectRatio() : Float
		{
			return aspect;
		}
		public function getNear() : Float
		{
			return near;
		}
		public function getFar() : Float
		{
			return far;
		}
		public function getViewMatrix() : Matrix4
		{
			return view;
		}
		public function getProjectionMatrix() : Matrix4
		{
			return projection;
		}
		public function getViewProjectionMatrix():Matrix4
		{
			return view_projection;
		}

		public inline function recalculateProjectionMatrix() : Void
		{	
			projection.projectionPerspective (fovy, aspect, near, far);
		}
		public inline function recalculateViewArea():Void
		{
			// update the view frustum
			viewFrustum.cameraPosition=getAbsolutePosition();
			viewFrustum.setFrom(view_projection);
		}
		override public function getBoundingBox():AABBox3D
		{
			return box;
		}
	}


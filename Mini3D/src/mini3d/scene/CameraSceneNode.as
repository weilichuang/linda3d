package mini3d.scene
{
	import mini3d.core.ViewFrustum;
	import mini3d.math.AABBox3D;
	import mini3d.math.Dimension2D;
	import mini3d.math.Matrix4;
	import mini3d.math.Vector3D;
	import mini3d.render.RenderManager;
	public class CameraSceneNode extends SceneNode
	{
		protected var upVector : Vector3D;
		protected var target : Vector3D;
		
		private var fovy : Number;
		private var aspect : Number;
		private var near : Number;
		private var far : Number;
		private var view : Matrix4;
		private var projection : Matrix4;
		private var view_projection : Matrix4;
		private var viewFrustum : ViewFrustum;
		private var orthogonal : Boolean;
		private var box:AABBox3D;
		public function CameraSceneNode (mgr:SceneManager , target : Vector3D = null)
		{
			super (mgr);
			
			autoCulling = false;
			view = new Matrix4 ();
			projection = new Matrix4 ();
			view_projection = new Matrix4 ();
			target = new Vector3D (0, 0, 0);
			viewFrustum = new ViewFrustum ();
			upVector = new Vector3D (0, 1, 0);
			orthogonal = false;
			
			if (target!=null) this.target=target;
			
			fovy = 120.;
			aspect = 1;
			near = 1;
			far = 1000.;
			//这里
			recalculateProjectionMatrix ();
			
			box = new AABBox3D ();
			box.addXYZ (-5, -5, -5);
			box.addXYZ (5, 5, 5);
		}
		override public function destroy():void
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
		private var tgtv : Vector3D = new Vector3D ();
		private var tmp_up : Vector3D = new Vector3D ();
		private var _tmp_position : Vector3D = new Vector3D ();
		override public function onPreRender () : void
		{
			var driver :RenderManager = sceneManager.getRenderManager();
			if (visible && sceneManager.getActiveCamera () == this)
			{
				_tmp_position.x = _absoluteMatrix.m30;
				_tmp_position.y = _absoluteMatrix.m31;
				_tmp_position.z = _absoluteMatrix.m32;
				
				tgtv.x = target.x - _tmp_position.x;
				tgtv.y = target.y - _tmp_position.y;
				tgtv.z = target.z - _tmp_position.z;
				tgtv.normalize();
				
				tmp_up.x = upVector.x;
				tmp_up.y = upVector.y;
				tmp_up.z = upVector.z;
				tmp_up.normalize();

				var dp : Number = tgtv.x * tmp_up.x + tgtv.y * tmp_up.y + tgtv.z * tmp_up.z;
				dp = dp > 0 ? dp : -dp;
				if (dp < 1.001 && dp > 0.999)
				{
					tmp_up.x += 1.0;
				}
				// create the new lookat matrix
				view.pointAt (_tmp_position, target, tmp_up);
				
				// multiply projection * view
				view_projection.copy (projection);
				view_projection.multiplyE (view);
				
				// update the view frustum
				viewFrustum.cameraPosition=_tmp_position;
				viewFrustum.setFrom(view_projection);
				
				driver.setCameraPosition(_tmp_position);
				
				sceneManager.registerNodeForRendering (this, SceneNode.CAMERA);
				super.onPreRender ();
			}
		}
		override public function render () : void
		{
			var driver : RenderManager = sceneManager.getRenderManager();
			if (driver)
			{
				//driver.setTransformProjection(projection);
				//driver.setTransformView (view);
				driver.setTransformViewProjection (view_projection);
			}
		}
		public function setTarget (t : Vector3D) : void
		{
			  target = t;
		}
		public function getTarget () : Vector3D
		{
			return target;
		}
		public function getUpVector () : Vector3D
		{
			return upVector;
		}
		public function setFOV (fov : Number) : void
		{
			  fovy = fov;
			  recalculateProjectionMatrix ();
		}
		public function setAspectRatio (asp : Number) : void
		{
			   aspect = asp;
			   recalculateProjectionMatrix ();
		}
		public function setNear (zn : int) : void
		{
			   near = zn;
			   recalculateProjectionMatrix ();	
		}
		public function setFar (zf : int) : void
		{
			   far = zf;
			   recalculateProjectionMatrix ();
		}
		public function getFOV () : Number
		{
			return fovy;
		}
		public function getAspectRatio () : Number
		{
			return aspect;
		}
		public function getNear () : Number
		{
			return near;
		}
		public function getFar () : Number
		{
			return far;
		}
		public function getViewMatrix () : Matrix4
		{
			return view;
		}
		public function getProjectionMatrix () : Matrix4
		{
			return projection;
		}
		public function getViewProjectionMatrix():Matrix4
		{
			return view_projection;
		}
		public function isOrthogonal () : Boolean
		{
			return orthogonal;
		}
		public function setOrthogonal (ort : Boolean) : void
		{
			if(orthogonal!=ort)
			{
			  orthogonal = ort;
			  recalculateProjectionMatrix ();
			}
		}
		public function recalculateProjectionMatrix () : void
		{	
			if ( ! orthogonal)
			{
					projection.buildProjectionMatrixPerspectiveFov (fovy, aspect, near, far);
			} else
			{
				if(sceneManager && sceneManager.getRenderManager ())
				{
				    var size :Dimension2D = sceneManager.getRenderManager ().getScreenSize();
				    projection.buildProjectionMatrixOrtho (size.width, size.height, near, far);
				}
			}
		}
		override public function getBoundingBox():AABBox3D
		{
			return box;
		}
	}
}

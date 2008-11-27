package linda.scene
{
	import flash.geom.Vector3D;
	
	import linda.math.AABBox3D;
	import linda.math.Dimension2D;
	import linda.math.Matrix4;
	import linda.video.IVideoDriver;
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
		public function CameraSceneNode (mgr:SceneManager,target:Vector3D=null)
		{
			super (mgr);
			autoCulling = false;
			view = new Matrix4 ();
			projection = new Matrix4 ();
			view_projection = new Matrix4 ();
			target = new Vector3D (0, 0, 0);
			viewFrustum = new ViewFrustum ();
			upVector = new Vector3D (0., 1., 0.);
			orthogonal = false;
			
			if (target!=null) this.target=target;
			
			fovy = 120.;
			aspect = 4./3.;
			near = 1.;
			far = 2000.;
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
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			if (visible && sceneManager.getActiveCamera () == this)
			{
				_tmp_position.x = _absoluteMatrix.m30;
				_tmp_position.y = _absoluteMatrix.m31;
				_tmp_position.z = _absoluteMatrix.m32;
				tgtv.x = target.x - _tmp_position.x;
				tgtv.y = target.y - _tmp_position.y;
				tgtv.z = target.z - _tmp_position.z;
				var n : Number = Math.sqrt (tgtv.x * tgtv.x + tgtv.y * tgtv.y + tgtv.z * tgtv.z);
				if (n == 0) return;
				n = 1 / n;
				tgtv.x *= n;
				tgtv.y *= n;
				tgtv.z *= n;
				tmp_up.x = upVector.x;
				tmp_up.y = upVector.y;
				tmp_up.z = upVector.z;
				n = Math.sqrt (tmp_up.x * tmp_up.x + tmp_up.y * tmp_up.y + tmp_up.z * tmp_up.z);
				if (n == 0) return;
				n = 1 / n;
				tmp_up.x *= n;
				tmp_up.y *= n;
				tmp_up.z *= n;
				var dp : Number = tgtv.x * tmp_up.x + tgtv.y * tmp_up.y + tgtv.z * tmp_up.z;
				dp = dp > 0 ? dp : -dp;
				if (dp < 1.001 && dp > 0.999)
				{
					tmp_up.x += 0.5;
				}
				// create the new lookat matrix
				view.pointAt (_tmp_position, target, tmp_up);
				
				/*
				// multiply projection * view
				view_projection.copy (projection);
				view_projection.multiplyE (view);
				// update the view frustum
				viewFrustum.setFrom (view_projection);
				viewFrustum.cameraPosition.copy(_tmp_position);
				//recalculateViewMatrix ();
				*/
				
				view_projection.m00 = projection.m00;
				view_projection.m01 = projection.m01;
				view_projection.m02 = projection.m02;
				view_projection.m03 = projection.m03;
				view_projection.m10 = projection.m10;
				view_projection.m11 = projection.m11;
				view_projection.m12 = projection.m12;
				view_projection.m13 = projection.m13;
				view_projection.m20 = projection.m20;
				view_projection.m21 = projection.m21;
				view_projection.m22 = projection.m22;
				view_projection.m23 = projection.m23;
				view_projection.m30 = projection.m30;
				view_projection.m31 = projection.m31;
				view_projection.m32 = projection.m32;
				view_projection.m33 = projection.m33;
				
				
				var n00 : Number = view_projection.m00, n01 : Number = view_projection.m01, n02 : Number = view_projection.m02, n03 : Number = view_projection.m03;
				var n10 : Number = view_projection.m10, n11 : Number = view_projection.m11, n12 : Number = view_projection.m12, n13 : Number = view_projection.m13;
				var n20 : Number = view_projection.m20, n21 : Number = view_projection.m21, n22 : Number = view_projection.m22, n23 : Number = view_projection.m23;
				var n30 : Number = view_projection.m30, n31 : Number = view_projection.m31, n32 : Number = view_projection.m32, n33 : Number = view_projection.m33;
				view_projection.m00 = n00 * view.m00 + n10 * view.m01 + n20 * view.m02 + n30 * view.m03;
				view_projection.m01 = n01 * view.m00 + n11 * view.m01 + n21 * view.m02 + n31 * view.m03;
				view_projection.m02 = n02 * view.m00 + n12 * view.m01 + n22 * view.m02 + n32 * view.m03;
				view_projection.m03 = n03 * view.m00 + n13 * view.m01 + n23 * view.m02 + n33 * view.m03;
				view_projection.m10 = n00 * view.m10 + n10 * view.m11 + n20 * view.m12 + n30 * view.m13;
				view_projection.m11 = n01 * view.m10 + n11 * view.m11 + n21 * view.m12 + n31 * view.m13;
				view_projection.m12 = n02 * view.m10 + n12 * view.m11 + n22 * view.m12 + n32 * view.m13;
				view_projection.m13 = n03 * view.m10 + n13 * view.m11 + n23 * view.m12 + n33 * view.m13;
				view_projection.m20 = n00 * view.m20 + n10 * view.m21 + n20 * view.m22 + n30 * view.m23;
				view_projection.m21 = n01 * view.m20 + n11 * view.m21 + n21 * view.m22 + n31 * view.m23;
				view_projection.m22 = n02 * view.m20 + n12 * view.m21 + n22 * view.m22 + n32 * view.m23;
				view_projection.m23 = n03 * view.m20 + n13 * view.m21 + n23 * view.m22 + n33 * view.m23;
				view_projection.m30 = n00 * view.m30 + n10 * view.m31 + n20 * view.m32 + n30 * view.m33;
				view_projection.m31 = n01 * view.m30 + n11 * view.m31 + n21 * view.m32 + n31 * view.m33;
				view_projection.m32 = n02 * view.m30 + n12 * view.m31 + n22 * view.m32 + n32 * view.m33;
				view_projection.m33 = n03 * view.m30 + n13 * view.m31 + n23 * view.m32 + n33 * view.m33;
				

				viewFrustum.setFrom (view_projection);
				viewFrustum.cameraPosition.x=_tmp_position.x;
				viewFrustum.cameraPosition.y=_tmp_position.y;
				viewFrustum.cameraPosition.z=_tmp_position.z;
				
				driver.setCameraPosition(_tmp_position);
				sceneManager.registerNodeForRendering (this, CAMERA);
				super.onPreRender ();
			}
		}
		override public function render () : void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			//driver.setTransformProjection(projection);
			//driver.setTransformView (view);
			driver.setTransformViewProjection (view_projection);
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
					projection.projectionPerspective (fovy, aspect, near, far);
			} else
			{
				if(sceneManager && sceneManager.getVideoDriver ())
				{
				    var size :Dimension2D = sceneManager.getVideoDriver ().getScreenSize();
				    projection.projectionOrtho (size.width, size.height, near, far);
				}
			}
		}
		public function recalculateViewArea():void
		{
			viewFrustum.cameraPosition=getAbsolutePosition();
			viewFrustum.setFrom(view_projection);
		}
		override public function getBoundingBox():AABBox3D
		{
			return box;
		}
	}
}

package linda.scene
{
	import flash.geom.Vector3D;
	
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Plane3D;
	
	public class ViewFrustum
	{
		public var cameraPosition : Vector3D;
		public var planes : Array;
		
		private var farPlane : Plane3D;
		private var nearPlane : Plane3D;
		private var leftPlane : Plane3D;
		private var rightPlane : Plane3D;
		private var topPlane : Plane3D;
		private var bottomPlane : Plane3D;
		
		private var boundingBox : AABBox3D;
		
		private var _farLeftUpVector:Vector3D;
		private var _farLeftDownVector:Vector3D;
		private var _farRightUpVector:Vector3D;
		private var _farRightDownVector:Vector3D;
		
		
		public function ViewFrustum (matrix : Matrix4 = null)
		{
			// camera position
			cameraPosition = new Vector3D ();
			// create planes
			leftPlane = new Plane3D ();
			rightPlane = new Plane3D ();
			topPlane = new Plane3D ();
			bottomPlane = new Plane3D ();
			farPlane = new Plane3D ();
			nearPlane = new Plane3D ();
			boundingBox = new AABBox3D ();
			// store frustum planes in array
			planes = new Array ();
			planes.push (nearPlane);
			planes.push (farPlane);
			planes.push (leftPlane);
			planes.push (rightPlane);
			planes.push (bottomPlane);
			planes.push (topPlane);
			
			_farLeftUpVector   = new Vector3D();
			_farLeftDownVector = new Vector3D();
			_farRightUpVector  = new Vector3D();
			_farRightDownVector= new Vector3D();
			// create the planes from a matrix
			setFrom (matrix);
		}
		public function recalculateBoundingBox () : void
		{
			boundingBox.resetVector (cameraPosition);
			boundingBox.addInternalPoint (getFarLeftUp ());
			boundingBox.addInternalPoint (getFarRightUp ());
			boundingBox.addInternalPoint (getFarLeftDown ());
			boundingBox.addInternalPoint (getFarRightDown ());
		}
		public function getBoundingBox():AABBox3D
		{
			return boundingBox;
		}
		public function transform (matrix : Matrix4) : void
		{
			if (matrix == null) return;
			matrix.transformPlane (leftPlane);
			matrix.transformPlane (rightPlane);
			matrix.transformPlane (topPlane);
			matrix.transformPlane (bottomPlane);
			matrix.transformPlane (nearPlane);
			matrix.transformPlane (farPlane);
			matrix.transformVector(cameraPosition);
			recalculateBoundingBox();
		}
		
		public function getFarLeftUp () : Vector3D
		{
			farPlane.getIntersectionWithPlanes (topPlane, leftPlane, _farLeftUpVector);
			return _farLeftUpVector;
		}
		public function getFarLeftDown () : Vector3D
		{
			farPlane.getIntersectionWithPlanes (bottomPlane, leftPlane, _farLeftDownVector);
			return _farLeftDownVector;
		}
		public function getFarRightUp () : Vector3D
		{
			farPlane.getIntersectionWithPlanes (topPlane, rightPlane, _farRightUpVector);
			return _farRightUpVector;
		}
		public function getFarRightDown () : Vector3D
		{
			farPlane.getIntersectionWithPlanes (bottomPlane, rightPlane, _farRightDownVector);
			return _farRightDownVector;
		}
		public function setFrom (mat : Matrix4) : void
		{
			if (mat == null) return;
			// left clipping plane
			leftPlane.normal.x = - (mat.m03 + mat.m00);
			leftPlane.normal.y = - (mat.m13 + mat.m10);
			leftPlane.normal.z = - (mat.m23 + mat.m20);
			leftPlane.d = - (mat.m33 + mat.m30);
			var len : Number = (1.0 / leftPlane.normal.length);
			leftPlane.normal.x*=len;
			leftPlane.normal.y*=len;
			leftPlane.normal.z*=len;
			leftPlane.d *= len;
			
			// right clipping plane
			rightPlane.normal.x = - (mat.m03 - mat.m00);
			rightPlane.normal.y = - (mat.m13 - mat.m10);
			rightPlane.normal.z = - (mat.m23 - mat.m20);
			rightPlane.d = - (mat.m33 - mat.m30);
			len = (1.0 / rightPlane.normal.length);
			rightPlane.normal.x*=len;
			rightPlane.normal.y*=len;
			rightPlane.normal.z*=len;
			rightPlane.d *= len;
			
			// top clipping plane
			topPlane.normal.x = - (mat.m03 - mat.m01);
			topPlane.normal.y = - (mat.m13 - mat.m11);
			topPlane.normal.z = - (mat.m23 - mat.m21);
			topPlane.d = - (mat.m33 - mat.m31);
			len = (1.0 / topPlane.normal.length);
			topPlane.normal.x*=len;
			topPlane.normal.y*=len;
			topPlane.normal.z*=len;
			topPlane.d *= len;
			
			// bottom clipping plane
			bottomPlane.normal.x = - (mat.m03 + mat.m01);
			bottomPlane.normal.y = - (mat.m13 + mat.m11);
			bottomPlane.normal.z = - (mat.m23 + mat.m21);
			bottomPlane.d = - (mat.m33 + mat.m31);
			len = (1.0 / bottomPlane.normal.length);
			bottomPlane.normal.x*=len;
			bottomPlane.normal.y*=len;
			bottomPlane.normal.z*=len;
			bottomPlane.d *= len;
			
			// far clipping plane
			farPlane.normal.x = - (mat.m03 - mat.m02);
			farPlane.normal.y = - (mat.m13 - mat.m12);
			farPlane.normal.z = - (mat.m23 - mat.m22);
			farPlane.d = - (mat.m33 - mat.m32);
			len = (1.0 / farPlane.normal.length);
			farPlane.normal.x*=len;
			farPlane.normal.y*=len;
			farPlane.normal.z*=len;
			farPlane.d *= len;
			
			// near clipping plane
			nearPlane.normal.x = - mat.m02;
			nearPlane.normal.y = - mat.m12;
			nearPlane.normal.z = - mat.m22;
			nearPlane.d = - mat.m32;
			len = (1.0 / nearPlane.normal.length);
			nearPlane.normal.x*=len;
			nearPlane.normal.y*=len;
			nearPlane.normal.z*=len;
			nearPlane.d *= len;
			
			// make bounding box
			//recalculateBoundingBox();
			boundingBox.resetVector (cameraPosition);
			boundingBox.addInternalPoint (getFarLeftUp ());
			boundingBox.addInternalPoint (getFarRightUp ());
			boundingBox.addInternalPoint (getFarLeftDown ());
			boundingBox.addInternalPoint (getFarRightDown ());
		}
	}
}

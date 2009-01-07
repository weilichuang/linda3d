package linda.scene;

	import linda.math.Vector3;
	
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Plane3D;
	
	import linda.math.MathUtil;
	
	class ViewFrustum
	{
		public var cameraPosition : Vector3;

		private var farPlane : Plane3D;
		private var nearPlane : Plane3D;
		private var leftPlane : Plane3D;
		private var rightPlane : Plane3D;
		private var topPlane : Plane3D;
		private var bottomPlane : Plane3D;
		
		private var boundingBox : AABBox3D;
		
		private var _farLeftUpVector:Vector3;
		private var _farLeftDownVector:Vector3;
		private var _farRightUpVector:Vector3;
		private var _farRightDownVector:Vector3;
		
		
		public function new (matrix : Matrix4 = null)
		{
			// camera position
			cameraPosition = new Vector3 ();
			// create planes
			leftPlane = new Plane3D ();
			rightPlane = new Plane3D ();
			topPlane = new Plane3D ();
			bottomPlane = new Plane3D ();
			farPlane = new Plane3D ();
			nearPlane = new Plane3D ();
			boundingBox = new AABBox3D ();

			_farLeftUpVector   = new Vector3();
			_farLeftDownVector = new Vector3();
			_farRightUpVector  = new Vector3();
			_farRightDownVector= new Vector3();
			
			// create the planes from a matrix
			setFrom (matrix);
		}
		public inline function recalculateBoundingBox () : Void
		{
			boundingBox.resetVector (cameraPosition);

			boundingBox.addVector (getFarLeftUp ());
			boundingBox.addVector (getFarRightUp ());
			boundingBox.addVector (getFarLeftDown ());
			boundingBox.addVector (getFarRightDown ());
		}
		public inline function getBoundingBox():AABBox3D
		{
			return boundingBox;
		}
		public inline function transform (matrix : Matrix4) : Void
		{
			if (matrix != null)
			{
				matrix.transformPlane (leftPlane);
				matrix.transformPlane (rightPlane);
				matrix.transformPlane (topPlane);
				matrix.transformPlane (bottomPlane);
				matrix.transformPlane (nearPlane);
				matrix.transformPlane (farPlane);
			
				matrix.transformVector(cameraPosition);
				recalculateBoundingBox();
			}
		}
		public inline function getFarLeftUp () : Vector3
		{
			farPlane.getIntersectionWithPlanes (topPlane, leftPlane, _farLeftUpVector);
			return _farLeftUpVector;
		}
		public inline function getFarLeftDown () : Vector3
		{
			farPlane.getIntersectionWithPlanes (bottomPlane, leftPlane, _farLeftDownVector);
			return _farLeftDownVector;
		}
		public inline function getFarRightUp () : Vector3
		{
			farPlane.getIntersectionWithPlanes (topPlane, rightPlane, _farRightUpVector);
			return _farRightUpVector;
		}
		public inline function getFarRightDown () : Vector3
		{
			farPlane.getIntersectionWithPlanes (bottomPlane, rightPlane, _farRightDownVector);
			return _farRightDownVector;
		}
		public inline function setFrom (mat : Matrix4) : Void
		{
			if (mat != null )
			{
				// left clipping plane
				leftPlane.normal.x = - (mat.m03 + mat.m00);
				leftPlane.normal.y = - (mat.m13 + mat.m10);
				leftPlane.normal.z = - (mat.m23 + mat.m20);
				leftPlane.d = - (mat.m33 + mat.m30);
				var len : Float = MathUtil.invSqrt(leftPlane.normal.getLengthSquared());
				leftPlane.normal.scaleBy(len);
				leftPlane.d *= len;
			
				// right clipping plane
				rightPlane.normal.x = - (mat.m03 - mat.m00);
				rightPlane.normal.y = - (mat.m13 - mat.m10);
				rightPlane.normal.z = - (mat.m23 - mat.m20);
				rightPlane.d = - (mat.m33 - mat.m30);
				len  = MathUtil.invSqrt(rightPlane.normal.getLengthSquared());
				rightPlane.normal.scaleBy(len);
				rightPlane.d *= len;
			
				// top clipping plane
				topPlane.normal.x = - (mat.m03 - mat.m01);
				topPlane.normal.y = - (mat.m13 - mat.m11);
				topPlane.normal.z = - (mat.m23 - mat.m21);
				topPlane.d = - (mat.m33 - mat.m31);
				len  = MathUtil.invSqrt(topPlane.normal.getLengthSquared());
				topPlane.normal.scaleBy(len);
				topPlane.d *= len;
			
				// bottom clipping plane
				bottomPlane.normal.x = - (mat.m03 + mat.m01);
				bottomPlane.normal.y = - (mat.m13 + mat.m11);
				bottomPlane.normal.z = - (mat.m23 + mat.m21);
				bottomPlane.d = - (mat.m33 + mat.m31);
				len  = MathUtil.invSqrt(bottomPlane.normal.getLengthSquared());
				bottomPlane.normal.scaleBy(len);
				bottomPlane.d *= len;

				// far clipping plane
				farPlane.normal.x = - (mat.m03 - mat.m02);
				farPlane.normal.y = - (mat.m13 - mat.m12);
				farPlane.normal.z = - (mat.m23 - mat.m22);
				farPlane.d = - (mat.m33 - mat.m32);
				len  = MathUtil.invSqrt(farPlane.normal.getLengthSquared());
				farPlane.normal.scaleBy(len);
				farPlane.d *= len;

				// near clipping plane
				nearPlane.normal.x = - mat.m02;
				nearPlane.normal.y = - mat.m12;
				nearPlane.normal.z = - mat.m22;
				nearPlane.d = - mat.m32;
				len  = MathUtil.invSqrt(nearPlane.normal.getLengthSquared());
				nearPlane.normal.scaleBy(len);
				nearPlane.d *= len;

				// make bounding box
				recalculateBoundingBox();
			}
		}
	}


package linda.math
{
	import flash.geom.Vector3D;
	public class Matrix4
	{
		/**
		* Matrix4 :
		* x-axis   y-axis    z-axis
		*   m00     m01       m02     m03
		* 
		*   m10     m11       m12     m13
		* 
		*   m20     m21       m22     m23
		* 
		*   m30     m31       m32     m33
		* 
		*   tx      ty        tz      tw
		*/
		public var m00 : Number;
		public var m01 : Number;
		public var m02 : Number;
		public var m03 : Number;
		public var m10 : Number;
		public var m11 : Number;
		public var m12 : Number;
		public var m13 : Number;
		public var m20 : Number;
		public var m21 : Number;
		public var m22 : Number;
		public var m23 : Number;
		public var m30 : Number;
		public var m31 : Number;
		public var m32 : Number;
		public var m33 : Number;
		public function Matrix4 ()
		{
			m00 = 1;
			m01 = 0;
			m02 = 0;
			m03 = 0;
			m10 = 0;
			m11 = 1;
			m12 = 0;
			m13 = 0;
			m20 = 0;
			m21 = 0;
			m22 = 1;
			m23 = 0;
			m30 = 0;
			m31 = 0;
			m32 = 0;
			m33 = 1;
		}
		public function isIdentity () : Boolean
		{
			if (m00 != 1) return false;
			if (m01 != 0) return false;
			if (m02 != 0) return false;
			if (m03 != 0) return false;
			if (m10 != 0) return false;
			if (m11 != 1) return false;
			if (m12 != 0) return false;
			if (m13 != 0) return false;
			if (m20 != 0) return false;
			if (m21 != 0) return false;
			if (m22 != 1) return false;
			if (m23 != 0) return false;
			if (m30 != 0) return false;
			if (m31 != 0) return false;
			if (m32 != 0) return false;
			if (m33 != 1) return false;
			return true;
		}
		// Builds a left-handed look-at matrix.
		public function buildCameraLookAtMatrix (position : Vector3D, target : Vector3D, upVector : Vector3D) : void
		{
			//var zaxis:Vector3D = target.subtract(position);
			//zaxis.normalize();
			var zaxisX : Number = target.x - position.x;
			var zaxisY : Number = target.y - position.y;
			var zaxisZ : Number = target.z - position.z;
			var n : Number = Math.sqrt ((zaxisX * zaxisX) + (zaxisY * zaxisY) + (zaxisZ * zaxisZ));
			if (n != 0.)
			{
				n = 1.0 / n;
				zaxisX *= n;
				zaxisY *= n;
				zaxisZ *= n;
			}
			//var xaxis:Vector3D = upVector.cross(zaxis);
			//xaxis.normalize();
			var xaxisX : Number = (upVector.y * zaxisZ) - (upVector.z * zaxisY);
			var xaxisY : Number = (upVector.z * zaxisX) - (upVector.x * zaxisZ);
			var xaxisZ : Number = (upVector.x * zaxisY) - (upVector.y * zaxisX);
			n = Math.sqrt ((xaxisX * xaxisX) + (xaxisY * xaxisY) + (xaxisZ * xaxisZ));
			if (n != 0.)
			{
				n = 1.0 / n;
				xaxisX *= n;
				xaxisY *= n;
				xaxisZ *= n;
			}
			//var yaxis:Vector3D = zaxis.cross (xaxis);
			var yaxisX : Number = (zaxisY * xaxisZ) - (zaxisZ * xaxisY);
			var yaxisY : Number = (zaxisZ * xaxisX) - (zaxisX * xaxisZ);
			var yaxisZ : Number = (zaxisX * xaxisY) - (zaxisY * xaxisX);
			m00 = xaxisX;
			m01 = yaxisX;
			m02 = zaxisX;
			m03 = 0.;
			m10 = xaxisY;
			m11 = yaxisY;
			m12 = zaxisY;
			m13 = 0.;
			m20 = xaxisZ;
			m21 = yaxisZ;
			m22 = zaxisZ;
			m23 = 0.;
			//m30 = -xaxis.dot(position);
			m30 = - ((xaxisX * position.x) + (xaxisY * position.y) + (xaxisZ * position.z))
			//m31 = -yaxis.dot(position);
			m31 = - ((yaxisX * position.x) + (yaxisY * position.y) + (yaxisZ * position.z))
			//m32 = -zaxis.dot(position);
			m32 = - ((zaxisX * position.x) + (zaxisY * position.y) + (zaxisZ * position.z))
			m33 = 1.0;
		}
		// Builds a left-handed perspective projection matrix based on a field of view
		public function buildProjectionMatrixPerspectiveFov (fov : Number, aspect : Number, zNear : Number, zFar : Number) : void
		{
			var halffov : Number = fov * 0.5 * 0.01745329;
			var h : Number = Math.tan(halffov);
			var w : Number = h / aspect;
			m00 = 2. * zNear / w;
			m01 = 0.;
			m02 = 0.;
			m03 = 0.;
			m10 = 0;
			m11 = 2. * zNear / h;
			m12 = 0.;
			m13 = 0.;
			m20 = 0.;
			m21 = 0.;
			m22 = zFar / (zFar - zNear);
			m23 = 1.;
			m30 = 0.;
			m31 = 0.;
			m32 = zNear * zFar / (zNear - zFar);
			m33 = 0.;
		}
		// Builds a matrix that flattens geometry into a plane.
		public function buildShadowMatrix (light : Vector3D, plane : Plane3D, point : Number) : void
		{
			plane.normal.normalize ();
			//plane.normal.dot(light);
			var d : Number = (plane.normal.x * light.x + plane.normal.y * light.y + plane.normal.z * light.z);
			m00 = plane.normal.x * light.x + d;
			m01 = plane.normal.x * light.y;
			m02 = plane.normal.x * light.z;
			m03 = plane.normal.x * point;
			m10 = plane.normal.y * light.x;
			m11 = plane.normal.y * light.y + d;
			m12 = plane.normal.y * light.z;
			m13 = plane.normal.y * point;
			m20 = plane.normal.z * light.x;
			m21 = plane.normal.z * light.y;
			m22 = plane.normal.z * light.z + d;
			m23 = plane.normal.z * point;
			m30 = plane.d * light.x + d;
			m31 = plane.d * light.y;
			m32 = plane.d * light.z;
			m33 = plane.d * point;
		}
		// Builds a left-handed orthogonal projection matrix.
		public function buildProjectionMatrixOrtho (width : Number, height : Number, zNear : Number, zFar : Number) : void
		{
			m00 = 2. / width;
			m01 = 0.;
			m02 = 0.;
			m03 = 0.;
			m10 = 0.;
			m11 = 2. / height;
			m12 = 0.;
			m13 = 0.;
			m20 = 0.;
			m21 = 0.;
			m22 = 1. / (zFar - zNear);
			m23 = 0.;
			m30 = 0.;
			m31 = 0.;
			m32 = zNear / (zNear - zFar);
			m33 = 1.;
		}
		public function getInverse (matrix : Matrix4) : Boolean
		{
			var d : Number = (m00 * m11 - m01 * m10) * (m22 * m33 - m23 * m32) - (m00 * m12 - m02 * m10) * (m21 * m33 - m23 * m31)
			+ (m00 * m13 - m03 * m10) * (m21 * m32 - m22 * m31) + (m01 * m12 - m02 * m11) * (m20 * m33 - m23 * m30)
			- (m01 * m13 - m03 * m11) * (m20 * m32 - m22 * m30) + (m02 * m13 - m03 * m12) * (m20 * m31 - m21 * m30);
			if (d == 0.0)
			{
				return false;
			}
			d = 1.0 / d;
			matrix.m00 = d * (m11 * (m22 * m33 - m23 * m32) + m12 * (m23 * m31 - m21 * m33) + m13 * (m21 * m32 - m22 * m31));
			matrix.m01 = d * (m21 * (m02 * m33 - m03 * m32) + m22 * (m03 * m31 - m01 * m33) + m23 * (m01 * m32 - m02 * m31));
			matrix.m02 = d * (m31 * (m02 * m13 - m03 * m12) + m32 * (m03 * m11 - m01 * m13) + m33 * (m01 * m12 - m02 * m11));
			matrix.m03 = d * (m01 * (m13 * m22 - m12 * m23) + m02 * (m11 * m23 - m13 * m21) + m03 * (m12 * m21 - m11 * m22));
			matrix.m10 = d * (m12 * (m20 * m33 - m23 * m30) + m13 * (m22 * m30 - m20 * m32) + m10 * (m23 * m32 - m22 * m33));
			matrix.m11 = d * (m22 * (m00 * m33 - m03 * m30) + m23 * (m02 * m30 - m00 * m32) + m20 * (m03 * m32 - m02 * m33));
			matrix.m12 = d * (m32 * (m00 * m13 - m03 * m10) + m33 * (m02 * m10 - m00 * m12) + m30 * (m03 * m12 - m02 * m13));
			matrix.m13 = d * (m02 * (m13 * m20 - m10 * m23) + m03 * (m10 * m22 - m12 * m20) + m00 * (m12 * m23 - m13 * m22));
			matrix.m20 = d * (m13 * (m20 * m31 - m21 * m30) + m10 * (m21 * m33 - m23 * m31) + m11 * (m23 * m30 - m20 * m33));
			matrix.m21 = d * (m23 * (m00 * m31 - m01 * m30) + m20 * (m01 * m33 - m03 * m31) + m21 * (m03 * m30 - m00 * m33));
			matrix.m22 = d * (m33 * (m00 * m11 - m01 * m10) + m30 * (m01 * m13 - m03 * m11) + m31 * (m03 * m10 - m00 * m13));
			matrix.m23 = d * (m03 * (m11 * m20 - m10 * m21) + m00 * (m13 * m21 - m11 * m23) + m01 * (m10 * m23 - m13 * m20));
			matrix.m30 = d * (m10 * (m22 * m31 - m21 * m32) + m11 * (m20 * m32 - m22 * m30) + m12 * (m21 * m30 - m20 * m31));
			matrix.m31 = d * (m20 * (m02 * m31 - m01 * m32) + m21 * (m00 * m32 - m02 * m30) + m22 * (m01 * m30 - m00 * m31));
			matrix.m32 = d * (m30 * (m02 * m11 - m01 * m12) + m31 * (m00 * m12 - m02 * m10) + m32 * (m01 * m10 - m00 * m11));
			matrix.m33 = d * (m00 * (m11 * m22 - m12 * m21) + m01 * (m12 * m20 - m10 * m22) + m02 * (m10 * m21 - m11 * m20));
			return true;
		}

		public function buildNDCToDCMatrix (rect :Dimension2D, scale : Number = 1) : void
		{
			var scaleX : Number =   (rect.width - 0.75) * 0.5;
			var scaleY : Number = - (rect.height- 0.75) * 0.5;
			
			var dx : Number = - 0.5 + rect.width * 0.5;
			var dy : Number = - 0.5 + rect.height * 0.5;
			
			makeIdentity ();
			m00 = scaleX;
			m11 = scaleY;
			m22 = scale;
			m30 = dx;
			m31 = dy;
		}
		public function multiplyWith1x4Matrix (m : *) : void
		{
			if (m is Vertex4D || m is Quaternion)
			{
				var x : Number = m.x, y : Number = m.y, z : Number = m.z, w : Number = m.w;
				m.x = m00 * x + m10 * y + m20 * z + m30 * w;
				m.y = m01 * x + m11 * y + m21 * z + m31 * w;
				m.z = m02 * x + m12 * y + m22 * z + m32 * w;
				m.w = m03 * x + m13 * y + m23 * z + m33 * w;
			} else if (m is Array)
			{
				x = m [0] , y = m [1] , z = m [2] , w = m [3];
				m [0] = m00 * x + m10 * y + m20 * z + m30 * w;
				m [1] = m01 * x + m11 * y + m21 * z + m31 * w;
				m [2] = m02 * x + m12 * y + m22 * z + m32 * w;
				m [3] = m03 * x + m13 * y + m23 * z + m33 * w;
			}
		}
		public function makeInverse () : Boolean
		{
			var temp : Matrix4 = new Matrix4 ();
			if (getInverse (temp))
			{
				copy (temp);
				return true;
			}
			return false;
		}
		public function makeIdentity () : void
		{
			m00 = 1.;
			m01 = 0.;
			m02 = 0.;
			m03 = 0.;
			m10 = 0.;
			m11 = 1.;
			m12 = 0.;
			m13 = 0.;
			m20 = 0.;
			m21 = 0.;
			m22 = 1.;
			m23 = 0.;
			m30 = 0.;
			m31 = 0.;
			m32 = 0.;
			m33 = 1.;
		}
		public function setRotationDegrees (rotation : Vector3D) : void
		{
			var rx : Number = rotation.x * 0.017453292519943;
			var ry : Number = rotation.y * 0.017453292519943;
			var rz : Number = rotation.z * 0.017453292519943;

			var cr : Number = Math.cos (rx );
			var sr : Number = Math.sin (rx );
			var cp : Number = Math.cos (ry );
			var sp : Number = Math.sin (ry );
			var cy : Number = Math.cos (rz );
			var sy : Number = Math.sin (rz );
			
			m00 = (cp * cy );
			m01 = (cp * sy );
			m02 = ( - sp );
			var srsp : Number = sr * sp;
			var crsp : Number = cr * sp;
			m10 = (srsp * cy - cr * sy );
			m11 = (srsp * sy + cr * cy );
			m12 = (sr * cp );
			m20 = (crsp * cy + sr * sy );
			m21 = (crsp * sy - sr * cy );
			m22 = (cr * cp );
		}

		public function setRotation (rotation : Vector3D) : void
		{
			var cr : Number = Math.cos (rotation.x );
			var sr : Number = Math.sin (rotation.x );
			var cp : Number = Math.cos (rotation.y );
			var sp : Number = Math.sin (rotation.y );
			var cy : Number = Math.cos (rotation.z );
			var sy : Number = Math.sin (rotation.z );
			
			
			m00 = (cp * cy );
			m01 = (cp * sy );
			m02 = ( - sp );
			var srsp : Number = sr * sp;
			var crsp : Number = cr * sp;
			m10 = (srsp * cy - cr * sy );
			m11 = (srsp * sy + cr * cy );
			m12 = (sr * cp );
			m20 = (crsp * cy + sr * sy );
			m21 = (crsp * sy - sr * cy );
			m22 = (cr * cp );
		}
		public function setTranslation (translation : Vector3D) : void
		{
			m30 = translation.x;
			m31 = translation.y;
			m32 = translation.z;
		}
		public function setInverseTranslation (translation : Vector3D) : void
		{
			m30 = -translation.x;
			m31 = -translation.y;
			m32 = -translation.z;
		}
		public function setScale (scale : Vector3D) : void
		{
			m00 = scale.x;
			m11 = scale.y;
			m22 = scale.z;
		}
		public function setScaleXYZ (sx:Number,sy:Number,sz:Number) : void
		{
			m00 = sx;
			m11 = sy;
			m22 = sz;
		}
		public function getRotation () : Vector3D
		{
			var y : Number = - Math.asin (m02);
			var d : Number = y;
			var c : Number = Math.cos (y);
			var rotx : Number, roty : Number, x : Number, z : Number;
			c = c < 0.? - c : c ;
			if (c > 0.0005)
			{
				c = 1 / c;
				rotx = m22 * c;
				roty = m12 * c;
				x = Math.atan2 (roty, rotx );
				rotx = m00 * c;
				roty = m01 * c;
				z = Math.atan2 (roty, rotx );
			} 
			else
			{
				x = 0.0;
				rotx = m11;
				roty = - m10;
				z = Math.atan2 (roty, rotx );
			}
			if (x < 0.0)
			{
				x += MathUtil.TWO_PI;
			}
			if (y < 0.0)
			{
				y += MathUtil.TWO_PI;
			}
			if (z < 0.0)
			{
				z += MathUtil.TWO_PI;
			}
			return new Vector3D (x, y, z);
		}
		public function getRotationDegrees () : Vector3D
		{
			var y : Number = - Math.asin (m02);
			var d : Number = y;
			var c : Number = Math.cos (y);
			var rotx : Number, roty : Number, x : Number, z : Number;
			c = c < 0.? - c : c ;
			//Math.abs(c);
			if (c > 0.0005)
			{
				c = 1 / c;
				rotx = m22 * c;
				roty = m12 * c;
				x = Math.atan2 (roty, rotx );
				rotx = m00 * c;
				roty = m01 * c;
				z = Math.atan2 (roty, rotx );
			} 
			else
			{
				x = 0.0;
				rotx = m11;
				roty = - m10;
				z = Math.atan2 (roty, rotx );
			}
			if (x < 0.00)
			{
				x += MathUtil.TWO_PI;
			}
			if (y < 0.00)
			{
				y += MathUtil.TWO_PI;
			}
			if (z < 0.00)
			{
				z += MathUtil.TWO_PI;
			}
			x = x * 57.2957795;
			y = y * 57.2957795;
			z = z * 57.2957795;
			return new Vector3D (x, y, z);
		}
		public function getTranslation () : Vector3D
		{
			return new Vector3D (m30, m31, m32);
		}
		public function getScale () : Vector3D
		{
			var scale : Vector3D = new Vector3D ();
			scale.x = Math.sqrt (m00 * m00 + m01 * m01 + m02 * m02);
			scale.y = Math.sqrt (m10 * m10 + m11 * m11 + m12 * m12);
			scale.z = Math.sqrt (m20 * m20 + m21 * m21 + m22 * m22);
			return scale;
		}

		public function getRight():Vector3D
		{
			var right:Vector3D=new Vector3D(m00,m01,m02);
			return right;
		}
		public function getUp():Vector3D
		{
			var up:Vector3D=new Vector3D(m10,m11,m12);
			return up;
		}
		public function getForward():Vector3D
		{
			var forward:Vector3D=new Vector3D(m20,m21,m22);
			return forward;
		}
		
		public function copy (other : Matrix4) : void
		{
			m00 = other.m00;
			m01 = other.m01;
			m02 = other.m02;
			m03 = other.m03;
			m10 = other.m10;
			m11 = other.m11;
			m12 = other.m12;
			m13 = other.m13;
			m20 = other.m20;
			m21 = other.m21;
			m22 = other.m22;
			m23 = other.m23;
			m30 = other.m30;
			m31 = other.m31;
			m32 = other.m32;
			m33 = other.m33;
		}
		public function clone () : Matrix4
		{
			var m : Matrix4 = new Matrix4 ();
			m.m00 = m00;
			m.m01 = m01;
			m.m02 = m02;
			m.m03 = m03;
			m.m10 = m10;
			m.m11 = m11;
			m.m12 = m12;
			m.m13 = m13;
			m.m20 = m20;
			m.m21 = m21;
			m.m22 = m22;
			m.m23 = m23;
			m.m30 = m30;
			m.m31 = m31;
			m.m32 = m32;
			m.m33 = m33;
			return m;
		}
		public function multiply (other : Matrix4) : Matrix4
		{
			var m : Matrix4 = new Matrix4 ();
			m.m00 = m00 * other.m00 + m10 * other.m01 + m20 * other.m02 + m30 * other.m03;
			m.m01 = m01 * other.m00 + m11 * other.m01 + m21 * other.m02 + m31 * other.m03;
			m.m02 = m02 * other.m00 + m12 * other.m01 + m22 * other.m02 + m32 * other.m03;
			m.m03 = m03 * other.m00 + m13 * other.m01 + m23 * other.m02 + m33 * other.m03;
			m.m10 = m00 * other.m10 + m10 * other.m11 + m20 * other.m12 + m30 * other.m13;
			m.m11 = m01 * other.m10 + m11 * other.m11 + m21 * other.m12 + m31 * other.m13;
			m.m12 = m02 * other.m10 + m12 * other.m11 + m22 * other.m12 + m32 * other.m13;
			m.m13 = m03 * other.m10 + m13 * other.m11 + m23 * other.m12 + m33 * other.m13;
			m.m20 = m00 * other.m20 + m10 * other.m21 + m20 * other.m22 + m30 * other.m23;
			m.m21 = m01 * other.m20 + m11 * other.m21 + m21 * other.m22 + m31 * other.m23;
			m.m22 = m02 * other.m20 + m12 * other.m21 + m22 * other.m22 + m32 * other.m23;
			m.m23 = m03 * other.m20 + m13 * other.m21 + m23 * other.m22 + m33 * other.m23;
			m.m30 = m00 * other.m30 + m10 * other.m31 + m20 * other.m32 + m30 * other.m33;
			m.m31 = m01 * other.m30 + m11 * other.m31 + m21 * other.m32 + m31 * other.m33;
			m.m32 = m02 * other.m30 + m12 * other.m31 + m22 * other.m32 + m32 * other.m33;
			m.m33 = m03 * other.m30 + m13 * other.m31 + m23 * other.m32 + m33 * other.m33;
			return m;
		}
		public function multiplyE (other : Matrix4) : void
		{
			var n00 : Number = m00; 
			var n01 : Number = m01; 
			var n02 : Number = m02; 
			var n03 : Number = m03;
			var n10 : Number = m10; 
			var n11 : Number = m11; 
			var n12 : Number = m12; 
			var n13 : Number = m13;
			var n20 : Number = m20; 
			var n21 : Number = m21; 
			var n22 : Number = m22; 
			var n23 : Number = m23;
			var n30 : Number = m30; 
			var n31 : Number = m31; 
			var n32 : Number = m32; 
			var n33 : Number = m33;
			m00 = n00 * other.m00 + n10 * other.m01 + n20 * other.m02 + n30 * other.m03;
			m01 = n01 * other.m00 + n11 * other.m01 + n21 * other.m02 + n31 * other.m03;
			m02 = n02 * other.m00 + n12 * other.m01 + n22 * other.m02 + n32 * other.m03;
			m03 = n03 * other.m00 + n13 * other.m01 + n23 * other.m02 + n33 * other.m03;
			m10 = n00 * other.m10 + n10 * other.m11 + n20 * other.m12 + n30 * other.m13;
			m11 = n01 * other.m10 + n11 * other.m11 + n21 * other.m12 + n31 * other.m13;
			m12 = n02 * other.m10 + n12 * other.m11 + n22 * other.m12 + n32 * other.m13;
			m13 = n03 * other.m10 + n13 * other.m11 + n23 * other.m12 + n33 * other.m13;
			m20 = n00 * other.m20 + n10 * other.m21 + n20 * other.m22 + n30 * other.m23;
			m21 = n01 * other.m20 + n11 * other.m21 + n21 * other.m22 + n31 * other.m23;
			m22 = n02 * other.m20 + n12 * other.m21 + n22 * other.m22 + n32 * other.m23;
			m23 = n03 * other.m20 + n13 * other.m21 + n23 * other.m22 + n33 * other.m23;
			m30 = n00 * other.m30 + n10 * other.m31 + n20 * other.m32 + n30 * other.m33;
			m31 = n01 * other.m30 + n11 * other.m31 + n21 * other.m32 + n31 * other.m33;
			m32 = n02 * other.m30 + n12 * other.m31 + n22 * other.m32 + n32 * other.m33;
			m33 = n03 * other.m30 + n13 * other.m31 + n23 * other.m32 + n33 * other.m33;
		}
		//
		public function getTransposed(o:Matrix4):Matrix4
		{
			if(o==null) o=new Matrix4();
			o.m00=m00;
			o.m01=m10;
			o.m02=m20;
			o.m03=m30;
			
			o.m10=m01;
			o.m11=m11;
			o.m12=m21;
			o.m13=m31;
			
			o.m20=m02;
			o.m21=m12;
			o.m22=m22;
			o.m23=m32;
			
			o.m30=m03;
			o.m31=m13;
			o.m32=m23;
			o.m33=m33;
			
			return o;
		}
		public function translateVertex(vect:Vertex):void
		{
			var x : Number = vect.x;
			var y : Number = vect.y;
			var z : Number = vect.z;
			vect.x += m30;
			vect.y += m31;
			vect.z += m32;
		}
		public function translateVector(vect:Vector3D):void
		{
			var x : Number = vect.x;
			var y : Number = vect.y;
			var z : Number = vect.z;
			vect.x += m30;
			vect.y += m31;
			vect.z += m32;
		}
		public function rotateVector (vect : Vector3D ) : void
		{
			var x : Number = vect.x;
			var y : Number = vect.y;
			var z : Number = vect.z;
			vect.x = x * m00 + y * m10 + z * m20;
			vect.y = x * m01 + y * m11 + z * m21;
			vect.z = x * m02 + y * m12 + z * m22;
		}
		public function rotateVertex (vect : Vertex ) : void
		{
			var x : Number = vect.x;
			var y : Number = vect.y;
			var z : Number = vect.z;
			vect.x = x * m00 + y * m10 + z * m20;
			vect.y = x * m01 + y * m11 + z * m21;
			vect.z = x * m02 + y * m12 + z * m22;
		}
		public function rotateVector2 (vect : Vector3D, out : Vector3D ) : void
		{
			var x : Number = vect.x;
			var y : Number = vect.y;
			var z : Number = vect.z;
			out.x = x * m00 + y * m10 + z * m20;
			out.y = x * m01 + y * m11 + z * m21;
			out.z = x * m02 + y * m12 + z * m22;
		}
		public function rotateVertex2 (vect : Vertex, out : Vertex ) : void
		{
			var x : Number = vect.x;
			var y : Number = vect.y;
			var z : Number = vect.z;
			out.x = x * m00 + y * m10 + z * m20;
			out.y = x * m01 + y * m11 + z * m21;
			out.z = x * m02 + y * m12 + z * m22;
		}
		// Transforms a plane by this matrix
		public function transformPlane (plane : Plane3D) : void
		{
			//rotate normal -> rotateVect ( plane.n );
			var x : Number;
			var y : Number;
			var z : Number;
			x = plane.normal.x * m00 + plane.normal.y * m10 + plane.normal.z * m20;
			y = plane.normal.x * m01 + plane.normal.y * m11 + plane.normal.z * m21;
			z = plane.normal.x * m02 + plane.normal.y * m12 + plane.normal.z * m22;
			//compute new d. -> getTranslation(). dotproduct ( plane.n )
			plane.d -= (m30 * x + m31 * y + m32 * z);
			plane.normal.x = x;
			plane.normal.y = y;
			plane.normal.z = z;
		}
		public function transformVector2 (vector : Vector3D, out : Vector3D) : void
		{
			var x : Number = vector.x;
			var y : Number = vector.y;
			var z : Number = vector.z;
			out.x = (m00 * x + m10 * y + m20 * z + m30);
			out.y = (m01 * x + m11 * y + m21 * z + m31);
			out.z = (m02 * x + m12 * y + m22 * z + m32);
		}
		public function transformVector (vector : Vector3D) : void
		{
			var x : Number = vector.x;
			var y : Number = vector.y;
			var z : Number = vector.z;
			vector.x = (m00 * x + m10 * y + m20 * z + m30);
			vector.y = (m01 * x + m11 * y + m21 * z + m31);
			vector.z = (m02 * x + m12 * y + m22 * z + m32);
		}
		public function transformVertex (vector : Vertex) : void
		{
			var x : Number = vector.x;
			var y : Number = vector.y;
			var z : Number = vector.z;
			vector.x = (m00 * x + m10 * y + m20 * z + m30);
			vector.y = (m01 * x + m11 * y + m21 * z + m31);
			vector.z = (m02 * x + m12 * y + m22 * z + m32);
		}
		public function transformVertex2 (vector : Vertex, out : Vertex) : void
		{
			var x : Number = vector.x;
			var y : Number = vector.y;
			var z : Number = vector.z;
			out.x = (m00 * x + m10 * y + m20 * z + m30);
			out.y = (m01 * x + m11 * y + m21 * z + m31);
			out.z = (m02 * x + m12 * y + m22 * z + m32);
		}
		public function transformBox (box : AABBox3D) : void
		{
			var x : Number;
			var y : Number;
			var z : Number;
			x = m00 * box.minX + m10 * box.minY + m20 * box.minZ + m30;
			y = m01 * box.minX + m11 * box.minY + m21 * box.minZ + m31;
			z = m02 * box.minX + m12 * box.minY + m22 * box.minZ + m32;
			box.minX = x;
			box.minY = y;
			box.minZ = z;
			x = m00 * box.maxX + m10 * box.maxY + m20 * box.maxZ + m30;
			y = m01 * box.maxX + m11 * box.maxY + m21 * box.maxZ + m31;
			z = m02 * box.maxX + m12 * box.maxY + m22 * box.maxZ + m32;
			box.maxX = x;
			box.maxY = y;
			box.maxZ = z;
			//box.repair ();
			var t : Number;
			if (box.minX > box.maxX) t = box.minX; box.minX = box.maxX; box.maxX = t;
			if (box.minY > box.maxY) t = box.minY; box.minY = box.maxY; box.maxY = t;
			if (box.minZ > box.maxZ) t = box.minZ; box.minZ = box.maxZ; box.maxZ = t;
		}
		public function transformBox2 (box : AABBox3D, outBox : AABBox3D) : void
		{
			var x : Number;
			var y : Number;
			var z : Number;
			x = m00 * box.minX + m10 * box.minY + m20 * box.minZ + m30;
			y = m01 * box.minX + m11 * box.minY + m21 * box.minZ + m31;
			z = m02 * box.minX + m12 * box.minY + m22 * box.minZ + m32;
			outBox.minX = x;
			outBox.minY = y;
			outBox.minZ = z;
			x = m00 * box.maxX + m10 * box.maxY + m20 * box.maxZ + m30;
			y = m01 * box.maxX + m11 * box.maxY + m21 * box.maxZ + m31;
			z = m02 * box.maxX + m12 * box.maxY + m22 * box.maxZ + m32;
			outBox.maxX = x;
			outBox.maxY = y;
			outBox.maxZ = z;
			//box.repair ();
			var t : Number;
			if (outBox.minX > outBox.maxX) t = outBox.minX; outBox.minX = outBox.maxX; outBox.maxX = t;
			if (outBox.minY > outBox.maxY) t = outBox.minY; outBox.minY = outBox.maxY; outBox.maxY = t;
			if (outBox.minZ > outBox.maxZ) t = outBox.minZ; outBox.minZ = outBox.maxZ; outBox.maxZ = t;
		}
		/**
		* 矩阵格式化打印，每个项只输出三位小数
		*/
		public function toString () : String
		{
			var s : String = new String ("Matrix4 :\n");
			s += (int (m00 * 1000) / 1000) + "\t" + (int (m01 * 1000) / 1000) + "\t" + (int (m02 * 1000) / 1000) + "\t" + (int (m03 * 1000) / 1000) + "\n";
			s += (int (m10 * 1000) / 1000) + "\t" + (int (m11 * 1000) / 1000) + "\t" + (int (m12 * 1000) / 1000) + "\t" + (int (m13 * 1000) / 1000) + "\n";
			s += (int (m20 * 1000) / 1000) + "\t" + (int (m21 * 1000) / 1000) + "\t" + (int (m22 * 1000) / 1000) + "\t" + (int (m23 * 1000) / 1000) + "\n";
			s += (int (m30 * 1000) / 1000) + "\t" + (int (m31 * 1000) / 1000) + "\t" + (int (m32 * 1000) / 1000) + "\t" + (int (m33 * 1000) / 1000) + "\n";
			return s;
		}
	}
}

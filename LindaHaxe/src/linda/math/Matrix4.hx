package linda.math;
	import flash.Vector;
	import haxe.Log;
    import linda.math.Vector3;
	class Matrix4
	{
		/**
		 * The matrix is a D3D style matrix, row major with translations in the 4th row.
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
		public var m00 : Float;
		public var m01 : Float;
		public var m02 : Float;
		public var m03 : Float;
		public var m10 : Float;
		public var m11 : Float;
		public var m12 : Float;
		public var m13 : Float;
		public var m20 : Float;
		public var m21 : Float;
		public var m22 : Float;
		public var m23 : Float;
		public var m30 : Float;
		public var m31 : Float;
		public var m32 : Float;
		public var m33 : Float;
		
		public function new (?v:Array<Float>=null)
		{
			if (v == null || v.length<16)
			{
				makeIdentity();
			}else
			{
				setArray(v);
			}
		}
		/**
		 * 
		 * @param	vec vec.length==16;
		 */
		public inline function setArray(v:Array<Float>):Void 
		{
			m00 = v[0];
			m01 = v[1];
			m02 = v[2];
			m03 = v[3];
			m10 = v[4];
			m11 = v[5];
			m12 = v[6];
			m13 = v[7];
			m20 = v[8];
			m21 = v[9];
			m22 = v[10];
			m23 = v[11];
			m30 = v[12];
			m31 = v[13];
			m32 = v[14];
			m33 = v[15];
		}
		public inline function pointAt (position : Vector3, target : Vector3, upVector : Vector3) : Void
		{
			var zaxis:Vector3 = target.subtract(position);
			zaxis.normalize();

			var xaxis:Vector3 = upVector.crossProduct(zaxis);
			xaxis.normalize();

			var yaxis:Vector3 = zaxis.crossProduct (xaxis);
			
			m00 = xaxis.x;
			m01 = yaxis.x;
			m02 = zaxis.x;
			m03 = 0.;
			m10 = xaxis.y;
			m11 = yaxis.y;
			m12 = zaxis.y;
			m13 = 0.;
			m20 = xaxis.z;
			m21 = yaxis.z;
			m22 = zaxis.z;
			m23 = 0.;
			m30 = -xaxis.dotProduct(position);
			m31 = -yaxis.dotProduct(position);
			m32 = -zaxis.dotProduct(position);
			m33 = 1.0;
			
			zaxis = null;
			xaxis = null;
			yaxis = null;
		}
		public inline function projectionPerspective(fov : Float, aspect : Float, zNear : Float, zFar : Float) : Void
		{
			var halffov : Float = fov * 0.5 ;
			var h : Float = Math.tan(halffov);
			var w : Float = h / aspect;
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
		
		public inline function inverse () :Void
		{
			var d : Float = (m00 * m11 - m01 * m10) * (m22 * m33 - m23 * m32) - (m00 * m12 - m02 * m10) * (m21 * m33 - m23 * m31)
			              + (m00 * m13 - m03 * m10) * (m21 * m32 - m22 * m31) + (m01 * m12 - m02 * m11) * (m20 * m33 - m23 * m30)
			              - (m01 * m13 - m03 * m11) * (m20 * m32 - m22 * m30) + (m02 * m13 - m03 * m12) * (m20 * m31 - m21 * m30);
			
			if (d == 0.0) d = 0 else d = 1.0 / d;

			var n00 : Float = d * (m11 * (m22 * m33 - m23 * m32) + m12 * (m23 * m31 - m21 * m33) + m13 * (m21 * m32 - m22 * m31));
			var n01 : Float = d * (m21 * (m02 * m33 - m03 * m32) + m22 * (m03 * m31 - m01 * m33) + m23 * (m01 * m32 - m02 * m31));
			var n02 : Float = d * (m31 * (m02 * m13 - m03 * m12) + m32 * (m03 * m11 - m01 * m13) + m33 * (m01 * m12 - m02 * m11));
			var n03 : Float = d * (m01 * (m13 * m22 - m12 * m23) + m02 * (m11 * m23 - m13 * m21) + m03 * (m12 * m21 - m11 * m22));
			var n10 : Float = d * (m12 * (m20 * m33 - m23 * m30) + m13 * (m22 * m30 - m20 * m32) + m10 * (m23 * m32 - m22 * m33));
			var n11 : Float = d * (m22 * (m00 * m33 - m03 * m30) + m23 * (m02 * m30 - m00 * m32) + m20 * (m03 * m32 - m02 * m33));
			var n12 : Float = d * (m32 * (m00 * m13 - m03 * m10) + m33 * (m02 * m10 - m00 * m12) + m30 * (m03 * m12 - m02 * m13));
			var n13 : Float = d * (m02 * (m13 * m20 - m10 * m23) + m03 * (m10 * m22 - m12 * m20) + m00 * (m12 * m23 - m13 * m22));
			var n20 : Float = d * (m13 * (m20 * m31 - m21 * m30) + m10 * (m21 * m33 - m23 * m31) + m11 * (m23 * m30 - m20 * m33));
			var n21 : Float = d * (m23 * (m00 * m31 - m01 * m30) + m20 * (m01 * m33 - m03 * m31) + m21 * (m03 * m30 - m00 * m33));
			var n22 : Float = d * (m33 * (m00 * m11 - m01 * m10) + m30 * (m01 * m13 - m03 * m11) + m31 * (m03 * m10 - m00 * m13));
			var n23 : Float = d * (m03 * (m11 * m20 - m10 * m21) + m00 * (m13 * m21 - m11 * m23) + m01 * (m10 * m23 - m13 * m20));
			var n30 : Float = d * (m10 * (m22 * m31 - m21 * m32) + m11 * (m20 * m32 - m22 * m30) + m12 * (m21 * m30 - m20 * m31));
			var n31 : Float = d * (m20 * (m02 * m31 - m01 * m32) + m21 * (m00 * m32 - m02 * m30) + m22 * (m01 * m30 - m00 * m31));
			var n32 : Float = d * (m30 * (m02 * m11 - m01 * m12) + m31 * (m00 * m12 - m02 * m10) + m32 * (m01 * m10 - m00 * m11));
			var n33 : Float = d * (m00 * (m11 * m22 - m12 * m21) + m01 * (m12 * m20 - m10 * m22) + m02 * (m10 * m21 - m11 * m20));
			
			
			m00 = n00;
			m01 = n01;
			m02 = n02;
			m03 = n03;
			m10 = n10;
			m11 = n11;
			m12 = n12;
			m13 = n13;
			m20 = n20;
			m21 = n21;
			m22 = n22;
			m23 = n23;
			m30 = n30;
			m31 = n31;
			m32 = n32;
			m33 = n33;
			
		}
		
		public inline function inverse4x3 () :Void
		{
			var d : Float = (m00 * m11 - m01 * m10) * m22  - (m00 * m12 - m02 * m10) * m21 + (m01 * m12 - m02 * m11) * m20 ;
			if (d == 0.0) d = 0 else d = 1.0 / d;

			var n00 : Float = d * (m11 * m22 - m12 * m21);
			var n01 : Float = d * (m21 * m02 - m22 * m01);
			var n02 : Float = d * (m01 * m12 - m02 * m11);
			var n10 : Float = d * (m12 * m20 - m10 * m22);
			var n11 : Float = d * (m22 * m00 - m20 * m02);
			var n12 : Float = d * (m02 * m10 - m00 * m12);
			var n20 : Float = d * (m10 * m21 - m11 * m20);
			var n21 : Float = d * (m20 * m01 - m21 * m00);
			var n22 : Float = d * (m00 * m11 - m01 * m10);
			var n30 : Float = d * (m10 * (m22 * m31 - m21 * m32) + m11 * (m20 * m32 - m22 * m30) + m12 * (m21 * m30 - m20 * m31));
			var n31 : Float = d * (m20 * (m02 * m31 - m01 * m32) + m21 * (m00 * m32 - m02 * m30) + m22 * (m01 * m30 - m00 * m31));
			var n32 : Float = d * (m30 * (m02 * m11 - m01 * m12) + m31 * (m00 * m12 - m02 * m10) + m32 * (m01 * m10 - m00 * m11));

			m00 = n00;
			m01 = n01;
			m02 = n02;
			m03 = 0;
			m10 = n10;
			m11 = n11;
			m12 = n12;
			m13 = 0;
			m20 = n20;
			m21 = n21;
			m22 = n22;
			m23 = 0;
			m30 = n30;
			m31 = n31;
			m32 = n32;
			m33 = 1;
			
		}

		public inline function buildNDCToDCMatrix (rect :Dimension2D, ?scale : Float = 1.) : Void
		{
			var scaleX : Float =   (rect.width - 0.75) * 0.5;
			var scaleY : Float = - (rect.height- 0.75) * 0.5;
			
			var dx : Float = - 0.5 + rect.width * 0.5;
			var dy : Float = - 0.5 + rect.height * 0.5;
			
			makeIdentity();
			m00 = scaleX;
			m11 = scaleY;
			m22 = scale;
			m30 = dx;
			m31 = dy;
		}
		public inline function makeIdentity() : Void
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
		public inline function setRotation (rotation : Vector3) : Void
		{
			var rx : Float = rotation.x;
			var ry : Float = rotation.y;
			var rz : Float = rotation.z;

			var cr : Float = MathUtil.cos(rx);
			var sr : Float = MathUtil.sin(rx);
			var cp : Float = MathUtil.cos(ry);
			var sp : Float = MathUtil.sin(ry);
			var cy : Float = MathUtil.cos(rz);
			var sy : Float = MathUtil.sin(rz);
			
			m00 = (cp * cy );
			m01 = (cp * sy );
			m02 = ( - sp );
			var srsp : Float = sr * sp;
			var crsp : Float = cr * sp;
			m10 = (srsp * cy - cr * sy );
			m11 = (srsp * sy + cr * cy );
			m12 = (sr * cp );
			m20 = (crsp * cy + sr * sy );
			m21 = (crsp * sy - sr * cy );
			m22 = (cr * cp );
		}

		public inline function setTranslation (translation : Vector3) : Void
		{
			m30 = translation.x;
			m31 = translation.y;
			m32 = translation.z;
		}
		public inline function setScale (scale : Vector3) : Void
		{
			m00 = scale.x;
			m11 = scale.y;
			m22 = scale.z;
		}
		public inline function scale(v:Vector3):Void
		{
			var rx:Float = v.x;
			var ry:Float = v.y;
			var rz:Float = v.z;
			
			m00 *= rx ;
			m01 *= rx ;
			m02 *= rx ;
			m10 *= ry ;
			m11 *= ry ;
			m12 *= ry ;
			m20 *= rz ;
			m21 *= rz ;
			m22 *= rz ;
		}
		public inline function getRotation () : Vector3
		{
			var y : Float = - Math.asin (m02);
			var d : Float = y;
			var c : Float = MathUtil.cos (y);
			var rotx : Float, roty : Float, x : Float, z : Float;
			c = MathUtil.abs(c);
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
			return new Vector3 (x, y, z);
		}
		public inline function getTranslation () : Vector3
		{
			return new Vector3 (m30, m31, m32);
		}
		public inline function getScale () : Vector3
		{
			var scale : Vector3 = new Vector3 ();
			scale.x = MathUtil.sqrt (m00 * m00 + m01 * m01 + m02 * m02);
			scale.y = MathUtil.sqrt (m10 * m10 + m11 * m11 + m12 * m12);
			scale.z = MathUtil.sqrt (m20 * m20 + m21 * m21 + m22 * m22);
			return scale;
		}

		public inline function getRight():Vector3
		{
			return new Vector3(m00,m01,m02);
		}
		public inline function getUp():Vector3
		{
			return new Vector3(m10,m11,m12);
		}
		public inline function getForward():Vector3
		{
			return new Vector3(m20,m21,m22);
		}
		
		public inline function copy (other : Matrix4) : Void
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
		public inline function clone () : Matrix4
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
		public inline function multiply (other : Matrix4) : Matrix4
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
		public inline function multiply4x3 (other : Matrix4) : Matrix4
		{
			var m : Matrix4 = new Matrix4 ();
			m.m00 = m00 * other.m00 + m10 * other.m01 + m20 * other.m02 ;
			m.m01 = m01 * other.m00 + m11 * other.m01 + m21 * other.m02 ;
			m.m02 = m02 * other.m00 + m12 * other.m01 + m22 * other.m02 ;
			m.m03 = 0.;
			m.m10 = m00 * other.m10 + m10 * other.m11 + m20 * other.m12 ;
			m.m11 = m01 * other.m10 + m11 * other.m11 + m21 * other.m12 ;
			m.m12 = m02 * other.m10 + m12 * other.m11 + m22 * other.m12 ;
			m.m13 = 0.;
			m.m20 = m00 * other.m20 + m10 * other.m21 + m20 * other.m22 ;
			m.m21 = m01 * other.m20 + m11 * other.m21 + m21 * other.m22 ;
			m.m22 = m02 * other.m20 + m12 * other.m21 + m22 * other.m22 ;
			m.m23 = 0.;
			m.m30 = m00 * other.m30 + m10 * other.m31 + m20 * other.m32 + m30;
			m.m31 = m01 * other.m30 + m11 * other.m31 + m21 * other.m32 + m31 ;
			m.m32 = m02 * other.m30 + m12 * other.m31 + m22 * other.m32 + m32 ;
			m.m33 = 1.;
			return m;
		}
		public inline function multiplyBy (other : Matrix4) : Void
		{
			var n00 : Float = m00; 
			var n01 : Float = m01; 
			var n02 : Float = m02; 
			var n03 : Float = m03;
			var n10 : Float = m10; 
			var n11 : Float = m11; 
			var n12 : Float = m12; 
			var n13 : Float = m13;
			var n20 : Float = m20; 
			var n21 : Float = m21; 
			var n22 : Float = m22; 
			var n23 : Float = m23;
			var n30 : Float = m30; 
			var n31 : Float = m31; 
			var n32 : Float = m32; 
			var n33 : Float = m33;
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
		public inline function multiply4x3By (other : Matrix4) : Void
		{
			var n00 : Float = m00; 
			var n01 : Float = m01; 
			var n02 : Float = m02; 

			var n10 : Float = m10; 
			var n11 : Float = m11; 
			var n12 : Float = m12; 

			var n20 : Float = m20; 
			var n21 : Float = m21; 
			var n22 : Float = m22; 

			var n30 : Float = m30; 
			var n31 : Float = m31; 
			var n32 : Float = m32; 

			m00 = n00 * other.m00 + n10 * other.m01 + n20 * other.m02 ;
			m01 = n01 * other.m00 + n11 * other.m01 + n21 * other.m02 ;
			m02 = n02 * other.m00 + n12 * other.m01 + n22 * other.m02 ;
			m03 = 0.;
			m10 = n00 * other.m10 + n10 * other.m11 + n20 * other.m12 ;
			m11 = n01 * other.m10 + n11 * other.m11 + n21 * other.m12 ;
			m12 = n02 * other.m10 + n12 * other.m11 + n22 * other.m12 ;
			m13 = 0.;
			m20 = n00 * other.m20 + n10 * other.m21 + n20 * other.m22 ;
			m21 = n01 * other.m20 + n11 * other.m21 + n21 * other.m22 ;
			m22 = n02 * other.m20 + n12 * other.m21 + n22 * other.m22 ;
			m23 = 0.;
			m30 = n00 * other.m30 + n10 * other.m31 + n20 * other.m32 + n30 ;
			m31 = n01 * other.m30 + n11 * other.m31 + n21 * other.m32 + n31 ;
			m32 = n02 * other.m30 + n12 * other.m31 + n22 * other.m32 + n32 ;
			m33 = 1.;
		}
		public inline function translateVertex(vect:Vertex):Void
		{
			vect.x += m30;
			vect.y += m31;
			vect.z += m32;
		}
		public inline function translateVector(vect:Vector3):Void
		{
			vect.x += m30;
			vect.y += m31;
			vect.z += m32;
		}
		public inline function rotateVector (vect : Vector3 ) : Void
		{
			var x : Float = vect.x;
			var y : Float = vect.y;
			var z : Float = vect.z;
			vect.x = x * m00 + y * m10 + z * m20;
			vect.y = x * m01 + y * m11 + z * m21;
			vect.z = x * m02 + y * m12 + z * m22;
		}
		public inline function rotateVertex (vect : Vertex,?normal:Bool=false) : Void
		{
			var x : Float = vect.x;
			var y : Float = vect.y;
			var z : Float = vect.z;
			vect.x = x * m00 + y * m10 + z * m20;
			vect.y = x * m01 + y * m11 + z * m21;
			vect.z = x * m02 + y * m12 + z * m22;
			if (normal)
			{
				x  = vect.nx;
		    	y  = vect.ny;
		    	z  = vect.nz;
				vect.nx = (m00 * x + m10 * y + m20 * z);
				vect.ny = (m00 * x + m10 * y + m20 * z);
				vect.nz = (m00 * x + m10 * y + m20 * z);
				vect.normalize();
			} 
		}

		public inline function transformPlane (plane : Plane3D) : Void
		{
			//rotate normal -> rotateVect( plane.n );
			var x : Float;
			var y : Float;
			var z : Float;
			x = plane.normal.x * m00 + plane.normal.y * m10 + plane.normal.z * m20;
			y = plane.normal.x * m01 + plane.normal.y * m11 + plane.normal.z * m21;
			z = plane.normal.x * m02 + plane.normal.y * m12 + plane.normal.z * m22;
			//compute new d. -> getTranslation(). dotproduct ( plane.n )
			plane.d -= (m30 * x + m31 * y + m32 * z);
			plane.normal.x = x;
			plane.normal.y = y;
			plane.normal.z = z;
		}

		public inline function transformVector (vector : Vector3) : Void
		{
			var x : Float = vector.x;
			var y : Float = vector.y;
			var z : Float = vector.z;
			vector.x = (m00 * x + m10 * y + m20 * z + m30);
			vector.y = (m01 * x + m11 * y + m21 * z + m31);
			vector.z = (m02 * x + m12 * y + m22 * z + m32);
		}
		public inline function transformVertex (vect : Vertex,?normal:Bool=false) : Void
		{
			var x : Float = vect.x;
			var y : Float = vect.y;
			var z : Float = vect.z;
			vect.x = (m00 * x + m10 * y + m20 * z + m30);
			vect.y = (m01 * x + m11 * y + m21 * z + m31);
			vect.z = (m02 * x + m12 * y + m22 * z + m32);
			if (normal)
			{
				//rotate normal and normalize;
				x  = vect.nx;
		    	y  = vect.ny;
		    	z  = vect.nz;
				vect.nx = (m00 * x + m10 * y + m20 * z);
				vect.ny = (m00 * x + m10 * y + m20 * z);
				vect.nz = (m00 * x + m10 * y + m20 * z);
				vect.normalize();
			}
		}

		public inline function transformBox (box : AABBox3D) : Void
		{
			var x : Float;
			var y : Float;
			var z : Float;
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
			box.repair ();
		}
		
		public inline function isOrthogonal():Bool 
		{
			return false;
		}

		/**
		* 矩阵格式化打印，每个项只输出三位小数
		*/
		public function toString () : String
		{
			var s : String = new String ("Matrix4 :\n");
			s += (Std.int (m00 * 1000) / 1000) + "\t" + (Std.int (m01 * 1000) / 1000) + "\t" + (Std.int (m02 * 1000) / 1000) + "\t" + (Std.int (m03 * 1000) / 1000) + "\n";
			s += (Std.int (m10 * 1000) / 1000) + "\t" + (Std.int (m11 * 1000) / 1000) + "\t" + (Std.int (m12 * 1000) / 1000) + "\t" + (Std.int (m13 * 1000) / 1000) + "\n";
			s += (Std.int (m20 * 1000) / 1000) + "\t" + (Std.int (m21 * 1000) / 1000) + "\t" + (Std.int (m22 * 1000) / 1000) + "\t" + (Std.int (m23 * 1000) / 1000) + "\n";
			s += (Std.int (m30 * 1000) / 1000) + "\t" + (Std.int (m31 * 1000) / 1000) + "\t" + (Std.int (m32 * 1000) / 1000) + "\t" + (Std.int (m33 * 1000) / 1000) + "\n";
			return s;
		}
	}

package linda.math
{
	import flash.geom.Vector3D;
	
	public final class Quaternion
	{
		public var x : Number = 0.;
		public var y : Number = 0.;
		public var z : Number = 0.;
		public var w : Number = 1.;
		public function Quaternion (x : Number = 0., y : Number = 0., z : Number = 0., w : Number = 1.)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
		}
		public function equals (other : Quaternion) : Boolean
		{
			return (x == other.x && y == other.y && z == other.z && w == other.z);
		}
		public function copy (other : Quaternion) : void
		{
			x = other.x;
			y = other.y;
			z = other.z;
			w = other.w;
		}
		public function setMatrix4 (m : Matrix4) : void
		{
			var diag : Number = m.m00 + m.m11 + m.m22 + 1;
			var scale : Number = 0.0;
			if (diag > 0.0)
			{
				scale = 1 / (Math.sqrt (diag) * 2.0);
				// get scale from diagonal
				x = (m.m21 - m.m12) * scale;
				y = (m.m02 - m.m20) * scale;
				z = (m.m10 - m.m01) * scale;
				w = 0.25 * scale;
			} 
			else
			{
				if (m.m00 > m.m11 && m.m00 > m.m22)
				
				{
					// 1st element of diag is greatest value
					// find scale according to 1st element, and double it
					scale = 1 / (Math.sqrt (1.0 + m.m00 - m.m11 - m.m22) * 2.0);
					x = 0.25 / scale;
					y = (m.m10 + m.m01) * scale;
					z = (m.m02 + m.m20) * scale;
					w = (m.m21 - m.m12) * scale;
					
				} 
				else if (m.m11 > m.m22 ) 
				
				{
					// 2nd element of diag is greatest value
					// find scale according to 2nd element, and double it
					scale = 1 / (Math.sqrt (1.0 + m.m11 - m.m00 - m.m11) * 2.0);
					x = (m.m10 + m.m01 ) * scale;
					y = 0.25 / scale;
					z = (m.m21 + m.m12 ) * scale;
					w = (m.m02 - m.m20 ) * scale;
					
				} 
				else
				{
					// 3rd element of diag is greatest value
					// find scale according to 3rd element, and double it
					scale = 1 / (Math.sqrt (1.0 + m.m22 - m.m00 - m.m11) * 2.0);
					x = (m.m02 + m.m20) * scale;
					y = (m.m21 + m.m12) * scale;
					z = 0.25 / scale;
					w = (m.m10 - m.m01) * scale;
					
				}
			}
			normalize ();
		}
		public function getMatrix4 (m : Matrix4) : Matrix4
		{
			if (m == null)
			{
				m = new Matrix4 ();
			}
			m.m00 = 1.0 - 2.0 * y * y - 2.0 * z * z;
			m.m10 = 2.0 * x * y + 2.0 * z * w;
			m.m20 = 2.0 * x * z - 2.0 * y * w;
			m.m30 = 0.0;
			m.m01 = 2.0 * x * y - 2.0 * z * w;
			m.m11 = 1.0 - 2.0 * x * x - 2.0 * z * z;
			m.m21 = 2.0 * z * y + 2.0 * x * w;
			m.m31 = 0.0;
			m.m02 = 2.0 * x * z + 2.0 * y * w;
			m.m12 = 2.0 * z * y - 2.0 * x * w;
			m.m22 = 1.0 - 2.0 * x * x - 2.0 * y * y;
			m.m32 = 0.0;
			m.m03 = 0.0;
			m.m13 = 0.0;
			m.m23 = 0.0;
			m.m33 = 1.0;
			return m;
		}
		public function multiply (other : Quaternion) : Quaternion
		{
			var tmp : Quaternion = new Quaternion ( (other.w * x) + (other.x * w) + (other.y * z) - (other.z * y) ,
			(other.w * y) + (other.y * w) + (other.z * x) - (other.x * z) ,
			(other.w * z) + (other.z * w) + (other.x * y) - (other.y * x) ,
			(other.w * w) - (other.x * x) - (other.y * y) - (other.z * z));
			return tmp;
		}
		public function multiplyE (other : Quaternion) : void
		{
			var xx : Number = (other.w * x) + (other.x * w) + (other.y * z) - (other.z * y);
			var yy : Number = (other.w * y) + (other.y * w) + (other.z * x) - (other.x * z);
			var zz : Number = (other.w * z) + (other.z * w) + (other.x * y) - (other.y * x);
			var ww : Number = (other.w * w) - (other.x * x) - (other.y * y) - (other.z * z);
			x = xx;
			y = yy;
			z = zz;
			w = ww;
		}
		public function scale (s : Number) : Quaternion
		{
			return new Quaternion (s * x, s * y, s * z, s * w);
		}
		public function scaleE (s : Number) : void
		{
			x *= s;
			y *= s;
			z *= s;
			w *= s;
		}
		public function add (b : Quaternion) : Quaternion
		{
			return new Quaternion (x + b.x, y + b.y, z + b.z, w + b.w);
		}
		public function addE (b : Quaternion) : void
		{
			x += b.x;
			y += b.y;
			z += b.z;
			w += b.w;
		}
		//! Inverts this quaternion
		public function makeInverse () : void
		{
			x = - x;
			y = - y;
			z = - z;
		}
		public function setXYZW (x : Number, y : Number, z : Number, w : Number) : void
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
		}
		public function setXYZ (x : Number, y : Number, z : Number) : void
		{
			var angle : Number;
			angle = x * 0.5;
			var sr : Number = Math.sin (angle);
			var cr : Number = Math.cos (angle);
			angle = y * 0.5;
			var sp : Number = Math.sin (angle);
			var cp : Number = Math.cos (angle);
			angle = z * 0.5;
			var sy : Number = Math.sin (angle);
			var cy : Number = Math.cos (angle);
			var cpcy : Number = cp * cy;
			var spcy : Number = sp * cy;
			var cpsy : Number = cp * sy;
			var spsy : Number = sp * sy;
			x = (sr * cpcy - cr * spsy);
			y = (cr * spcy + sr * cpsy);
			z = (cr * cpsy - sr * spcy);
			w = (cr * cpcy + sr * spsy);
			normalize ();
		}
		public function normalize () : Quaternion
		{
			var n : Number = x * x + y * y + z * z + w * w;
			if (n == 0)
			{
				return this;
			}
			n = 1.0 / Math.sqrt (n);
			x *= n;
			y *= n;
			z *= n;
			w *= n;
			return this;
		}
		public function slerp (q1 : Quaternion, q2 : Quaternion, time : Number) : Quaternion
		{
			var angle : Number = q1.dot (q2);
			if (angle < 0.0)
			{
				q1.scaleE ( - 1.0);
				angle *= - 1.0;
			}
			var scale : Number;
			var invscale : Number;
			var xx : Number, yy : Number, zz : Number, ww : Number;
			if ((angle + 1.0) > 0.05)
			{
				if ((1.0 - angle) >= 0.05) // spherical interpolation
				
				{
					var theta : Number = Math.acos (angle);
					var invsintheta : Number = 1.0 / Math.sin (theta);
					scale = Math.sin (theta * (1.0 - time)) * invsintheta;
					invscale = Math.sin (theta * time) * invsintheta;
				} 
				else // linear interploation
				
				{
					scale = 1.0 - time;
					invscale = time;
				}
				xx = q2.x;
				yy = q2.y;
				zz = q2.z;
				ww = q2.w;
			} 
			else
			{
				//q2 = new Quaternion(-q1.Y, q1.X, -q1.W, q1.Z);
				xx = - q1.y;
				yy = q1.x;
				zz = - q1.w;
				ww = q1.z;
				scale = Math.sin (Math.PI * (0.5 - time));
				invscale = Math.sin (Math.PI * time);
			}
			//this = (q1*scale) + (q2*invscale);
			x = (q1.x * scale) + (xx * invscale);
			y = (q1.y * scale) + (yy * invscale);
			z = (q1.z * scale) + (zz * invscale);
			w = (q1.w * scale) + (ww * invscale);
			return this;
		}
		public function dot (q2 : Quaternion) : Number
		{
			return (x * q2.x) + (y * q2.y) + (z * q2.z) + (w * q2.w);
		}
		// axis must be unit length
		// The quaternion representing the rotation is
		//  q = cos(A/2)+sin(A/2)*(x*i+y*j+z*k)
		public function fromAngleAxis (angle : Number, axis : Vector3D) : void
		{
			var fHalfAngle : Number = 0.5 * angle;
			var fSin : Number = Math.sin (fHalfAngle);
			w = Math.cos (fHalfAngle);
			x = fSin * axis.x;
			y = fSin * axis.y;
			z = fSin * axis.z;
		}
		public function toEuler (euler : Vector3D) : void
		{
			var sqw : Number = w * w;
			var sqx : Number = x * x;
			var sqy : Number = y * y;
			var sqz : Number = z * z;
			// heading = rotation about z-axis
			euler.z = (Math.atan2 (2.0 * (x * y + z * w) , (sqx - sqy - sqz + sqw)));
			// bank = rotation about x-axis
			euler.x = (Math.atan2 (2.0 * (y * z + x * w) , ( - sqx - sqy + sqz + sqw)));
			// attitude = rotation about y-axis
			euler.y = (Math.asin ( - 2.0 * (x * z - y * w)));
		}
		public function multiplyVector3D (vIn : Vector3D, vOut : Vector3D) : void
		{
			//var uv:Vector3D, uuv:Vector3D;
			//var qvec:Vector3D = new Vector3D(X, Y, Z);
			//uv = qvec.crossProduct(vIn);
			var uvx : Number = (y * vIn.z) - (z * vIn.y);
			var uvy : Number = (z * vIn.x) - (x * vIn.z);
			var uvz : Number = (x * vIn.y) - (y * vIn.x);
			//uuv = qvec.crossProduct(uv);
			var uuvx : Number = (y * uvz) - (z * uvy);
			var uuvy : Number = (z * uvx) - (x * uvz);
			var uuvz : Number = (x * uvy) - (y * uvx);
			//uv *= (2.0 * W);
			uvx *= 2.0 * w;
			uvy *= 2.0 * w;
			uvz *= 2.0 * w;
			//uuv *= 2.0;
			uuvx *= 2.0;
			uuvy *= 2.0;
			uuvz *= 2.0;
			//vOut = vIn + uv + uuv;
			vOut.x = vIn.x + uvx + uuvx;
			vOut.y = vIn.y + uvy + uuvy;
			vOut.z = vIn.z + uvz + uuvz;
		}
		public function clone () : Quaternion
		{
			return new Quaternion (x, y, z, w);
		}
		public function toString () : String 
		{
			return "[Quaternion - x:" + x + " y:" + y + " z:" + z + " w:" + w + "]";
		}
	}
}

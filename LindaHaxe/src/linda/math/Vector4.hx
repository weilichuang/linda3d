package linda.math;
import flash.events.FocusEvent;

class Vector4 
{
    public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	public function new(x:Float=0.,y:Float=0.,z:Float=0.,w:Float=0.) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public inline function makeIdentity():Void
	{
		w = 1.;
		x = 0.;
		y = 0.;
		z = 0.;
	}
	
	public inline function add(other:Vector4):Vector4
	{
		var tmp:Vector4 = new Vector4();
		tmp.x = x + other.x;
		tmp.y = y + other.y;
		tmp.z = z + other.z;
		tmp.w = w + other.w;
		return tmp;
	}
	
	public inline function addBy(other:Vector4):Void 
	{
		x += other.x;
		y += other.y;
		z += other.z;
		w += other.w;
	}
	
	public inline function scale(s:Float):Vector4 
	{
		var tmp:Vector4 = new Vector4();
		tmp.x = x * s;
		tmp.y = y * s;
		tmp.z = z * s;
		tmp.w = w * s;
		return tmp;
	}
	
	public inline function scaleBy(s:Float):Void 
	{
		x *= s;
		y *= s;
		z *= s;
		w *= s;
	}
	
	public inline function multiply(other:Vector4):Vector4 
	{
		var tmp:Vector4 = new Vector4();
		tmp.w = (other.w * w) - (other.x * x) - (other.y * y) - (other.z * z);
		tmp.x = (other.w * x) + (other.x * w) + (other.y * z) - (other.z * y);
		tmp.y = (other.w * y) + (other.y * w) + (other.z * x) - (other.x * z);
		tmp.z = (other.w * z) + (other.z * w) + (other.x * y) - (other.y * x);
		return tmp;
	}
	
	public inline function multiplyBy(other:Vector4):Void 
	{
		var tw:Float = (other.w * w) - (other.x * x) - (other.y * y) - (other.z * z);
		var tx:Float = (other.w * x) + (other.x * w) + (other.y * z) - (other.z * y);
		var ty:Float = (other.w * y) + (other.y * w) + (other.z * x) - (other.x * z);
		var tz:Float = (other.w * z) + (other.z * w) + (other.x * y) - (other.y * x);
		
		x = tx;
		y = ty;
		z = tz;
		w = tw;
	}
	
	public inline function setMatrix(m:Matrix4):Void 
	{
		var diag = m.m00 + m.m11 + m.m22 + 1;

		if( diag > 0.0 )
		{
			var invScale:Float = MathUtil.invSqrt(diag) * 0.5; // get invScale from diagonal

			x = ( m.m12 - m.m21) * invScale;
			y = ( m.m20 - m.m02) * invScale;
			z = ( m.m01 - m.m10) * invScale;
			w = 0.25 / invScale;
		}
		else
		{
			if ( m.m00 > m.m11 && m.m00 > m.m22)
			{
				// 1st element of diag is greatest value
				// find scale according to 1st element, and double it
				var invScale:Float = MathUtil.invSqrt(1+m.m00-m.m11-m.m22) * 0.5;

				x = 0.25  / invScale;
				y = (m.m10 + m.m01) * invScale;
				z = (m.m02 + m.m20) * invScale;
				w = (m.m12 - m.m21) * invScale;
			}
			else if ( m.m11 > m.m22)
			{
				// 2nd element of diag is greatest value
				// find scale according to 2nd element, and double it
				var invScale:Float = MathUtil.invSqrt(1 + m.m11 - m.m00 - m.m22) * 0.5;
				
				x = (m.m10 + m.m01) * invScale;
				y = 0.25 / invScale;
				z = (m.m21 + m.m12) * invScale;
				w = (m.m20 - m.m02) * invScale;
			}
			else
			{
				// 3rd element of diag is greatest value
				// find scale according to 3rd element, and double it
				var invScale:Float = MathUtil.invSqrt(1 + m.m22 - m.m00 - m.m11) * 0.5;

				x = (m.m02 + m.m20) * invScale;
				y = (m.m12 + m.m21) * invScale;
				z = 0.25 / invScale;
				w = (m.m01 - m.m10) * invScale;
			}
		}

		normalize();
	}
	
	public inline function getMatrix(matrix:Matrix4=null):Matrix4
	{
		if (matrix == null)
		{
			matrix = new Matrix4();
		}
		matrix.m00 = 1.0 - 2.0*y*y - 2.0*z*z;
		matrix.m01 = 2.0*x*y + 2.0*z*w;
		matrix.m02 = 2.0*x*z - 2.0*y*w;
		matrix.m03 = 0.0;

		matrix.m10 = 2.0*x*y - 2.0*z*w;
		matrix.m11 = 1.0 - 2.0*x*x - 2.0*z*z;
		matrix.m12 = 2.0*z*y + 2.0*x*w;
		matrix.m13 = 0.0;

		matrix.m20 = 2.0*x*z + 2.0*y*w;
		matrix.m21 = 2.0*z*y - 2.0*x*w;
		matrix.m22 = 1.0 - 2.0*x*x - 2.0*y*y;
		matrix.m23 = 0.0;

		matrix.m30 = 0.;
		matrix.m31 = 0.;
		matrix.m32 = 0.;
		matrix.m33 = 1.;
		
		return matrix;
	}
	
	public inline function getTransposedMatrix(matrix:Matrix4=null):Matrix4
	{
		if (matrix == null)
		{
			matrix = new Matrix4();
		}
		matrix.m00 = 1.0 - 2.0*y*y - 2.0*z*z;
		matrix.m10 = 2.0*x*y + 2.0*z*w;
		matrix.m20 = 2.0*x*z - 2.0*y*w;
		matrix.m30 = 0.0;

		matrix.m01 = 2.0*x*y - 2.0*z*w;
		matrix.m11 = 1.0 - 2.0*x*x - 2.0*z*z;
		matrix.m21 = 2.0*z*y + 2.0*x*w;
		matrix.m31= 0.0;

		matrix.m02 = 2.0*x*z + 2.0*y*w;
		matrix.m12 = 2.0*z*y - 2.0*x*w;
		matrix.m22 = 1.0 - 2.0*x*x - 2.0*y*y;
		matrix.m32 = 0.0;

		matrix.m03 = 0.;
		matrix.m13 = 0.;
		matrix.m23 = 0.;
		matrix.m33 = 1.;
		
		return matrix;
	}
	
	public inline function inverse():Void 
	{
		x = -x;
		y = -y;
		z = -z;
	}
	
	public inline function setAngle(vec:Vector3):Void 
	{
		var angle:Float;

		angle = vec.x * MathUtil.PI_OVER_ONE_EIGHTY * 0.5;
		var sr:Float = MathUtil.sin(angle);
		var cr:Float = MathUtil.cos(angle);

		angle = vec.y * MathUtil.PI_OVER_ONE_EIGHTY * 0.5;
		var sp:Float = MathUtil.sin(angle);
		var cp:Float = MathUtil.cos(angle);

		angle = vec.z * MathUtil.PI_OVER_ONE_EIGHTY * 0.5;
		var sy:Float = MathUtil.sin(angle);
		var cy:Float = MathUtil.cos(angle);

		var cpcy:Float = cp * cy;
		var spcy:Float = sp * cy;
		var cpsy:Float = cp * sy;
		var spsy:Float = sp * sy;

		x = (sr * cpcy - cr * spsy);
		y = (cr * spcy + sr * cpsy);
		z = (cr * cpsy - sr * spcy);
		w = (cr * cpcy + sr * spsy);

		normalize();
	}
	
	public inline function normalize():Void 
	{
		var n:Float = x * x + y * y + z * z + w * w;
		
		var inv:Float = MathUtil.invSqrt(n);
		
		x *= n;
		y *= n;
		z *= n;
		w *= n;
	}
	
	public inline function set(x:Float, y:Float, z:Float, w:Float):Void 
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	// set this quaternion to the result of the interpolation between two quaternions
	public inline function slerp(q1:Vector4,q2:Vector4,time:Float):Void 
	{
		var angle:Float = q1.dotProduct(q2);

		if (angle < 0.0)
		{
			q1.scale( -1.0);
			angle *= -1.0;
		}

		var scale:Float;
		var invscale:Float;

		if ((angle + 1.0) > 0.05)
		{
			if ((1.0 - angle) >= 0.05) // spherical interpolation
			{
				var theta:Float = Math.acos(angle);
				var invsintheta:Float = 1/MathUtil.sin(theta);
				scale = MathUtil.sin(theta * (1.0-time)) * invsintheta;
				invscale = MathUtil.sin(theta * time) * invsintheta;
			}
			else // linear interploation
			{
				scale = 1.0 - time;
				invscale = time;
			}
		}
		else
		{
			q2.set(-q1.y, q1.x, -q1.w, q1.z);
			scale = MathUtil.sin(Math.PI * (0.5 - time));
			invscale = MathUtil.sin(Math.PI * time);
		}
        
		x = q1.x * scale + q2.x * invscale;
		y = q1.y * scale + q2.y * invscale;
		z = q1.z * scale + q2.z * invscale;
		w = q1.w * scale + q2.w * invscale;
	}
	
	
	//! axis must be unit length
	//! angle in radians
	public inline function fromAngleAxis(angle:Float,axis:Vector3):Void 
	{
		var fHalfAngle:Float = 0.5*angle;
		var fSin:Float = MathUtil.sin(fHalfAngle);
		w = MathUtil.cos(fHalfAngle);
		x = fSin*axis.x;
		y = fSin*axis.y;
		z = fSin*axis.z;
	}


	public inline function toAngleAxis(angle:Float,axis:Vector3):Void 
	{
		var scale:Float = Math.sqrt(x*x + y*y + z*z);

		if (scale<MathUtil.ROUNDING_ERROR || w > 1.0 || w < -1.0)
		{
			angle = 0.0;
			axis.x = 0.0;
			axis.y = 1.0;
			axis.z = 0.0;
		}
		else
		{
			var invscale:Float = 1/scale;
			angle = 2.0 * MathUtil.cos(w);
			axis.x = x * invscale;
			axis.y = y * invscale;
			axis.z = z * invscale;
		}
	}

	public inline function toEuler(euler:Vector3):Void
	{
		var sqw:Float = w*w;
		var sqx:Float = x*x;
		var sqy:Float = y*y;
		var sqz:Float = z*z;

		// heading = rotation about z-axis
		euler.z = (Math.atan2(2.0 * (x*y +z*w),(sqx - sqy - sqz + sqw)));

		// bank = rotation about x-axis
		euler.x = (Math.atan2(2.0 * (y*z +x*w),(-sqx - sqy + sqz + sqw)));

		// attitude = rotation about y-axis
		euler.y = MathUtil.sin(MathUtil.clamp(-2.0 * (x*z - y*w), -1.0, 1.0) );
	}
	
	public inline function dotProduct(other:Vector4):Float
	{
		return (x * other.x + y * other.y + z * other.z + w * other.w);
	}

	public inline function rotationFromTo(from:Vector3,to:Vector3):Vector4
	{
		// Based on Stan Melax's article in Game Programming Gems
		// Copy, since cannot modify local
		var v0:Vector3 = from.clone();
		var v1:Vector3 = to.clone();
		v0.normalize();
		v1.normalize();

		var d:Float = v0.dotProduct(v1);
		if (d >= 1.0) // If dot == 1, vectors are the same
		{
			makeIdentity();
			v0 = null;
			v1 = null;
			return this;
		}else
		{
			var invs:Float = MathUtil.invSqrt((1+d)*2);
			var c:Vector3 = v0.crossProduct(v1);
			c.scaleBy(invs);

			x = c.x;
			y = c.y;
			z = c.z;
			w = 0.5/invs;
        
			v0 = null;
			v1 = null;
			c = null;
		
			return this;
		}
	}	
}
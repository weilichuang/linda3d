package mini3d.math
{
	public class Vector4D
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		
		public function Vector4D(x:Number=0,y:Number=0,z:Number=0,w:Number=0)
		{
			this.x=x;
			this.y=y;
			this.z=z;
			this.w=w;
		}
		public function copy(other:Vector4D):void
		{
			this.x=other.x;
			this.y=other.y;
			this.z=other.z;
			this.w=other.w;
		}
		public function clone():Vector4D
		{
			return new Vector4D(x,y,z,w);
		}
		public function dotProduct(other:Vector4D):Number
		{
			return (x * other.x + y * other.y + z * other.z + w * other.w);
		}

	}
}
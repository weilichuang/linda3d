package linda.math;

class Vector4 
{
    public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	public function new(?x:Float=0.,?y:Float=0.,?z:Float=0.,?w:Float=0.) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public inline function dotProduct(other:Vector4):Float
	{
		return (x * other.x + y * other.y + z * other.z + w * other.w);
	}
}
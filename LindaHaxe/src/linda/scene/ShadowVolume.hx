package linda.scene;
import linda.math.Vector3;
import flash.Vector;
class ShadowVolume 
{
    public var vertices:Vector<Vector3>;
	public var count:Int;
	public var size:Int;
	public function new() 
	{
		vertices = new Vector<Vector3>();
		count = 0;
		size = 0;
	}
}
package linda.animator;
import linda.math.Vector3;
import linda.scene.SceneNode;

class AnimatorRotation implements IAnimator
{
    public var startTime:Int;
	public var rotation:Vector3;
	public function new(now:Int,rotation:Vector3) 
	{
		this.startTime = now;
		this.rotation = rotation;
	}
	public function animateNode(node:SceneNode, timeMs:Int):Void 
	{
		if (node == null) return;
		
		var diffTime:Int = timeMs - startTime;
		if (diffTime != 0)
		{
			var newRotation:Vector3 = node.getRotation();
			newRotation.incrementBy(rotation.scale(diffTime * 0.1));
			node.setRotation(newRotation);
			startTime = timeMs;
		}
	}
}
package linda.animator
{
	import linda.scene.SceneNode;
	public interface ISceneNodeAnimator
	{
		function animateNode (node : SceneNode, timeMs : Number) : void;
	}
}

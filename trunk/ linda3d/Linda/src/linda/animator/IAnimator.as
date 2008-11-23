package linda.animator
{
	import linda.scene.SceneNode;
	public interface IAnimator
	{
		function animateNode (node : SceneNode, timeMs : Number) : void;
	}
}

package mini3d.animator
{
	import mini3d.scene.SceneNode;
	
	public interface IAnimator
	{
		function animateNode (node : SceneNode, timeMs : Number) : void;
	}
}

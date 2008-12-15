package linda.animator;

	import linda.scene.SceneNode;
	interface IAnimator
	{
		function animateNode (node : SceneNode, timeMs : Int) : Void;
	}

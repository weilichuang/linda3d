package linda.animator;

	import linda.scene.SceneNode;
	interface IAnimator
	{
		function animateNode (node : SceneNode, timeMs : Int) : Void;
		
		/** This is only valid for non-looping animators with a discrete end state.
		 *	@return true if the animator has finished, false if it is still running. 
		 */
		function hasFinished():Bool;
	}

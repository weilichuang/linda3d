package linda.scene
{
	import linda.animator.ISceneNodeAnimator;
	import linda.math.AABBox3D;
	
	import flash.geom.Vector3D;
	//Todo maybe need to add debug mode
	public class BoneSceneNode extends SceneNode
	{
		public var positionHint : int;
		public var scaleHint : int;
		public var rotationHint : int;
		public function BoneSceneNode (mgr:SceneManager,boneIndex : int, boneName : String)
		{
			super (mgr);
			this.boneIndex = boneIndex;
			this.boneName = boneName;
		}
		public function getBoneIndex () : int
		{
			return boneIndex;
		}
		public function setAnimationMode (mode : int) : Boolean
		{
			animationMode = mode;
			return true;
		}
		public function getAnimationMode () : int
		{
			return animationMode;
		}
		override public function getBoundingBox () : AABBox3D
		{
			return box;
		}
		override public function onAnimate (timeMs : int) : void
		{
			if (visible)
			{
				for (var i : int = 0; i < animators.length; i ++)
				{
					var animator : ISceneNodeAnimator = animators [i];
					animator.animateNode (this, timeMs);
				}
				//updateAbsoluteTransformation ();
				for (i = 0; i < children.length; i ++)
				{
					var child : SceneNode = children [i];
					child.onAnimate (timeMs);
				}
			}
		}
		public function helper_updateAbsolutePositionOfAllChildren (node : SceneNode) : void
		{
			node.updateAbsoluteMatrix ();
			for (var i : int = 0; i < node.getChildren ().length; i ++)
			{
				helper_updateAbsolutePositionOfAllChildren (node.getChildAt (i));
			}
		}
		public function updateAbsolutePositionOfAllChildren () : void
		{
			helper_updateAbsolutePositionOfAllChildren (this);
		}
		public function getSkinningSpace () : int
		{
			return skinningSpace;
		}
		public function setSkinningSpace (space : int) : void
		{
			this.skinningSpace = space;
		}
		private var animationMode : int;
		private var skinningSpace : int;
		private var boneIndex : int;
		private var boneName : String;
		private var box : AABBox3D;
	}
}
class BoneAnimationMode
{
	//! The bone is usually animated, unless it's parent is not animated
	public static const AUTOMATIC : int = 0;
	//! The bone is animated by the skin, if it's parent is not animated then animation will resume from this bone onward
	public static const ANIMATED : int = 1;
	//! The bone is not animated by the skin
	public static const UNANIMATED : int = 2;
	//! Not an animation mode, just here to count the available modes
	public static const COUNT : int = 3;
}
class BoneSkiningSpace
{
	//! local skinning, standard
	public static const LOCAL : int = 0;
	//! global skinning
	public static const GLOBAL : int = 1;
	public static const COUNT : int = 2;
}

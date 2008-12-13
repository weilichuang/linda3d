package linda.animator;

	import linda.math.Vector3;
	import linda.math.MathUtil;
	import linda.scene.SceneNode;
	

	class AnimatorFlyCircle implements IAnimator
	{
		public var center:Vector3;
		public var radius:Float;
		public var speed:Float;
		public var time:Int;
		public function new(time:Int,center:Vector3,radius:Float,speed:Float)
		{
			this.time=time;
			this.center=center;
			this.radius=radius;
			this.speed=speed;
		}
		public function animateNode(node:SceneNode, timeMs:Float):Void
		{
			if(node==null) return;
			
			var t:Float=(timeMs-time)*speed*0.001;
			node.x=center.x+radius*MathUtil.cos(t);
			node.z=center.z+radius*MathUtil.sin(t);
		}
	}

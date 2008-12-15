package linda.animator;

	import linda.math.Vector3;
	import linda.math.MathUtil;
	import linda.scene.SceneNode;
	

	class AnimatorFlyCircle implements IAnimator
	{
		public var center:Vector3;
		public var direction:Vector3;
		public var radius:Float;
		public var speed:Float;
		public var time:Int;
		private var vecV:Vector3;
		private var vecU:Vector3;
		public function new(time:Int,center:Vector3,radius:Float,speed:Float,direction:Vector3)
		{
			this.time=time;
			this.center=center;
			this.radius=radius;
			this.speed = speed;
			this.direction = direction;
			init();
		}
		private function init():Void 
		{
			direction.normalize();
			if (direction.y != 0)
			{
				vecV = new Vector3(1, 0, 0).crossProduct(direction);
				vecV.normalize();
			}else
			{
				vecV = new Vector3(0, 1, 0).crossProduct(direction);
				vecV.normalize();
			}
			vecU = vecV.crossProduct(direction);
			vecU.normalize();
		}
		public function animateNode(node:SceneNode, timeMs:Int):Void
		{
			if(node==null) return;
			
			var t:Float=(timeMs-time)*speed;
			node.x = center.x + radius * (MathUtil.cos(t) * vecU.x + MathUtil.sin(t) * vecV.x);
			node.y = center.y + radius * (MathUtil.cos(t) * vecU.y + MathUtil.sin(t) * vecV.y);
			node.z = center.z + radius * (MathUtil.cos(t) * vecU.z + MathUtil.sin(t) * vecV.z);
		}
	}

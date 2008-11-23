package linda.animator
{
	import flash.geom.Vector3D;
	
	import linda.scene.SceneNode;

	public class AnimatorFlyCircle implements IAnimator
	{
		public var center:Vector3D;
		public var radius:Number;
		public var speed:Number;
		public var time:int;
		public function AnimatorFlyCircle(time:int,center:Vector3D,radius:Number,speed:Number)
		{
			this.time=time;
			this.center=center;
			this.radius=radius;
			this.speed=speed;
		}
		public function animateNode(node:SceneNode, timeMs:Number):void
		{
			if(node==null) return;
			
			var t:Number=(timeMs-time)*speed*0.001;
			node.x=center.x+radius*Math.cos(t);
			node.z=center.z+radius*Math.sin(t);
		}
	}
}
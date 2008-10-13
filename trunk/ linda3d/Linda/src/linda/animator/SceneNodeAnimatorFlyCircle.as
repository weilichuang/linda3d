package linda.animator
{
	import flash.geom.Vector3D;
	
	import linda.scene.SceneNode;

	public class SceneNodeAnimatorFlyCircle implements ISceneNodeAnimator
	{
		private var center:Vector3D;
		private var radius:Number;
		private var speed:Number;
		private var time:int;
		public function SceneNodeAnimatorFlyCircle(time:int,center:Vector3D,radius:Number,speed:Number)
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
		public function setCenter(center:Vector3D):void
		{
			this.center=center;
		}
		public function getCenter():Vector3D
		{
			return this.center;
		}
		public function setRadius(radius:Number):void
		{
			this.radius=radius;
		}
		public function getRadius():Number
		{
			return this.radius;
		}
		public function setSpeed(speed:Number):void
		{
			this.speed=speed;
		}
		public function getSpeed():Number
		{
			return this.speed;
		}
		public function setTime(time:Number):void
		{
			this.time=time;
		}
		public function getTime():Number
		{
			return this.time;
		}
		
	}
}
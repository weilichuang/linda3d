package mini3d.animator
{
	import mini3d.math.Vector3D;
	import mini3d.scene.SceneNode;

	public class AnimatorFlyCircle implements IAnimator
	{
		private var center:Vector3D;
		private var radius:Number;
		private var speed:Number;
		private var time:int;
		private var tmpV:Vector3D;
		private var tmpU:Vector3D;
		private var direction:Vector3D;
		public function AnimatorFlyCircle(time:int,center:Vector3D,radius:Number,speed:Number,dir:Vector3D)
		{
			this.time=time;
			this.center=center;
			this.radius=radius;
			this.speed=speed;
			
			this.direction=dir;
			
			direction.normalize();

			if (direction.y != 0)
			{
				tmpV = new Vector3D(50,0,0).crossProduct(direction);
			}	
			else
			{
				tmpV = new Vector3D(0,50,0).crossProduct(direction);
			}	
			tmpV.normalize();
			tmpU = tmpV.crossProduct(direction);
			tmpU.normalize();
		}
		public function animateNode(node:SceneNode, timeMs:Number):void
		{
			if(node==null) return;
			
			var t:Number=(timeMs-time)*speed*0.001;
			
			var cos:Number=Math.cos(t);
			var sin:Number=Math.sin(t);

			node.x=center.x+radius*(tmpU.x*cos+tmpV.x*sin);
			node.y=center.y+radius*(tmpU.y*cos+tmpV.y*sin);
			node.z=center.z+radius*(tmpU.z*cos+tmpV.z*sin);
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
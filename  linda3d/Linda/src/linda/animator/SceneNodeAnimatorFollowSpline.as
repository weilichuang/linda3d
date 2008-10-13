package linda.animator
{
	import flash.geom.Vector3D;
	
	import linda.math.MathUtil;
	import linda.scene.SceneNode;
	
	public class SceneNodeAnimatorFollowSpline implements ISceneNodeAnimator
	{
		private var points:Array;
		private var speed:Number;
		private var tightness:Number;
		private var startTime:int;
		public function SceneNodeAnimatorFollowSpline(time:int,points:Array,speed:Number,tightness:Number)
		{
			this.points=points;
			this.speed=speed;
			this.tightness=tightness;
			this.startTime=time;
			
		}
		public function animateNode(node:SceneNode, timeMs:Number):void
		{
			if(!points || !node) return;
			var size:int=points.length;
			if(size==0) return;
			if(size==1)
			{
				node.setPosition(points[0]);
				return;
			} 
			
			var dt:Number=(timeMs-startTime)*speed*0.001;
			var u:Number= dt - Math.floor(dt);
			var idx:int= Math.floor(dt)%size;
			
			var p0:Vector3D=points[MathUtil.clamp(idx-1,size)];
			var p1:Vector3D=points[MathUtil.clamp(idx+0,size)];
			var p2:Vector3D=points[MathUtil.clamp(idx+1,size)];
			var p3:Vector3D=points[MathUtil.clamp(idx+2,size)];
			
			// hermite polynomials
			// hermite polynomials
			var h1:Number = 2.0 * u * u * u - 3.0 * u * u + 1.0;
			var h2:Number = -2.0 * u * u * u + 3.0 * u * u;
			var h3:Number = u * u * u - 2.0 * u * u + u;
			var h4:Number = u * u * u - u * u;

			// tangents
			var t1:Vector3D = ( p2.subtract(p0) ).scale(tightness);
			var t2:Vector3D = ( p3.subtract(p1) ).scale(tightness);

			// interpolated point
			var p:Vector3D=p1.scale(h1).add(p2.scale(h2).add(t1.scale(h3).add(t2.scale(h4))));
			node.setPosition(p);
		}

	}
}
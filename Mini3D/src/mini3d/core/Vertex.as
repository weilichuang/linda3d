package mini3d.core
{
	import mini3d.math.Vector3D;
	
	public class Vertex
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public var u:Number;
		public var v:Number;

		public function Vertex(x:Number=0,y:Number=0,z:Number=0,u:Number=0,v:Number=0)
		{
			this.x=x;
			this.y=y;
			this.z=z;
			
			this.u=u;
			this.v=v;
		}
		
		public function get position():Vector3D
		{
			return new Vector3D(x,y,z);
		}
		
		public function set position(v:Vector3D):void
		{
			x=v.x;
			y=v.y;
			z=v.z;
		}
		
		public function copy(v:Vertex):void
		{
			this.x=v.x;
			this.y=v.y;
			this.z=v.z;
			this.u=v.u;
			this.v=v.v;
		}
		
		public function clone():Vertex
		{
			return new Vertex(x,y,z,u,v);
		}
		

	}
}
package mini3d.core
{
	public class Vertex4D
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		
		public var u:Number;
		public var v:Number;

		public function Vertex4D(x:Number=0,y:Number=0,z:Number=0,w:Number=1,u:Number=0,v:Number=0)
		{
			this.x=x;
			this.y=y;
			this.z=z;
			this.w=w;
			
			this.u=u;
			this.v=v;
		}
		public function copy(other:Vertex4D):void
		{
			x=other.x;
			y=other.y;
			z=other.z;
			w=other.w;
			
			u=other.u;
			v=other.v;
		}

	}
}
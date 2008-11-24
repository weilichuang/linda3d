package linda.math
{
	public class Vertex4D
	{
		//position
		public var x : Number ;
		public var y : Number ;
		public var z : Number ;
		public var w : Number ;
		//color
		public var r : int ;
		public var g : int ;
		public var b : int ;
		//uv
		public var u : Number ;
		public var v : Number ;
		public function Vertex4D ()
		{
			x=0;
			y=0;
			z=0;
			w=0;
			
			u=0;
			v=0;
			
			r=0;
			g=0;
			b=0;
		}
		public function copy (c : Vertex4D) : void
		{
			x = c.x;
			y = c.y;
			z = c.z;
			r = c.r;
			g = c.g;
			b = c.b;
			u = c.u;
			v = c.v;
		}
	}
}

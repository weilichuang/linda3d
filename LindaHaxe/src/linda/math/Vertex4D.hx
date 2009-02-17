package linda.math;

	class Vertex4D
	{
		//position
		public var x : Float ;
		public var y : Float ;
		public var z : Float ;
		public var w : Float ;
		//color
		public var r : Int ;
		public var g : Int ;
		public var b : Int ;
		//uv
		public var u : Float ;
		public var v : Float ;
		
		public function new ()
		{
			x = 0.;
			y = 0.;
			z = 0.;
			w = 0.;
			
			u = 0.;
			v = 0.;
			
			r = 0;
			g = 0;
			b = 0;
		}
		public inline function copy (c : Vertex4D) : Void
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
		
		public inline function interpolate(v0:Vertex4D, v1:Vertex4D, t:Float,?useUV:Bool=true):Void 
		{
			x = v1.x + (v0.x - v1.x) * t ;
			y = v1.y + (v0.y - v1.y) * t ;
			z = v1.z + (v0.z - v1.z) * t ;
			w = v1.w + (v0.w - v1.w) * t ;
			r = Std.int(v1.r + (v0.r - v1.r) * t) ;
			g = Std.int(v1.g + (v0.g - v1.g) * t) ;
			b = Std.int(v1.b + (v0.b - v1.b) * t) ;
			if (useUV)
			{
			   u = v1.u + (v0.u - v1.u) * t ;
			   v = v1.v + (v0.v - v1.v) * t ;
			}
		}
	}

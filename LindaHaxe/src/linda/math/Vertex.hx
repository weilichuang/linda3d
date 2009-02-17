package linda.math;
import flash.geom.Point;

	class Vertex
	{
		//position
		public var x : Float;
		public var y : Float;
		public var z : Float;
		//normal
		public var nx : Float;
		public var ny : Float;
		public var nz : Float;
		//color
		public var r : Int;
		public var g : Int;
		public var b : Int;
		//uv
		public var u : Float;
		public var v : Float;
		
		public inline var color(getColor, setColor):UInt;
		public inline var position(getPosition, setPosition):Vector3;
		public inline var normal(getNormal, setNormal):Vector3;
		public inline var uv(getUV, setUV):Point;

		public function new (?x : Float = 0., ?y : Float = 0., ?z : Float = 0., ?nx : Float = 0., ?ny : Float = 0., ?nz : Float = 0., ?c : UInt = 0xFFFFFF, ?u : Float = 0., ?v : Float = 0.)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.nx = nx;
			this.ny = ny;
			this.nz = nz;
			this.u = u;
			this.v = v;
			
			setColor(c);
		}
		public inline function getPosition () : Vector3
		{
			return new Vector3(x,y,z);
		}
		public inline function setPosition (v : Vector3) : Vector3
		{
			x = v.x;
			y = v.y;
			z = v.z;
			return v;
		}
		public inline function getNormal () : Vector3
		{
			return new Vector3(nx,ny,nz);
		}
		public inline function setNormal (v : Vector3) : Vector3
		{
			nx = v.x;
			ny = v.y;
			nz = v.z;
			return v;
		}
		public inline function getUV () : Point
		{
			return new Point(u,v);
		}
		public inline function setUV (tc : Point) : Point
		{
			u = tc.x;
			v = tc.y;
			return tc;
		}
		public inline function getColor () : UInt
		{
			return (r << 16 | g << 8 | b);
		}
		public inline function setColor (c : UInt) : UInt
		{
			r = (c >> 16) & 0xFF;
			g = (c >> 8) & 0xFF;
			b = c & 0xFF;
			return c;
		}
		public inline function clone () : Vertex
		{
			var vertex : Vertex = new Vertex ();
			vertex.x = x;
			vertex.y = y;
			vertex.z = z;
			vertex.nx = nx;
			vertex.ny = ny;
			vertex.nz = nz;
			vertex.r = r;
			vertex.g = g;
			vertex.b = b;
			vertex.u = u;
			vertex.v = v;
			return vertex;
		}
		public inline function normalize () : Void
		{
			var sq:Float = nx * nx + ny * ny + nz * nz;
			if ( sq < MathUtil.ROUNDING_ERROR ) sq = 0 else sq = MathUtil.invSqrt(sq);
			nx *= sq;
			ny *= sq;
			nz *= sq;
		}
		public inline function copy (c : Vertex) : Void
		{
			x = c.x;
			y = c.y;
			z = c.z;
			nx = c.nx;
			ny = c.ny;
			nz = c.nz;
			r = c.r;
			g = c.g;
			b = c.b;
			u = c.u;
			v = c.v;
		}
		public function toString () : String
		{
			return "[Vertex(" + x + ',' + y + ',' + z + ',r=' + r + ',g=' + g + ',b=' + b + ',u=' + u + ',v=' + v + ')]';
		}
		public inline function equals (other : Vertex) : Bool
		{
			return (x == other.x && y == other.y && z == other.z && u == other.u && v == other.v);
		}
	}

package linda.math
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	public class Vertex
	{
		//position
		public var x : Number;
		public var y : Number;
		public var z : Number;
		//normal
		public var nx : Number;
		public var ny : Number;
		public var nz : Number;
		//color
		public var r : int;
		public var g : int;
		public var b : int;
		//uv
		public var u : Number;
		public var v : Number;
		public function Vertex (x : Number = 0, y : Number = 0, z : Number = 0, nx : Number = 0, ny : Number = 0, nz : Number = 0, c : uint = 0xFFFFFF, u : Number = 0, v : Number = 0)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.nx = nx;
			this.ny = ny;
			this.nz = nz;
			this.color = c;
			this.u = u;
			this.v = v;
		}
		public function get position () : Vector3D
		{
			return new Vector3D(x,y,z);
		}
		public function set position (v : Vector3D) : void
		{
			x = v.x;
			y = v.y;
			z = v.z;
		}
		public function get normal () : Vector3D
		{
			return new Vector3D(nx,ny,nz);
		}
		public function set normal (v : Vector3D) : void
		{
			nx = v.x;
			ny = v.y;
			nz = v.z;
		}
		public function get uv () : Point
		{
			return new Point(u,v);
		}
		public function set uv (tx : Point) : void
		{
			u = tx.x;
			v = tx.y;
		}
		public function get color () : uint
		{
			return ((r << 16) | (g << 8) | b);
		}
		public function set color (c : uint) : void
		{
			r = (c >> 16) & 0xFF;
			g = (c >> 8) & 0xFF;
			b = (c) & 0xFF;
		}
		public function clone () : Vertex
		{
			var vertex : Vertex = new Vertex ();
			vertex.x = x;
			vertex.y = y;
			vertex.z = z;
			vertex.nx = nx;
			vertex.ny = ny;
			vertex.nz = nz;
			vertex.color = color;
			vertex.u = u;
			vertex.v = v;
			return vertex;
		}
		public function normalize () : void
		{
			var n : Number = Math.sqrt (nx * nx + ny * ny + nz * nz);
			n = (n < 0.0001) ? 0 : 1/n;
			nx *= n;
			ny *= n;
			nz *= n;
		}
		public function copy (c : Vertex) : void
		{
			x = c.x;
			y = c.y;
			z = c.z;
			nx = c.nx;
			ny = c.ny;
			nz = c.nz;
			color = c.color;
			u = c.u;
			v = c.v;
		}
		public function toString () : String
		{
			return "[ x=" + x + ',y=' + y + ',z=' + z + ',r=' + r + ',g=' + g + ',b=' + b + ',u=' + u + ',v=' + v + ' ]';
		}
		public function equals (other : Vertex) : Boolean
		{
			return (x == other.x && y == other.y && z == other.z && u == other.u && v == other.v);
		}
	}
}

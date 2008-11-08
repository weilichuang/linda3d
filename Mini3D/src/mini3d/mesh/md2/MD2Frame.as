package mini3d.mesh.md2
{
	public class MD2Frame
	{
		public var name : String;
		public var begin : int;
		public var end : int;
		public var fps : int;
		public function MD2Frame (begin:int=0,end:int=1,fps:int=1)
		{
			this.begin=begin;
			this.end=end;
			this.fps=fps;
			name="";
		}
	}
}

package linda.mesh.md2;

class MD2Frame
{
	public var name  : String;
	public var begin : Int;
	public var end   : Int;
	public var fps   : Int;
	public function new (?begin:Int=0,?end:Int=1,?fps:Int=1)
	{
			this.begin=begin;
			this.end=end;
			this.fps=fps;
			name="";
	}
}

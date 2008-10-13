package linda.math
{
	import flash.geom.Matrix;
	
	import linda.material.Material;
	public class Face3D
	{
		public var v0:Vertex4D;
		public var v1:Vertex4D;
		public var v2:Vertex4D;
		
		public var material:Material;
		
		public var matrix:Matrix;
		public function Face3D()
		{
			v0=new Vertex4D();
			v1=new Vertex4D();
			v2=new Vertex4D();
			
			material=new Material();
			
			matrix=new Matrix();
		}

	}
}
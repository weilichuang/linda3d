package linda.video.vector
{
	import flash.geom.Matrix;
	
	import linda.material.Material;
	import linda.math.Vertex4D;
	
	public class Face3D
	{
		public var point0:Vertex4D;
		public var point1:Vertex4D;
		public var point2:Vertex4D;
		
		public var material:Material;

		public var matrix:Matrix;
		
		public var z:Number;

		public function Face3D()
		{
			point0=new Vertex4D();
			point1=new Vertex4D();
			point2=new Vertex4D();
			
			matrix=new Matrix();

			z=-1000;
		}

	}
}
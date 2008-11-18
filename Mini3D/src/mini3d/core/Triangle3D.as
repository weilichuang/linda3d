package mini3d.core
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class Triangle3D
	{
		public var p0:Vertex4D;
		public var p1:Vertex4D;
		public var p2:Vertex4D;
		
		public var material:Material;

		public var matrix:Matrix;

		public var z:Number;

		public var bitmapData:BitmapData;
		
		//该三角形将绘制在target里
		public var target:Sprite;
		
		public function Triangle3D()
		{
			p0=new Vertex4D();
			p1=new Vertex4D();
			p2=new Vertex4D();
			
			matrix=new Matrix();

			z=0;
		}

	}
}
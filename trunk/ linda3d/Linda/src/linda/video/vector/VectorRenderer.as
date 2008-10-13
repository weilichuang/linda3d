package linda.video.vector
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	
	import linda.material.Material;
	import linda.math.*;

	internal class VectorRenderer implements IVectorRenderer
	{
		protected var target:Graphics;
		protected var rect:Rectangle=new Rectangle(0,0,1,1);
		protected var vt0:Vertex4D,vt1:Vertex4D,vt2:Vertex4D;
		protected var material:Material;
		
		protected var mipMapDistance:Number;
		protected var perspectiveCorrectDistance:Number;

		public function VectorRenderer()
		{
		}

		public function setRenderTarget(target:Graphics):void
		{
			this.target = target;
		}
		
		public function setMaterial(material:Material):void
		{
			this.material = material;
		}
		
		public function drawIndexedTriangleList (triangles:Vector.<Face3D>, triangleCount : int) : void
		{
		}
		public function setPerspectiveCorrectDistance(distance:Number=400):void
		{
			perspectiveCorrectDistance=distance;
		}
		public function setMipMapDistance(distance:Number=800):void
		{
			mipMapDistance=distance;
		}
		
	}
}
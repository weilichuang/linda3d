package linda.video
{
	import flash.display.BitmapData;
	
	import __AS3__.vec.Vector;
	
	import linda.math.Vertex4D;
	
	import linda.material.Material;
	public interface ITriangleRenderer
	{
		function setRenderTarget (target : Vector.<uint>, buffer : Vector.<Number>,height:int) : void;
		function setMaterial (material : Material) : void;
		function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void;
		function drawIndexedLineList (vertices :Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void;
		function setPerspectiveCorrectDistance(distance:Number=400):void;
		function setMipMapDistance(distance:Number=500):void;
	}
}

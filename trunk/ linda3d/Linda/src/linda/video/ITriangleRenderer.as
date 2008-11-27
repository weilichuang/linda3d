package linda.video
{
	import __AS3__.vec.Vector;
	
	import linda.math.Vertex4D;
	
	import linda.material.Material;
	public interface ITriangleRenderer
	{
		function setVector (target : Vector.<uint>, buffer : Vector.<Number>) : void;
		function setHeight(height:int):void;
		function setMaterial (material : Material) : void;
		function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void;
		function drawIndexedLineList (vertices :Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void;
		function setPerspectiveCorrectDistance(distance:Number=400):void;
		function setMipMapDistance(distance:Number=500):void;
	}
}

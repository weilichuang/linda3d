package linda.video.vector
{
	import __AS3__.vec.Vector;
	
	import linda.material.Material;
	import linda.math.Face3D;
	
	import flash.display.*;
	
	internal interface IVectorRenderer
	{
		function setRenderTarget (target : Graphics) : void;
		function setMaterial (material : Material) : void;
		function drawIndexedTriangleList (triangles:Vector.<Face3D>, triangleCount : int) : void;
		function setPerspectiveCorrectDistance(distance:Number=400):void;
		function setMipMapDistance(distance:Number=800):void;
	}
}
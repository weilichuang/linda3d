package mini3d.render
{
	import flash.display.Sprite;
	
	import mini3d.core.Material;
	
	public interface ITriangleRender
	{
		function drawTriangleList(triangles:Array,triangleCount:int):void;
	}
}
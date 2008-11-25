package linda.material
{
	import flash.display.BitmapData;
	
	import linda.math.Dimension2D;
	
	public interface ITexture
	{
		function hasMipMaps():Boolean;
		function getMipMapCount():int;//没有则返回0
		function generateMipMaps(level:int=16):void;
		function getBitmapData(i:int=-1):BitmapData;
	}
}
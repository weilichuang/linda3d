package linda.material
{
	import flash.display.BitmapData;
	
	import linda.math.Dimension2D;
	
	public interface ITexture
	{
		function getSize():Dimension2D;
		function hasMipMaps():Boolean;
		function getMipMapCount():int;//没有则返回0
		function regenerateMipMapLevels(mipMapLevel:int=16):void;
		function getBitmapData(i:int=-1):BitmapData;
		function get width():int;//最大图片的宽度
		function get height():int;//最大图片的高度
		function set name(n:String):void;
		function get name():String;
	}
}
package mini3d.texture
{
	import flash.display.BitmapData;
	
	public interface ITexture
	{
		function get bitmapData():BitmapData;
		function set bitmapData(value:BitmapData):void;
	}
}
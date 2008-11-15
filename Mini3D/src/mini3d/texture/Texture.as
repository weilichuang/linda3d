package mini3d.texture
{
	import flash.display.BitmapData;
	//Todo Texture部分要重新设计
	public class Texture implements ITexture
	{
		private var _bitmapData:BitmapData;
		public function Texture(bitmapData:BitmapData = null)
		{
			_bitmapData=bitmapData;
		}
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		public function setBitmapData(value:BitmapData):void
		{
			_bitmapData=value;
		}
	}
}
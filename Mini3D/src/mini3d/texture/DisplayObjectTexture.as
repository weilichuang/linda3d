package mini3d.texture
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	public class DisplayObjectTexture implements ITexture
	{
		private var displayObject:DisplayObject;
		private var _bitmapData:BitmapData;
		public function DisplayObjectTexture(value:DisplayObject=null)
		{
			setDisplayObject(value);
		}
		public function setDisplayObject(value:DisplayObject):void
		{
			displayObject=value;
			if(displayObject==null)
			{
				_bitmapData=null;
			}else
			{
				_bitmapData=new BitmapData(value.width,value.height,true,0x0);
				_bitmapData.draw(displayObject);
			}
		}
		public function set bitmapData(value:BitmapData):void
		{
			
		}
		public function getDisplayObject():DisplayObject
		{
			return displayObject;
		}

		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
	}
}
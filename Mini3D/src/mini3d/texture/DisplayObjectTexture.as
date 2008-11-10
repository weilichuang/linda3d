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
			if(displayObject)
			{
				if(_bitmapData)
				{
					_bitmapData.fillRect(displayObject.getRect(displayObject),0);
				}else
				{
					_bitmapData=new BitmapData(displayObject.width,displayObject.height,true,0x0);
				}
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
			if(displayObject == null) return null;
			return _bitmapData;
		}
	}
}
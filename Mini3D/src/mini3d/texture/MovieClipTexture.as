package mini3d.texture
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;

	public class MovieClipTexture implements ITexture
	{
		private var _mc:MovieClip;
		public function MovieClipTexture(mc:MovieClip=null)
		{
			_mc=mc;
		}
		public function setMovieClip(mc:MovieClip):void
		{
			_mc=mc;
		}
		public function set bitmapData(value:BitmapData):void
		{
			
		}
		public function getMovieClip():MovieClip
		{
			return _mc;
		}
		public function play():void
		{
			_mc.play();
		}
		public function stop():void
		{
			_mc.stop();
		}
		public function get bitmapData():BitmapData
		{
			if(_mc==null) return null;
			var _bitmapData:BitmapData=new BitmapData(_mc.width,_mc.height,true,0x0);
			_bitmapData.draw(_mc);
			return _bitmapData;
		}
	}
}
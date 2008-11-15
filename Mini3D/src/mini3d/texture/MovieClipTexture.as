package mini3d.texture
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;

	public class MovieClipTexture implements ITexture
	{
		private var _mc:MovieClip;
		private var _bitmapData:BitmapData;
		public function MovieClipTexture(mc:MovieClip=null)
		{
			setMovieClip(mc);
		}
		public function setMovieClip(mc:MovieClip):void
		{
			_mc=mc;
		}
		public function getMovieClip():MovieClip
		{
			return _mc;
		}
		public function get bitmapData():BitmapData
		{
			if(_mc==null) return null;
			if(_bitmapData)
			{
				_bitmapData.fillRect(_mc.getRect(_mc),0x0);
			}else
			{
				_bitmapData=new BitmapData(_mc.width,_mc.height,true,0x0);
			}
			_bitmapData.draw(_mc);
			return _bitmapData;
		}
	}
}
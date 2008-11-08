package mini3d.texture
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;

    //适用于需要多个物体共用的情况下。比如多个需要loading条的物体
    //注意：不要使用太多帧的MovieClip,否则会影响效能
	public class MovieClipCacheTexture implements ITexture
	{
		private var _mc:MovieClip;
		private var _caches:Array;
		public function MovieClipCacheTexture(mc:MovieClip=null)
		{
			_caches=new Array();
			this.setMovieClip(mc);
		}
		public function setMovieClip(mc:MovieClip):void
		{
			if(mc)
			{
				_mc=mc;
				clear();	
				var nums:int=_mc.totalFrames;
				var width:Number=_mc.width;
				var height:Number=_mc.height;
				for(var i:int=1;i<=nums;i++)
				{
					_mc.gotoAndStop(i);
					var _bitmapData:BitmapData=new BitmapData(width,height,true,0x0);
			        _bitmapData.draw(_mc);
			        _caches.push(_bitmapData);
				}
			}
			
		}
		public function set bitmapData(value:BitmapData):void
		{
			
		}
		public function clear():void
		{
			if(_caches!=null)
			{
				for(var i:int=0;i<_caches.length;i++)
				{
					var data:BitmapData=_caches[i];
					data.dispose();
				}
			}
			_caches=new Array();
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
		public function gotoAndStop(i:int):void
		{
			_mc.gotoAndStop(i);
		}
		public function get bitmapData():BitmapData
		{
			if(_mc==null) return null;
			var _bitmapData:BitmapData=_caches[_mc.currentFrame-1];
			return _bitmapData;
		}
	}
}
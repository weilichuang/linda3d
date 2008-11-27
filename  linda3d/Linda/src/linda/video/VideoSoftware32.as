package linda.video
{
	import flash.display.*;
	import flash.geom.*;
	
	import linda.math.*;
	import linda.video.pixel.*;
	public class VideoSoftware32 extends VideoSoftware
	{
		public function VideoSoftware32(size:Dimension2D)
		{
			super(size);
			
			target.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0x0);
			
			renderers [TRType.WIRE] = new TRWire32 ();
			renderers [TRType.FLAT_ALPHA] = new TRFlatAlpha32 ();
			renderers [TRType.GOURAUD_ALPHA] = new TRGouraudAlpha32 ();
			renderers [TRType.TEXTURE_FLAT_ALPHA] = new TRTextureFlatAlpha32 ();
			renderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha32 ();
		}
		override public function setScreenSize (size : Dimension2D) : void
		{
			if(!size)
            {
            	throw new Error("需要设置显示范围");
	            return;
            }
            
			screenSize = size;
			
			rect=screenSize.toRect();
			
			if(target.bitmapData)
			{
				target.bitmapData.fillRect(rect,0x0);
			}else
			{
				target.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0);
			}
			
			_clip_scale.buildNDCToDCMatrix(screenSize,1);
			
			var len:int=screenSize.width*screenSize.height;
			targetVector.length=len;
			bufferVector.length=len;
		}
		override public function getDriverType () : String
		{
			return VideoType.PIXEL32;
		}
	}
}
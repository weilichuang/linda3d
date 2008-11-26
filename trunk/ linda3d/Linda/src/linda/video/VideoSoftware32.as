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
			
			targetBitmap.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0x0);
			
			triangleRenderers [TRType.WIRE] = new TRWire32 ();
			triangleRenderers [TRType.FLAT] = new TRFlat ();
			triangleRenderers [TRType.GOURAUD] = new TRGouraud ();
			triangleRenderers [TRType.TEXTURE_FLAT] = new TRTextureFlat ();
			triangleRenderers [TRType.TEXTURE_GOURAUD] = new TRTextureGouraud ();
			triangleRenderers [TRType.FLAT_ALPHA] = new TRFlatAlpha32 ();
			triangleRenderers [TRType.GOURAUD_ALPHA] = new TRGouraudAlpha32 ();
			triangleRenderers [TRType.TEXTURE_FLAT_ALPHA] = new TRTextureFlatAlpha32 ();
			triangleRenderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha32 ();
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
			
			if(targetBitmap.bitmapData)
			{
				targetBitmap.bitmapData.fillRect(screenSize.toRect(),0x0);
			}else
			{
				targetBitmap.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0);
			}
			
			_clip_scale.buildNDCToDCMatrix(screenSize,1);
			
			var len:int=int(screenSize.width)*int(screenSize.height);
			targetVector.length=len;
			bufferVector.length=len;
		}
		override public function getDriverType () : String
		{
			return VideoType.PIXEL32;
		}
	}
}
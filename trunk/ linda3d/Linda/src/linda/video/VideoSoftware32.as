package linda.video
{
	import flash.display.*;
	import flash.geom.*;
	
	import linda.math.*;
	import linda.video.pixel32.*;
	public class VideoSoftware32 extends VideoSoftware
	{
		public function VideoSoftware32(size:Dimension2D)
		{
			super(size);
			
			targetBitmap.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0x0);
			
			triangleRenderers [TRType.WIRE] = new TRWire ();
			triangleRenderers [TRType.FLAT] = new TRFlat ();
			triangleRenderers [TRType.GOURAUD] = new TRGouraud ();
			triangleRenderers [TRType.TEXTURE_FLAT] = new TRTextureFlat ();
			triangleRenderers [TRType.TEXTURE_GOURAUD] = new TRTextureGouraud ();
			triangleRenderers [TRType.FLAT_ALPHA] = new TRFlatAlpha ();
			triangleRenderers [TRType.GOURAUD_ALPHA] = new TRGouraudAlpha ();
			triangleRenderers [TRType.TEXTURE_FLAT_ALPHA] = new TRTextureFlatAlpha ();
			triangleRenderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha ();
		}
		override public function setScreenSize (size : Dimension2D) : void
		{
			if(!size) return;
			if (size.width >= 1 && size.height >= 1)
			{
				screenSize = size;
				if(targetBitmap.bitmapData)
				{
					targetBitmap.bitmapData.fillRect(screenSize.toRect(),0x0);
				}else
				{
					targetBitmap.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0);
				}
				buffer.fillRect(screenSize.toRect(),0xffffff);
				_clip_scale.buildNDCToDCMatrix(screenSize,1);
			}
		}
	}
}
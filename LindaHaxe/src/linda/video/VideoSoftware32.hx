﻿package linda.video;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import flash.geom.Rectangle;
	
	import linda.math.Dimension2D;
	import linda.math.Matrix4;
	import linda.video.pixel32.TRFlatAlpha32;
	import linda.video.pixel32.TRGouraudAlpha32;
	import linda.video.pixel32.TRTextureFlatAlpha32;
	import linda.video.pixel32.TRTextureGouraudAlpha32;
	import linda.video.pixel32.TRWire32;
	import linda.video.pixel32.TRFlat32;
	import linda.video.pixel32.TRGouraud32;
	import linda.video.pixel32.TRTextureFlat32;
	import linda.video.pixel32.TRTextureGouraud32;
	/**
	 * 用于需要背景透明的时候，如果不需要背景透明，强烈建议使用VideoSoftware,那个会快许多。
	 */
	class VideoSoftware32 extends VideoSoftware
	{
		public function new(size:Dimension2D)
		{
			super(size);
			
			target.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0x0);
			
			renderers [TRType.WIRE]                  = new TRWire32 ();
			renderers [TRType.FLAT]                  = new TRFlat32 ();
			renderers [TRType.GOURAUD]               = new TRGouraud32 ();
			renderers [TRType.TEXTURE_FLAT]          = new TRTextureFlat32 ();
			renderers [TRType.TEXTURE_GOURAUD]       = new TRTextureGouraud32 ();
			renderers [TRType.FLAT_ALPHA]            = new TRFlatAlpha32 ();
			renderers [TRType.GOURAUD_ALPHA]         = new TRGouraudAlpha32 ();
			renderers [TRType.TEXTURE_FLAT_ALPHA]    = new TRTextureFlatAlpha32 ();
			renderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha32 ();
			
			setVector(targetVector,bufferVector);

			setScreenSize(size);
		}
		override public function setScreenSize (size : Dimension2D) : Void
		{
			if(size==null)
            {
            	size=new Dimension2D(300,300);
            }
            
			screenSize = size;
			
			rect=screenSize.toRect();
			
			if(target.bitmapData!=null)
			{
				target.bitmapData.fillRect(rect,0x0);
			}else
			{
				target.bitmapData = new BitmapData (screenSize.width, screenSize.height, true, 0);
			}
			
			_scaleMatrix.buildNDCToDCMatrix(screenSize,1);
			
			var len:Int=screenSize.width*screenSize.height;
			targetVector.length=len;
			bufferVector.length=len;
			
			setHeight(screenSize.height);
		}
		override public function getDriverType () : String
		{
			return VideoType.PIXEL32;
		}
	}
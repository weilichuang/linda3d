package linda.material
{
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	
	import flash.geom.Matrix;
	
	import linda.math.Dimension2D;
	public class Texture implements ITexture
	{	
		private var _name : String;

		private var source:BitmapData;
		private var mipMap : Vector.<BitmapData>;
		private static var _id:int=0;
		
		public function Texture (image : BitmapData=null)
		{
			mipMap= new Vector.<BitmapData> ();
			name='texture'+(_id++);
			source =new BitmapData(128,128,true,0xffffffff);
	
			setImage(image);
		}
		private function getOptimalSize (size : int) : int
		{
			var ts : int = 0x01;
			while (ts < size)
			{
				ts <<= 1;
			}
			return ts;
		}
		private function copyToSize (sou : BitmapData, newWidth : int, newHeight : int) : BitmapData
		{
			var out : BitmapData;

			out = new BitmapData (newWidth, newHeight, false, 0x000000);
			// scale image
			var matrix : Matrix = new Matrix (newWidth / sou.width, 0, 0, newHeight / sou.height, 0, 0)
			out.draw (sou, matrix, null, null, null, true);
			return out;
		}
		public function scale (newWidth : int, newHeight : int) : void
		{
			if (source == null) return;

			var w : int = getOptimalSize (newWidth);
			var h : int = getOptimalSize (newHeight);
			
			if (w < 1 || h < 1) return;

			var new_img : BitmapData = copyToSize (source, w, h);
			setImage (new_img);
		}
		public function get width () : int
		{
			return source.width;
		}
		public function get height () : int
		{
			return source.height;
		}
		public function getSize():Dimension2D
		{
			return new Dimension2D(source.width,source.height);
		}
		
		public function setImage (image : BitmapData) : void
		{
			if (image == null)
			{				
				return;
			} 

			clearMipMapLevels ();

			var orig_width : int = image.width;
			var orig_height : int = image.height;
			var opt_width : int = getOptimalSize (orig_width);
			var opt_height : int = getOptimalSize (orig_height);
			
			if(source) source.dispose();
			
			if ((orig_width == opt_width) && (orig_height == opt_height))
			{
				source = image;
			} 
			else
			{
				source = copyToSize (image, opt_width, opt_height);
			}
		}
		
		public function getBitmapData (mipLevel : int=-1) : BitmapData
		{
			if (mipLevel <= 0 || mipMap.length == 0)
			{
				return source;
			}
			if (mipLevel >= mipMap.length)
			{
				return mipMap [mipMap.length-1];
			}
			return mipMap [mipLevel-1];
		}
		public function getMipMapCount () : int
		{
			return mipMap.length;
		}
		/**
		 * mipMapLevel 最小等级图片的大小
		 */
		public function regenerateMipMapLevels (mipMapLevel:int=16) : void
		{
			clearMipMapLevels ();
			var width : int = source.width;
			var count:int=0;
			for (var i : int = (width >> 1); i >= mipMapLevel; (i >>= 1))
			{
				mipMap [count] = copyToSize (source, i, i);
				count++;
			}
		}
		public function hasMipMaps():Boolean
		{
			return mipMap.length >= 1;
		}
		public function clearMipMapLevels () : void
		{
			var mip_count:int=mipMap.length;
			for (var i : int = 0; i < mip_count; i ++)
			{
				var tx1 : BitmapData = mipMap [i];
				tx1.dispose ();
			}
			mipMap=new Vector.<BitmapData>();
		}
		
		public function toString():String
		{
			return _name;
		}
		public function set name(n:String):void
		{
			_name=n;
		}
		public function get name():String
		{
			return _name;
		}
	}
}

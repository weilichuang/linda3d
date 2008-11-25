package linda.material
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.Matrix;
	public class Texture implements ITexture
	{	
		public var name : String;
		private var source:BitmapData=new BitmapData(1,1,true,0xffffffff);;
		private var mipMap : Vector.<BitmapData>;
		private var mipMapCount:int;
		public function Texture (image : BitmapData=null)
		{
			mipMap= new Vector.<BitmapData> ();
			mipMapCount=0;
			name="";
			setImage(image);
		}
		/**
		 * 对source执行缩放
		 */
		private function scale (value:Number):BitmapData
		{
			var data:BitmapData=new BitmapData(source.width*value,source.height*value,source.transparent,0x0);
			var matrix:Matrix=new Matrix();
			matrix.a=value;
			matrix.d=value;
			data.draw(source,matrix);
            return data;
		}
		public function setImage (image : BitmapData) : void
		{
			if (image == null) return;
			if(source)
			{
				clearMipMaps ();
				source.dispose();
			} 
			source=image;
		}
		public function getBitmapData (level : int=-1) : BitmapData
		{
			if (level <= 0 || mipMapCount == 0)
			{
				return source;
			}
			if (level >= mipMapCount)
			{
				return mipMap [mipMapCount-1];
			}
			return mipMap [level-1];
		}
		public function getMipMapCount () : int
		{
			return mipMapCount;
		}
		/**
		 * level 最小等级图片的大小
		 */
		public function generateMipMaps (level:int=16) : void
		{
			clearMipMaps ();
			var min:int=int(Math.min(source.width,source.height));
			for (var i : int = int(min >> 1); i >= level; (i >>= 1))
			{
				mipMap [mipMapCount] = scale(1/Math.pow(2,(mipMapCount+1)));
				mipMapCount++;
			}
		}
		public function hasMipMaps():Boolean
		{
			return mipMapCount >= 1;
		}
		public function clearMipMaps () : void
		{	
			for (var i : int = 0; i < mipMapCount; i+=1)
			{
				var tx : BitmapData = mipMap[i];
				tx.dispose ();
				tx=null;
			}
			mipMap=new Vector.<BitmapData>();
			mipMapCount=0;
		}
		
		public function toString():String
		{
			return name;
		}
	}
}

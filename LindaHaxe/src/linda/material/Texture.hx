package linda.material;

	import flash.Vector;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	class Texture implements ITexture
	{	
		public var name : String;
		private var source:BitmapData;
		private var mipMap : Vector<BitmapData>;
		private var mipMapCount:Int;
		public function new (?image : BitmapData=null)
		{
			mipMap= new Vector<BitmapData> ();
			mipMapCount=0;
			name = "";
			source=new BitmapData(1,1,true,0xffffffff);
			setImage(image);
		}
		/**
		 * 对source执行缩放
		 */
		private inline function scale (value:Float):BitmapData
		{
			var data:BitmapData=new BitmapData(Std.int(source.width*value),Std.int(source.height*value),source.transparent,0x0);
			var matrix:Matrix=new Matrix();
			matrix.a=value;
			matrix.d=value;
			data.draw(source,matrix);
            return data;
		}
		public function setImage (image : BitmapData) : Void
		{
			if (image == null) return;
			if(source!=null)
			{
				clearMipMaps ();
				source.dispose();
			} 
			source=image;
		}
		public function getBitmapData (?level : Int=-1) : BitmapData
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
		public function getMipMapCount () : Int
		{
			return mipMapCount;
		}
		public function hasMipMaps():Bool
		{
			return mipMapCount >= 1;
		}
		/**
		 * level 最小等级图片的大小
		 */
		public function generateMipMaps (?level:Int=16) : Void
		{
			clearMipMaps ();
			var min:Int = Std.int(Math.min(source.width, source.height));
			
			var i:Int = Std.int(min >> 1);
			while ( i >= level)
			{
				mipMap [mipMapCount] = scale(1/Math.pow(2,(mipMapCount+1)));
				mipMapCount++;
				
				i >>= 1;
			}
		}
		
		public inline function clearMipMaps () : Void
		{	
			for (i in 0...mipMapCount)
			{
				var tx : BitmapData = mipMap[i];
				tx.dispose ();
				tx=null;
			}
			mipMap=new Vector<BitmapData>();
			mipMapCount=0;
		}
		
		public function toString():String
		{
			return name;
		}
	}

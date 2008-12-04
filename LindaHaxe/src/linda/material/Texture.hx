package linda.material;

	import flash.Vector;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import haxe.Log;
	import linda.math.Dimension2D;
	import linda.math.MathUtil;
	
	//Todo 设置是否需要MipMap,如果需要的话，则每次重新赋值贴图时需要重新生成MipMaps
	class Texture
	{	
		public var name : String;
		private var vectors : Vector < Vector < UInt >> ;
		private var dimensions:Vector<Dimension2D>;// 对应每一个Vector数组的长和宽
		private var vectorCount:Int;
		private var useMipMap:Bool;
		private var level:Int;
		/**
		 * 要想重新生成新的MipMap必须重新调用setImage()
		 * @param	?image image.transparent must be true
		 * @param	?useMipMap
		 * @param	?level when useMipMap true,this active
		 */
		public function new (?image : BitmapData=null,?useMipMap:Bool=false,?level:Int=16)
		{
			name = "";
			vectors = new Vector < Vector < UInt >> ();
			dimensions= new Vector<Dimension2D>();
			vectorCount = 0;
			
			this.useMipMap = useMipMap;

			this.level = (level < 1) ? 1 : level;
			
			setImage(image);
		}
		public function setImage (image : BitmapData) : Void
		{
			if (image != null)
			{
				clear();
				
				vectors[0] = image.getVector(image.rect);
				dimensions[0] = new Dimension2D(image.width,image.height);
				vectorCount = 1;
				
				if (useMipMap)
				{
					generateMipMaps(image);
				}
			}
		}
		public function getVector (?i:Int = 0) : Vector<UInt>
		{
			if (i < 0) return vectors[0];
			if (i >= vectorCount) return vectors[vectorCount - 1];
			return vectors[i];
		}
		public function getWidth(?i:Int = 0):Int
		{
			if (i < 0) return dimensions[0].width;
			if (i >= vectorCount) return dimensions[vectorCount - 1].width;
			return dimensions[i].width;
		}
		public function getHeight(?i:Int = 0):Int
		{
			if (i < 0) return dimensions[0].height;
			if (i >= vectorCount) return dimensions[vectorCount - 1].height;
			return dimensions[i].height;
		}
		public function getVectorCount () : Int
		{
			return vectorCount;
		}
		
		/**
		 * level 最小等级图片的大小
		 */
		private inline function generateMipMaps (image:BitmapData) : Void
		{
			var min:Int = MathUtil.minInt(image.width, image.height);
			var i:Int = Std.int(min >> 1);
			while ( i >= level)
			{
				var data:BitmapData = scale(image, 1 / Math.pow(2, vectorCount));

				vectors[vectorCount] = data.getVector(data.rect);
				
				dimensions[vectorCount] = new Dimension2D(data.width,data.height);
				
				data.dispose();
				
				vectorCount++;
				
				i >>= 1;
			}
		}
		
		/**
		 * 对source执行缩放
		 */
		private inline function scale (image:BitmapData,value:Float):BitmapData
		{
			var data:BitmapData=new BitmapData(Std.int(image.width*value),Std.int(image.height*value),true,0x0);
			var matrix:Matrix=new Matrix();
			matrix.a = value;
			matrix.d = value;
			data.draw(image, matrix);
			matrix = null;
            return data;
		}
		
		public inline function clear() : Void
		{	
			vectors.length = 0;
			vectorCount = 0;
		}
		
		public function dispose():Void 
		{
			vectors.length = 0;
			vectors = null;
			vectorCount = 0;
		}
		
		public function toString():String
		{
			return name;
		}
	}

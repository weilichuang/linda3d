package linda.material;

	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.Lib;
	import flash.Vector;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import linda.math.Dimension2D;
	import linda.math.MathUtil;
    
	//Todo imp 是否可以不使用嵌套？？
	class Texture
	{	
		public var name : String;
		private var vectors : Vector < Vector < UInt >> ;
		private var dimensions:Vector<Dimension2D>;// 对应每一个Vector数组的长和宽
		private var vectorCount:Int;
		private var useMipMap:Bool;
		private var level:Int;
		/**
		 * 要想重新生成新的MipMap必须重新调用setDrawable()
		 * @param	?drawable IBitmapDrawable if drawable is BitmapData,it`s transparent must be true;
		 * @param	?useMipMap
		 * @param	?level when useMipMap true,this active
		 */
		public function new (?drawable:IBitmapDrawable=null,?useMipMap:Bool=false,?level:Int=16)
		{
			name = "";
			vectors = new Vector < Vector < UInt >> ();
			dimensions= new Vector<Dimension2D>();
			vectorCount = 0;
			
			this.useMipMap = useMipMap;

			this.level = (level < 1) ? 1 : level;
			
			setDrawable(drawable);
		}
		public function setDrawable (drawable : IBitmapDrawable) : Void
		{
			if (drawable != null)
			{
				clear();
				var image:BitmapData;
				if (Std.is(drawable, BitmapData))
				{
					image = cast(drawable, BitmapData).clone();
				}else
				{
					var display:DisplayObject=cast(drawable, DisplayObject);
					image = new BitmapData(Std.int(display.width), Std.int(display.height), true, 0x0);
					image.draw(display);
					display = null;
				}

				vectors[0] = image.getVector(image.rect);
				dimensions[0] = new Dimension2D(image.width,image.height);
				vectorCount = 1;
				
				if (useMipMap)
				{
					generateMipMaps(image);
				}
				
				image.dispose();
			}
		}
		public inline function getVector (?i:Int = 0) : Vector<UInt>
		{
			if (i < 0) i = 0;
			if (i >= vectorCount) i = vectorCount - 1;
			return vectors[i];
		}
		public inline function getWidth(?i:Int = 0):Int
		{
			if (i < 0) i = 0;
			if (i >= vectorCount) i = vectorCount - 1;
			return dimensions[i].width;
		}
		public inline function getHeight(?i:Int = 0):Int
		{
			if (i < 0) i = 0;
			if (i >= vectorCount) i = vectorCount - 1;
			return dimensions[i].height;
		}
		public inline function getDimension(?i:Int = 0):Dimension2D
		{
			if (i < 0) i = 0;
			if (i >= vectorCount) i = vectorCount - 1;
			return dimensions[i];
		}
		public inline function getVectorCount () : Int
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
				
				data = null;
				
				vectorCount++;
				
				i >>= 1;
			}
		}
		
		/**
		 * 对source执行缩放
		 */
		private static var matrix:Matrix = new Matrix();
		private inline function scale (image:BitmapData,value:Float):BitmapData
		{
			var data:BitmapData=new BitmapData(Std.int(image.width*value),Std.int(image.height*value),true,0x0);
			matrix.a = value;
			matrix.d = value;
			Lib.current.stage.quality = StageQuality.LOW;
			data.draw(image, matrix);
			Lib.current.stage.quality = StageQuality.HIGH;
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

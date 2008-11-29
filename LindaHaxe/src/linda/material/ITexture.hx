package linda.material;

	import flash.display.BitmapData;
	
	import linda.math.Dimension2D;
	
	interface ITexture
	{
		function hasMipMaps():Bool;
		function getMipMapCount():Int;
		function generateMipMaps(?level:Int=16):Void;
		function getBitmapData(i:Int=-1):BitmapData;
	}

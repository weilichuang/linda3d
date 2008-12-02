package linda;
import haxe.Log;

	class Linda
	{
		public static inline var VERSION:String="0.0.1.1202";
		public function new()
		{
		}
		public static function log():Void
		{
			Log.trace("Linda3D " + VERSION);
		}
	}
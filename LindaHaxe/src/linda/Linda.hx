package linda;
import haxe.Log;

	class Linda
	{
		public static inline var VERSION:String="0.0.8.1215";
		public function new()
		{
		}
		public static function log():Void
		{
			Log.trace("Linda : " + VERSION);
		}
	}
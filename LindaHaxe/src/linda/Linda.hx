package linda;
import haxe.Log;

	class Linda
	{
		public static inline var VERSION:String="0.1.0.0105";
		public function new()
		{
		}
		public static function log():Void
		{
			Log.trace("Linda : " + VERSION);
		}
	}
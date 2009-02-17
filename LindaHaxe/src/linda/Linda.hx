package linda;
import haxe.Log;

	class Linda
	{
		
		public static inline var VERSION:String="0.1.0.0217";//"主版本.较大改动.小改动.bug修复"
		public function new()
		{
		}
		public static function log():Void
		{
			Log.trace("Linda : " + VERSION);
		}
	}
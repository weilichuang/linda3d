package linda;
import haxe.Log;

	class Linda
	{
		
		public static inline var VERSION:String="0.1.0.0217";//"���汾.�ϴ�Ķ�.С�Ķ�.bug�޸�"
		public function new()
		{
		}
		public static function log():Void
		{
			Log.trace("Linda : " + VERSION);
		}
	}
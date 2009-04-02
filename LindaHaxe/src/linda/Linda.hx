package linda;
import haxe.Log;

class Linda
{
		
	public static inline var VERSION:String = "0.1.5.0401";
	
	public static inline var AUTHOR:String = "Andy";
	public function new()
	{
	}
	public static function log():Void
	{
		Log.trace("Linda : " + VERSION);
	}
}
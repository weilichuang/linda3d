package linda.events
{
	import flash.events.Event;

	public class RenderEvent extends Event
	{
		public static const COMPLETE:String='renderComplete';
		public static const RENDERING:String='rendering';
		public static const START:String='renderStart';
		public function RenderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
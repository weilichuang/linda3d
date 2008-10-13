package linda.events
{
	import flash.events.Event;

	public class AnimationEvent extends Event
	{
		public static const START:String='start';
		public static const END:String='end';
		public function AnimationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
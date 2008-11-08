package mini3d.events
{
	import flash.events.MouseEvent;
	
	import mini3d.scene.SceneNode;

	public class Mouse3DEvent extends MouseEvent
	{
		public static const CLICK:String=MouseEvent.CLICK;
		public static const DOUBLE_CLICK:String=MouseEvent.DOUBLE_CLICK;
		public static const MOUSE_DOWN:String=MouseEvent.MOUSE_DOWN;
		public static const MOUSE_UP:String=MouseEvent.MOUSE_UP;
		public static const MOUSE_MOVE:String=MouseEvent.MOUSE_MOVE;
		public static const MOUSE_OUT:String=MouseEvent.MOUSE_OUT;
		public static const MOUSE_OVER:String=MouseEvent.MOUSE_OVER;
		public static const MOUSE_WHEEL:String=MouseEvent.MOUSE_WHEEL;
		public static const ROLL_OUT:String=MouseEvent.ROLL_OUT;
		public static const ROLL_OVER:String=MouseEvent.ROLL_OVER;
		
		public var node:SceneNode;
		public function Mouse3DEvent(type:String,node:SceneNode)
		{
			super(type);
			
			this.node=node;
		}
		
	}
}
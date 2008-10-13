package linda.utils
{
    import flash.ui.Keyboard
	public class InputMap
	{
		public static const MOUSE_LEFT:int = -1;
		public static const MOUSE_RIGHT:int = -2;
		public static const MOUSE_WHEEL_ROLL:int = -3;
		public static const MOUSE_WHEEL_DOWN:int = -4;

		// movement
		public var moveForward:int = Keyboard.UP;
		public var moveBack:int = Keyboard.DOWN;
		public var moveStrafeLeft:int = Keyboard.LEFT;
		public var moveStrafeRight:int = Keyboard.RIGHT;
		public var moveJump:int = Keyboard.SPACE;
	}
}
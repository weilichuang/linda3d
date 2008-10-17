package linda.utils
{
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	import linda.math.Vector2D;	
	public class InputControl
	{
		/**
		 * Keyboard keys <Boolean> false = up, true = down
		 */
		public var keyDown:Vector.<Boolean>=new Vector.<Boolean>();
		public var keyShiftDown:Boolean = false;
		public var keyCtrlDown:Boolean = false;
		
		public var mouseDown:Boolean = false;
		
		// position of cursor
		private var cursorPos:Vector2D;
		private var cursorPosRelative:Vector2D;
		
		// size of output window
		private var _windowSize:Rectangle;
		private var inv_windowSizeX:Number;
		private var inv_windowSizeY:Number;
		
		private var _visible:Boolean;
		private var _container:DisplayObjectContainer;

		private var offsetX:int, offsetY:int;
		
		private var hasFocus:Boolean;

		public function InputControl(inputSize:Rectangle, window:DisplayObjectContainer)	
		{
			cursorPos = new Vector2D(0.5,0.5);
			cursorPosRelative = new Vector2D(0.5,0.5);
			
			_windowSize = inputSize;
			_visible = true;
			inv_windowSizeX = 1/_windowSize.width;
			inv_windowSizeY = 1/_windowSize.height;
			_container = window;
			offsetX = 0;
			offsetY = 0;
						
			// setup the key states
			resetKeys();
			
			// check stage
			if(!_container.stage)
			{
				return;
			}
			
			// add event listeners
			_container.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			_container.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
			
			// add mouse down listener
			_container.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			_container.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			
		}

		public function setFocus():void
		{
			hasFocus = true;
			_container.stage.focus = _container.stage;
		}
		
		public function removeFocus():void
		{
			hasFocus = false;
		}
		public function get windowSize():Rectangle
		{
			return _windowSize;
		}
		
		public function set windowSize(size:Rectangle):void
		{
			if(!size) return;
			if(size.width==0) size.width=1;
			if(size.height==0) size.height=1;
				
			_windowSize.width = size.width;
			_windowSize.height = size.height;
			
			
			inv_windowSizeX = 1/_windowSize.width;
			inv_windowSizeY = 1/_windowSize.height;
		}
		// =================================================================
		// event methods
		// =================================================================
		private function onKeyDownHandler(event:KeyboardEvent):void
		{
			keyDown[event.keyCode] = true;
			keyShiftDown = event.shiftKey;
			keyCtrlDown = event.ctrlKey;
			
			event.stopImmediatePropagation();
		}
		
		private function onKeyUpHandler(event:KeyboardEvent):void
		{
			keyDown[event.keyCode] = false;
			keyShiftDown = event.shiftKey;
			keyCtrlDown = event.ctrlKey;
		}
		
		private function onMouseMoveEvent(event:MouseEvent):void
		{
			if(!hasFocus)
				return;
			
			cursorPos.x = event.localX;
			cursorPos.y = event.localY;
			cursorPosRelative.x = cursorPos.x * inv_windowSizeX;
			cursorPosRelative.y = cursorPos.y * inv_windowSizeY;
			
			// check relative values
			if(cursorPosRelative.x<0)
			{
				cursorPosRelative.x = 0;
			}
			else if(cursorPosRelative.x>1)
			{
				cursorPosRelative.x = 1;
			}
			if(cursorPosRelative.y<0)
			{
				cursorPosRelative.y = 0;
			}
			else if(cursorPosRelative.y>1)
			{
				cursorPosRelative.y = 1;
			}
		}
		
		private function onMouseEvent(event:MouseEvent):void
		{
			mouseDown = event.buttonDown;	
		}
		public function setVisible(visible:Boolean):void
		{
			_visible = visible;
		}
		public function isVisible():Boolean
		{
			return _visible;
		}
		public function setPositionXY(x:Number, y:Number):void
		{
			cursorPos.x = x;
			cursorPos.y = y;
			cursorPosRelative.x = cursorPos.x * inv_windowSizeX;
			cursorPosRelative.y = cursorPos.y * inv_windowSizeY;
			
			// check relative values
			if(cursorPosRelative.x<0)
			{
				cursorPosRelative.x = 0;
			}
			else if(cursorPosRelative.x>1)
			{
				cursorPosRelative.x = 1;
			}
			if(cursorPosRelative.y<0)
			{
				cursorPosRelative.y = 0;
			}
			else if(cursorPosRelative.y>1)
			{
				cursorPosRelative.y = 1;
			}
		}
		public function setRelativePositionXY(x:Number, y:Number):void
		{
			cursorPosRelative.x = x;
			cursorPosRelative.y = x;
			
			// check relative values
			if(cursorPosRelative.x<0)
			{
				cursorPosRelative.x = 0;
			}
			else if(cursorPosRelative.x>1)
			{
				cursorPosRelative.x = 1;
			}
			if(cursorPosRelative.y<0)
			{
				cursorPosRelative.y = 0;
			}
			else if(cursorPosRelative.y>1)
			{
				cursorPosRelative.y = 1;
			}
			
			cursorPos.x = cursorPosRelative.x * _windowSize.width;
			cursorPos.y = cursorPosRelative.y * _windowSize.height;
		}
		public function getPosition():Vector2D
		{
			updateInternalCursorPosition();
			return cursorPos;
		}
		public function getRelativePosition():Vector2D
		{
			updateInternalCursorPosition();
			return cursorPosRelative;
		}
		
		
		//! Updates the internal cursor position
		private function updateInternalCursorPosition():void
		{
			if(!hasFocus) return;
			
			cursorPos.x = _container.mouseX;
			cursorPos.y = _container.mouseY;
			cursorPosRelative.x = cursorPos.x * inv_windowSizeX;
			cursorPosRelative.y = cursorPos.y * inv_windowSizeY;
			
			// check relative values
			if(cursorPosRelative.x<0)
			{
				cursorPosRelative.x = 0;
			}
			else if(cursorPosRelative.x>1)
			{
				cursorPosRelative.x = 1;
			}
			if(cursorPosRelative.y<0)
			{
				cursorPosRelative.y = 0;
			}
			else if(cursorPosRelative.y>1)
			{
				cursorPosRelative.y = 1;
			}
		}
		
		public function resetKeys():void
		{
			var l:int = keyDown.length;
			l = l == 0 ? 256 : l;
			
			for(var i:int=0;i<l;i++)
			{
				keyDown[i] = false;
			}
			
			keyShiftDown = false;
			keyCtrlDown = false;
		}
	}
}
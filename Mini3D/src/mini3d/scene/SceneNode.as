package mini3d.scene
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mini3d.animator.IAnimator;
	import mini3d.core.Material;
	import mini3d.events.Mouse3DEvent;
	import mini3d.math.AABBox3D;
	import mini3d.math.Matrix4;
	import mini3d.math.Vector3D;
	import mini3d.texture.ITexture;

	[Event(name='click'      , type='mini3d.events.Mouse3DEvent')]
	[Event(name='doubleClick', type='mini3d.events.Mouse3DEvent')]
	[Event(name='mouseDown'  , type='mini3d.events.Mouse3DEvent')]
	[Event(name='mouseMove'  , type='mini3d.events.Mouse3DEvent')]
	[Event(name='mouseOut'   , type='mini3d.events.Mouse3DEvent')]
	[Event(name='mouseOver'  , type='mini3d.events.Mouse3DEvent')]
	[Event(name='mouseUp'    , type='mini3d.events.Mouse3DEvent')]
	[Event(name='mouseWheel' , type='mini3d.events.Mouse3DEvent')]
	[Event(name='rollOut'    , type='mini3d.events.Mouse3DEvent')]
	[Event(name='rollOver'   , type='mini3d.events.Mouse3DEvent')]

	public class SceneNode extends EventDispatcher
	{
		private var _container:Sprite;
		
		private var _parent : SceneNode;
		private var _children : Array;
		
		private var _id:int;
		
		private var _animators:Array;
		
		protected var sceneManager : SceneManager;
		
		protected var _absoluteMatrix:Matrix4;
		protected var _relativeMatrix:Matrix4;
		
		protected var _relativeTranslation : Vector3D;
		protected var _relativeRotation : Vector3D;
		protected var _relativeScale : Vector3D;

		public var autoCulling : Boolean;

		public var distance : Number;
		
		public var name:String;
		
		public static const CAMERA :int = 0;
		public static const LIGHT  :int = 1;
		public static const NODE   :int = 2;

		public function SceneNode(mgr:SceneManager)
		{
			sceneManager=mgr;
			
			_relativeTranslation = new Vector3D(0,0,0);
			_relativeRotation = new Vector3D(0,0,0);
			_relativeScale = new Vector3D(1,1,1);
			
			_absoluteMatrix=new Matrix4();
			_relativeMatrix=new Matrix4();
			
			_children=new Array();
			_animators=new Array();

			autoCulling=true;
			distance=0;
			
			_container=new Sprite();
			
			_container.addEventListener(MouseEvent.CLICK,__clickHandler,false,0,true);
			_container.addEventListener(MouseEvent.DOUBLE_CLICK,__doubleClickHandler,false,0,true);
			_container.addEventListener(MouseEvent.MOUSE_DOWN,__mouseDownHandler,false,0,true);
			_container.addEventListener(MouseEvent.MOUSE_MOVE,__mouseMoveHandler,false,0,true);
			_container.addEventListener(MouseEvent.MOUSE_OUT,__mouseOutHandler,false,0,true);
			_container.addEventListener(MouseEvent.MOUSE_OVER,__mouseOverHandler,false,0,true);
			_container.addEventListener(MouseEvent.MOUSE_UP,__mouseUpHandler,false,0,true);
			_container.addEventListener(MouseEvent.MOUSE_WHEEL,__mouseWheelHandler,false,0,true);
			_container.addEventListener(MouseEvent.ROLL_OUT,__rollOutHandler,false,0,true);
			_container.addEventListener(MouseEvent.ROLL_OVER,__rollOverHandler,false,0,true);
			
		}
		
		public function destroy():void
		{
			_container.removeEventListener(MouseEvent.CLICK,__clickHandler,false);
			_container.removeEventListener(MouseEvent.DOUBLE_CLICK,__doubleClickHandler,false);
			_container.removeEventListener(MouseEvent.MOUSE_DOWN,__mouseDownHandler,false);
			_container.removeEventListener(MouseEvent.MOUSE_MOVE,__mouseMoveHandler,false);
			_container.removeEventListener(MouseEvent.MOUSE_OUT,__mouseOutHandler,false);
			_container.removeEventListener(MouseEvent.MOUSE_OVER,__mouseOverHandler,false);
			_container.removeEventListener(MouseEvent.MOUSE_UP,__mouseUpHandler,false);
			_container.removeEventListener(MouseEvent.MOUSE_WHEEL,__mouseWheelHandler,false);
			_container.removeEventListener(MouseEvent.ROLL_OUT,__rollOutHandler,false);
			_container.removeEventListener(MouseEvent.ROLL_OVER,__rollOverHandler,false);

			_absoluteMatrix=null;
			_relativeMatrix=null;
			_relativeTranslation=null;
			
			_relativeRotation=null;
			_relativeScale=null;
			
			_parent=null;
			_container=null;
			_animators=null;
			sceneManager=null;

			var i:int;
			var len:int=_children.length;
			for(i=0;i<len;i+=1)
			{
				var node:SceneNode=_children[i];
				node.destroy();
				node=null;
			}
			_children=null;
		}
		
		public function addChild (child : SceneNode) : void
		{
			if (child && (child != this))
			{
				child.remove(); // remove from old parent
				child._parent = this;
				child.updateAbsoluteMatrix ();
				
				_children.push(child);
			}
		}
		public function removeChild (child : SceneNode) : Boolean
		{
			var i:int=_children.indexOf(child);
				
			if(i == -1) return false;
			
			child._parent=null;
			
			_children.splice (i, 1);

			return true;
		}
		public function removeAll () : void
		{
			var len : int = _children.length;
			var child : SceneNode;
			for (var i : int = 0; i < len; i+=1)
			{
				child = _children [i];
				child._parent = null;
			}
			_children = [];
		}
		public function remove () : void
		{
			if (_parent)
			{
				_parent.removeChild (this);
			}
		}
		public function hasChild(child:SceneNode):Boolean
		{
			return child.parent == this;
		}
		public function getChildren () : Array
		{
			return _children;
		}
		public function getChildAt (i : int) : SceneNode
		{
			return _children[i];
		}
		public function set parent (newParent : SceneNode) : void
		{
			if (_parent)
			{
				_parent.removeChild(this);
			}
			
			_parent = newParent;
			
			if(_parent)
			{
				_parent.addChild(this);
			}
		}
		public function get parent():SceneNode
		{
	          return _parent;
		}

		public function getMaterial (i : int = 0) : Material
		{
			return null;
		}
		public function getMaterialCount () : int
		{
			return 0;
		}
		
		public function setMaterialFlag (flag : int, value : Boolean) : void
		{
			var count:int=getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial(i);
				if(material)
				{
					material.setFlag (flag, value);
				}
			}
		}
		public function setMaterialTexture (texture : ITexture) : void
		{
			var count:int=getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial(i);
				if(material)
				{
					material.setTexture (texture);
				}
			}
		}
		public function setMaterialColor (fillColor:uint,lineColor:uint) : void
		{
			var count:int=getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial(i);
				if(material)
				{
					material.fillColor=fillColor;
					material.lineColor=lineColor;
				}
			}
		}
		public function setMaterialAlpha (value:Number) : void
		{
			var count:int=getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial(i);
				if(material)
				{
					material.alpha=value;
				}
			}
		}
    
		public function onPreRender () : void
		{
			if (visible)
			{
				var len : int = _children.length;
				var child:SceneNode;
				for (var i : int = 0; i < len; i+=1)
				{
					child=_children[i];
					child.onPreRender ();
				}
			}
		}
		public function render () : void
		{
		}
		
		public function addAnimator (animator : IAnimator) : void
		{
			if (animator)
			{
				_animators.push (animator);
			}
		}
		public function removeAnimator (animator : IAnimator) : Boolean
		{
			var i:int=_animators.indexOf(animator);
				
			if(i == -1) return false;
			
			_animators.splice (i, 1);
			
			return true;
		}
		
		public function removeAnimators () : void
		{
			_animators=new Array();
		}
		public function onAnimate (timeMs : int) : void
		{
			if (visible)
			{
				var len:int=_animators.length;
				var animator:IAnimator;
				for (var i : int = 0; i < len; i+=1)
				{
					animator=_animators [i];
					animator.animateNode (this, timeMs);
				}
				
				updateAbsoluteMatrix ();
				
				len=_children.length;
				var child:SceneNode;
				for (i = 0; i < len; i+=1)
				{
					child=_children[i];
					child.onAnimate(timeMs);
				}
			}
		}
		public function updateAbsoluteMatrix () : void
		{
			var rx : Number = _relativeRotation.x * 0.017453292519943;
			var ry : Number = _relativeRotation.y * 0.017453292519943;
			var rz : Number = _relativeRotation.z * 0.017453292519943;

			var cr : Number = Math.cos (rx );
			var sr : Number = Math.sin (rx );
			var cp : Number = Math.cos (ry );
			var sp : Number = Math.sin (ry );
			var cy : Number = Math.cos (rz );
			var sy : Number = Math.sin (rz );

			var srsp : Number = sr * sp;
			var crsp : Number = cr * sp;
			
			//rotate
			_relativeMatrix.m00 = (cp * cy );
			_relativeMatrix.m01 = (cp * sy );
			_relativeMatrix.m02 = ( - sp );
			_relativeMatrix.m10 = (srsp * cy - cr * sy );
			_relativeMatrix.m11 = (srsp * sy + cr * cy );
			_relativeMatrix.m12 = (sr * cp );
			_relativeMatrix.m20 = (crsp * cy + sr * sy );
			_relativeMatrix.m21 = (crsp * sy - sr * cy );
			_relativeMatrix.m22 = (cr * cp );
			//translate
			_relativeMatrix.m30 = _relativeTranslation.x;
			_relativeMatrix.m31 = _relativeTranslation.y;
			_relativeMatrix.m32 = _relativeTranslation.z;
            //scale
			_relativeMatrix.m00 *= _relativeScale.x ;
			_relativeMatrix.m01 *= _relativeScale.x ;
			_relativeMatrix.m02 *= _relativeScale.x ;

			_relativeMatrix.m10 *= _relativeScale.y ;
			_relativeMatrix.m11 *= _relativeScale.y ;
			_relativeMatrix.m12 *= _relativeScale.y ;

			_relativeMatrix.m20 *= _relativeScale.z;
			_relativeMatrix.m21 *= _relativeScale.z;
			_relativeMatrix.m22 *= _relativeScale.z;

			if (_parent)
			{
				var absolute:Matrix4=_parent.getAbsoluteMatrix ();
				
				_absoluteMatrix.m00 = absolute.m00 * _relativeMatrix.m00 + absolute.m10 * _relativeMatrix.m01 + absolute.m20 * _relativeMatrix.m02;
			    _absoluteMatrix.m01 = absolute.m01 * _relativeMatrix.m00 + absolute.m11 * _relativeMatrix.m01 + absolute.m21 * _relativeMatrix.m02;
			    _absoluteMatrix.m02 = absolute.m02 * _relativeMatrix.m00 + absolute.m12 * _relativeMatrix.m01 + absolute.m22 * _relativeMatrix.m02;

			    _absoluteMatrix.m10 = absolute.m00 * _relativeMatrix.m10 + absolute.m10 * _relativeMatrix.m11 + absolute.m20 * _relativeMatrix.m12;
			    _absoluteMatrix.m11 = absolute.m01 * _relativeMatrix.m10 + absolute.m11 * _relativeMatrix.m11 + absolute.m21 * _relativeMatrix.m12;
			    _absoluteMatrix.m12 = absolute.m02 * _relativeMatrix.m10 + absolute.m12 * _relativeMatrix.m11 + absolute.m22 * _relativeMatrix.m12;

			    _absoluteMatrix.m20 = absolute.m00 * _relativeMatrix.m20 + absolute.m10 * _relativeMatrix.m21 + absolute.m20 * _relativeMatrix.m22;
			    _absoluteMatrix.m21 = absolute.m01 * _relativeMatrix.m20 + absolute.m11 * _relativeMatrix.m21 + absolute.m21 * _relativeMatrix.m22;
			    _absoluteMatrix.m22 = absolute.m02 * _relativeMatrix.m20 + absolute.m12 * _relativeMatrix.m21 + absolute.m22 * _relativeMatrix.m22;

			    _absoluteMatrix.m30 = absolute.m00 * _relativeMatrix.m30 + absolute.m10 * _relativeMatrix.m31 + absolute.m20 * _relativeMatrix.m32 + absolute.m30;
			    _absoluteMatrix.m31 = absolute.m01 * _relativeMatrix.m30 + absolute.m11 * _relativeMatrix.m31 + absolute.m21 * _relativeMatrix.m32 + absolute.m31;
			    _absoluteMatrix.m32 = absolute.m02 * _relativeMatrix.m30 + absolute.m12 * _relativeMatrix.m31 + absolute.m22 * _relativeMatrix.m32 + absolute.m32;

			} 
			else
			{
				_absoluteMatrix.m00 = _relativeMatrix.m00;
				_absoluteMatrix.m01 = _relativeMatrix.m01;
				_absoluteMatrix.m02 = _relativeMatrix.m02;

				_absoluteMatrix.m10 = _relativeMatrix.m10;
				_absoluteMatrix.m11 = _relativeMatrix.m11;
				_absoluteMatrix.m12 = _relativeMatrix.m12;

				_absoluteMatrix.m20 = _relativeMatrix.m20;
				_absoluteMatrix.m21 = _relativeMatrix.m21;
				_absoluteMatrix.m22 = _relativeMatrix.m22;

				_absoluteMatrix.m30 = _relativeMatrix.m30;
				_absoluteMatrix.m31 = _relativeMatrix.m31;
				_absoluteMatrix.m32 = _relativeMatrix.m32;
			}
		}

		public function getBoundingBox () :AABBox3D
		{
			return null;
		}
		public function getAbsoluteMatrix () : Matrix4
		{
			return _absoluteMatrix;
		}
		
		/**
		 * set and get methods
		 * x,y,z
		 * rotationX,rotationY,rotationZ
		 * scaleX,scaleY,scaleZ
		 */
		public function get x () : Number
		{
			return _relativeTranslation.x;
		}
		public function set x (px : Number) : void
		{
			_relativeTranslation.x = px;
		}
		public function get y () : Number
		{
			return _relativeTranslation.y;
		}
		public function set y (py : Number) : void
		{
			_relativeTranslation.y = py;
		}
		public function get z () : Number
		{
			return _relativeTranslation.z;
		}
		public function set z (pz : Number) : void
		{
			_relativeTranslation.z = pz;
		}
		public function get rotationX () : Number
		{
			return _relativeRotation.x;
		}
		public function set rotationX (rx : Number) : void
		{
			_relativeRotation.x = rx;
		}
		public function get rotationY () : Number
		{
			return _relativeRotation.y;
		}
		public function set rotationY (ry : Number) : void
		{
			_relativeRotation.y = ry;
		}
		public function get rotationZ () : Number
		{
			return _relativeRotation.z;
		}
		public function set rotationZ (rz : Number) : void
		{
			_relativeRotation.z = rz;
		}
		public function get scaleX () : Number
		{
			return _relativeScale.x;
		}
		public function set scaleX (rx : Number) : void
		{
			_relativeScale.x = rx;
		}
		public function get scaleY () : Number
		{
			return _relativeScale.y;
		}
		public function set scaleY (ry : Number) : void
		{
			_relativeScale.y = ry;
		}
		public function get scaleZ () : Number
		{
			return _relativeScale.z;
		}
		public function set scaleZ (rz : Number) : void
		{
			_relativeScale.z = rz;
		}
		
		
		//write only 
		public function set scale ( s : Number):void
		{
			_relativeScale.x=s;
			_relativeScale.y=s;
			_relativeScale.z=s;
		}
		public function getPosition () : Vector3D
		{
			return _relativeTranslation;
		}
		public function getRotation () : Vector3D
		{
			return _relativeRotation;
		}
		public function getScale () : Vector3D
		{
			return _relativeScale;
		}
		public function setPosition (pos : Vector3D) : void
		{
			_relativeTranslation = pos;
		}
		public function setRotation (rot : Vector3D) : void
		{
			_relativeRotation = rot;
		}
		public function setScale (s : Vector3D) : void
		{
			_relativeScale = s;
		}
		public function getAbsolutePosition () : Vector3D
		{
			return _absoluteMatrix.getTranslation ();
		}
		public function getAbsoluteScale () : Vector3D
		{
			return _absoluteMatrix.getScale ();
		}
		public function getAbsoluteRotation () : Vector3D
		{
			return _absoluteMatrix.getRotation ();
		}
		public function clone () : SceneNode
		{
			return null;
		}
		
		public function get visible():Boolean
		{
	          return container.visible;
		}
		public function set visible(value:Boolean):void
		{
	          container.visible=value;
		}

		/**
		 *read only
		 */
		public function get children():Array
		{
	           return _children;
		}

        /**
         * 包内调用，外部不可用
         * 避免用户调整其坐标,旋转等参数或方法而导致出现不可预测的结果
         */
		internal function get container():Sprite
		{
			return _container;
		}
		/**
		 * _container的本地坐标
		 */
		public function get contentX():Number
		{
			return _container.x;
		}
		public function get contentY():Number
		{
			return _container.y;
		}
		
		public function get mouseX():Number
		{
			return _container.mouseX;
		}
		
		public function get mouseY():Number
		{
			return _container.mouseY;
		}
		
		public function localToGlobal(p:Point):Point
		{
			return _container.localToGlobal(p);
		}
		public function globalToLocal(p:Point):Point
		{
			return _container.globalToLocal(p);
		}
		/**
		 * 
		 * 一些Sprite的属性,可能还要添加一些
		 * 
		 */
		public function set filters(fs:Array):void
		{
			_container.filters=fs;
		}
		public function get filters():Array
		{
			return _container.filters;
		}
		
		public function set buttonMode(mode:Boolean):void
		{
			_container.buttonMode=mode;
		}
		public function get buttonMode():Boolean
		{
			return _container.buttonMode;
		}
		
		public function set blendMode(mode:String):void
		{
			_container.blendMode=mode;
		}
		public function get blendMode():String
		{
			return _container.blendMode;
		}
		
		public function set alpha(a:Number):void
		{
			_container.alpha=a;
		}
		public function get alpha():Number
		{
			return _container.alpha;
		}
		
		public function get doubleClickEnabled():Boolean
		{
			return _container.doubleClickEnabled;
		}
    	public function set doubleClickEnabled(value:Boolean):void
    	{
    		_container.doubleClickEnabled=value;
    	}
    	
    	override public function toString () : String
		{
			return container.name;
		}
    	
    	/**
    	 * @private dispatchEvent
    	 */
    	
    	private function __clickHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.CLICK,this));
		}
		private function __doubleClickHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.DOUBLE_CLICK,this));
		}
		private function __mouseDownHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_DOWN,this));
		}
		private function __mouseMoveHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_MOVE,this));
		}
		private function __mouseOutHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_OUT,this));
		}
		private function __mouseOverHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_OVER,this));
		}
		private function __mouseUpHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_UP,this));
		}
		private function __mouseWheelHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.MOUSE_WHEEL,this));
		}
		private function __rollOutHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.ROLL_OUT,this));
		}
		private function __rollOverHandler(e:MouseEvent):void
		{
			dispatchEvent(new Mouse3DEvent(Mouse3DEvent.ROLL_OVER,this));
		}
	}
}
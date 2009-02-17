package linda.scene;

	import flash.Vector;
	import flash.events.EventDispatcher;
	
	import linda.animator.IAnimator;
	import linda.material.Material;
	import linda.material.Texture;
	import linda.math.Vector3;
	import linda.math.MathUtil;
	import linda.math.Matrix4;
	import linda.math.AABBox3D;
	import linda.math.Color;
	class SceneNode extends EventDispatcher
	{
		public static inline var CAMERA      : Int = 0;
		public static inline var LIGHT       : Int = 1;
		public static inline var SKYBOX      : Int = 2;
		public static inline var SOLID       : Int = 3;
		public static inline var TRANSPARENT : Int = 4;
		public static inline var SHADOW      : Int = 5;
		
		private var _parent : SceneNode;
		private var _children : Vector<SceneNode> ;
		private var _animators : Vector<IAnimator> ;
		
		private var _absoluteMatrix : Matrix4;
		private var _relativeMatrix : Matrix4;
		
		private var _relativeTranslation : Vector3;
		private var _relativeRotation : Vector3;
		private var _relativeScale : Vector3;

		private var sceneManager : SceneManager;

		public var distance : Float ;
		
		public var debug:Bool;
		
		public var name : String ;
		
		public var autoCulling : Bool;
		
		public var visible : Bool ;
		
		public var hasShadow : Bool ;
		
		public var id:Int;
		
		public var x(getX, setX):Float;
		public var y(getY, setY):Float;
		public var z(getZ, setZ):Float;
		
		public var scaleX(getScaleX, setScaleX):Float;
		public var scaleY(getScaleX, setScaleX):Float;
		public var scaleZ(getScaleX, setScaleX):Float;
		
		public var rotationX(getRotationX, setRotationX):Float;
		public var rotationY(getRotationY, setRotationY):Float;
		public var rotationZ(getRotationZ, setRotationZ):Float;
		
		public var parent(getParent, setParent):SceneNode;
		
		public function new (mgr:SceneManager)
		{
			super();
			sceneManager=mgr;
			
			_relativeTranslation = new Vector3(0.,0.,0.);
			_relativeRotation = new Vector3(0.,0.,0.);
			_relativeScale = new Vector3(1.,1.,1.);
			
			_absoluteMatrix=new Matrix4();
			_relativeMatrix=new Matrix4();
			
			_children=new Vector<SceneNode>();
			_animators=new Vector<IAnimator>();
			
			updateAbsoluteMatrix ();
			
			debug=false;
			distance=0.;
			visible=true;
			hasShadow=false;
			autoCulling=true;
			name="";
		}
		public function destroy():Void
		{
			_parent=null;
			_animators=null;
			sceneManager=null;
			name=null;
			_absoluteMatrix=null;
			_relativeMatrix=null;
			_relativeTranslation=null;
			
			_relativeRotation=null;
			_relativeScale=null;

			var i:Int;
			var len:Int=_children.length;
			for(i in 0...len)
			{
				var node:SceneNode=_children[i];
				node.destroy();
				node=null;
			}
			_children.length = 0;
			_children=null;
		}
		
		public function addChild (child : SceneNode) : Void
		{
			if (child!=null && (child != this))
			{
				child.remove(); // remove from old parent
				child._parent = this;
				_children.push(child);

				// change scene manager?
				if (sceneManager != child.sceneManager)
				{
					child.setSceneManager(sceneManager);
				}
			}
		}
		public function removeChild (child : SceneNode) : Bool
		{
			var i:Int=untyped _children.indexOf(child);
				
			if(i == -1) return false;
			
			child._parent=null;
			
			_children.splice (i, 1);

			return true;
		}
		public function removeAll () : Void
		{
			var len : Int = _children.length;
			for (i in 0...len)
			{
				_children[i]._parent = null;
			}
			_children.length = 0;
		}
		public function remove () : Void
		{
			if (_parent!=null)
			{
				_parent.removeChild (this);
			}
		}
		public function hasChild(child:SceneNode):Bool
		{
			return child.parent == this;
		}

		public function getChildAt (i : Int) : SceneNode
		{
			if (i < 0 || i >= _children.length) return null;
			return _children [i];
		}
		public function setParent (newParent : SceneNode) : SceneNode
		{
			if (_parent!=null)
			{
				_parent.removeChild(this);
			}
			
			_parent = newParent;
			
			if(_parent!=null)
			{
				_parent.addChild(this);
			}
			
			return newParent;
		}
		public function getParent():SceneNode
		{
	          return _parent;
		}

		public function addAnimator (animator : IAnimator) : Void
		{
			if(animator!=null)
			{
				_animators.push(animator);
			}
		}
		public function removeAnimator (animator : IAnimator) : Bool
		{
			var idx:Int = untyped _animators.indexOf(animator);
			if(idx == -1) return false;
			
			_animators.splice(idx,1);
			
			return true;
		}
		
		public function removeAnimators () : Void
		{
			_animators.length = 0;
		}
		public function getMaterial (?i : Int = 0) : Material
		{
			return null;
		}
		public function getMaterialCount () : Int
		{
			return 0;
		}
		public function setMaterialFlag (flag : Int, value : Bool) : Void
		{
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial(i);
				if(material!=null)
				{
					material.setFlag(flag, value);
				}
			}
		}
		//现在一个Material只使用一个texture
		public function setMaterialTexture (texture : Texture, ?textureLayer : Int = 1) : Void
		{
			if (textureLayer < 1 || textureLayer > 2) return;
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial(i);
				if(material!=null)
				{
					material.setTexture(texture, textureLayer);
				}
			}
		}
		/**
		* 设置所有materials的透明度
		*/
		public function setMaterialAlpha (alpha : Float) : Void
		{
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial (i);
				if(material!=null)
				{
					material.alpha = alpha;
				}
			}
		}
		public function setMaterialColor (?diffuse : UInt = 0xFFFFFF, ?ambient : UInt = 0xFFFFFF, ?emissive : UInt = 0x0000FF, ?specular : UInt = 0x0000FF) : Void
		{
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial (i);
				if(material!=null)
				{
					material.diffuseColor.color = diffuse;
					material.ambientColor.color = ambient;
					material.emissiveColor.color = emissive;
					material.specularColor.color = specular;
				}
			}
		}
		public function setMaterialDiffuseColor (color : UInt) : Void
		{
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial (i);
				if(material!=null)
				{
					material.diffuseColor.color = color;
				}
			}
		}
		public function setMaterialAmbientColor (color : UInt) : Void
		{
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial (i);
				if(material!=null)
				{
					material.ambientColor.color = color;
				}
			}
		}
		public function setMaterialEmissiveColor (color : UInt) : Void
		{
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial (i);
				if(material!=null)
				{
					material.emissiveColor.color = color;
				}
			}
		}
		public function setMaterialSpecularColor (color : UInt) : Void
		{
			var count:Int=this.getMaterialCount();
			var material:Material;
			for (i in 0...count)
			{
				material=getMaterial (i);
				if(material!=null)
				{
					material.specularColor.color = color;
				}
			}
		}
		public function onRegisterSceneNode() : Void
		{
			if (visible)
			{
				var len : Int = _children.length;
				for (i in 0...len)
				{
					_children[i].onRegisterSceneNode();
				}
			}
		}
		public function onAnimate (timeMs : Int) : Void
		{
			if (visible)
			{
				var len:Int=_animators.length;
				for (i in 0...len)
				{
					_animators[i].animateNode (this, timeMs);
				}
				
				updateAbsoluteMatrix ();
				
				len=_children.length;
				for (i in 0...len)
				{
					_children[i].onAnimate (timeMs);
				}
			}
		}
		public function render () : Void
		{
		}
		public function updateAbsoluteMatrix () : Void
		{
			_relativeMatrix.setRotation(_relativeRotation);

			_relativeMatrix.setTranslation(_relativeTranslation);
            
			if ( _relativeScale.x != 1 || _relativeScale.y != 1 || _relativeScale.z != 1)
			{
				_relativeMatrix.scale(_relativeScale);
			}
			
			if (_parent!=null)
			{
				var absolute:Matrix4 = _parent.getAbsoluteMatrix ();

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
				_absoluteMatrix.copy(_relativeMatrix);
			}
		}

		public function getBoundingBox () : AABBox3D
		{
			return null;
		}
		public function getAbsoluteMatrix () : Matrix4
		{
			return _absoluteMatrix;
		}
		public function getRelativeMatrix () : Matrix4
		{
			return _relativeMatrix;
		}
		public function getX () : Float
		{
			return _relativeTranslation.x;
		}
		public function setX (px : Float) : Float
		{
			_relativeTranslation.x = px;
			return px;
		}
		public function getY () : Float
		{
			return _relativeTranslation.y;
		}
		public function setY(py : Float) : Float
		{
			_relativeTranslation.y = py;
			return py;
		}
		public function getZ() : Float
		{
			return _relativeTranslation.z;
		}
		public function setZ(pz : Float) : Float
		{
			_relativeTranslation.z = pz;
			return pz;
		}
		public function getRotationX () : Float
		{
			return _relativeRotation.x;
		}
		public function setRotationX (rx : Float) : Float
		{
			_relativeRotation.x = rx;
			return rx;
		}
		public function getRotationY () : Float
		{
			return _relativeRotation.y;
		}
		public function setRotationY (ry : Float) : Float
		{
			_relativeRotation.y = ry;
			return ry;
		}
		public function getRotationZ () : Float
		{
			return _relativeRotation.z;
		}
		public function setRotationZ (rz : Float) : Float
		{
			_relativeRotation.z = rz;
			return rz;
		}
		public function getScaleX () : Float
		{
			return _relativeScale.x;
		}
		public function setScaleX (rx : Float) : Float
		{
			_relativeScale.x = rx;
			return rx;
		}
		public function getScaleY () : Float
		{
			return _relativeScale.y;
		}
		public function setScaleY (ry : Float) : Float
		{
			_relativeScale.y = ry;
			return ry;
		}
		public function getScaleZ () : Float
		{
			return _relativeScale.z;
		}
		public function setScaleZ (rz : Float) : Float
		{
			_relativeScale.z = rz;
			return rz;
		}
		public function getPosition () : Vector3
		{
			return _relativeTranslation.clone();
		}
		public function getRotation () : Vector3
		{
			return _relativeRotation.clone();
		}
		public function getScale () : Vector3
		{
			return _relativeScale.clone();
		}
		public function setPosition (pos : Vector3) : Void
		{
			_relativeTranslation.copy(pos);
		}
		public function setRotation (rot : Vector3) : Void
		{
			_relativeRotation.copy(rot);
		}
		public function setScale (s : Vector3) : Void
		{
			_relativeScale.copy(s);
		}
		public function getAbsolutePosition () : Vector3
		{
			return _absoluteMatrix.getTranslation ();
		}
		public function getAbsoluteScale () : Vector3
		{
			return _absoluteMatrix.getScale ();
		}
		public function getAbsoluteRotation () : Vector3
		{
			return _absoluteMatrix.getRotation ();
		}
		public function clone (newParent:SceneNode,newManager:SceneManager) : SceneNode
		{
			return null;
		}
		override public function toString () : String
		{
			return name;
		}
		//read only
		public function getChildren():Vector<SceneNode>
		{
	           return _children;
		}
		
		public function getAnimators():Vector<IAnimator>
		{
	           return _animators;
		}
		
		/**
		 * 
		 * @param	SceneManager newManager
		 * Sets the new scene manager for this node and all children.
         * Called by addChild when moving nodes between scene managers
		 */ 
		public function setSceneManager(newManager:SceneManager):Void 
		{
			sceneManager = newManager;
            
			var len:Int = _children.length;
			for ( i in 0...len)
			{
				_children[i].setSceneManager(newManager);
			}
		}
	}

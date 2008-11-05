package linda.scene
{
	import __AS3__.vec.Vector;
	
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	
	import linda.animator.ISceneNodeAnimator;
	import linda.material.Material;
	import linda.material.Texture;
	import linda.math.*;
	public class SceneNode extends EventDispatcher implements ISceneNode
	{
		public static const CAMERA : int = 0;
		public static const LIGHT : int = 1;
		public static const SKYBOX : int = 2;
		public static const SOLID : int = 3;
		public static const TRANSPARENT : int = 4;
		public static const SHADOW : int = 5;
		
		
		protected var _parent : SceneNode;
		protected var _children : Vector.<SceneNode> ;
		protected var _animators : Vector.<ISceneNodeAnimator> ;
		
		protected var _sceneManager : SceneManager;

		protected var _absoluteMatrix : Matrix4;
		protected var _relativeMatrix : Matrix4;
		
		protected var _relativeTranslation : Vector3D;
		protected var _relativeRotation : Vector3D;
		protected var _relativeScale : Vector3D;
		
		
		private var _name : String ;
		private var _autoCulling : Boolean;
		private var _visible : Boolean ;
		private var _hasShadow : Boolean ;
		
		private var _id:int=-1;
		
		private var _debug:Boolean;
		
		private static var _totalId:int=-1;

		private var _triangleSelector : TriangleSelector;

		private var _distance : Number=0;
		
		public function SceneNode (pos : Vector3D = null, rotation : Vector3D = null, scale : Vector3D = null)
		{
			
			_relativeTranslation = pos ? pos : new Vector3D(0,0,0);
			_relativeRotation = rotation ? rotation : new Vector3D(0,0,0);
			_relativeScale = scale ? scale : new Vector3D(1,1,1);
			
			_absoluteMatrix=new Matrix4();
			_relativeMatrix=new Matrix4();
			
			_children=new Vector.<SceneNode>();
			_animators=new Vector.<ISceneNodeAnimator>();
			
			updateAbsoluteMatrix ();
			
			_debug=false;
			_distance=0;
			_visible=true;
			_hasShadow=false;
			_autoCulling=true;
			_id=_totalId++;
			_name="node"+_id;
		}
		public function destroy():void
		{
			_parent=null;
			_children=null;
			_animators=null;
			_sceneManager=null;
			_name=null;
			_absoluteMatrix=null;
			_relativeMatrix=null;
			_relativeTranslation=null;
			
			_relativeRotation=null;
			_relativeScale=null;
			
			_triangleSelector=null;
		}
		public function addChild (child : SceneNode) : SceneNode
		{
			if ( ! child) return null;
			if (child._parent)
			{
				child._parent.removeChild (child);
			}
			child._parent = this;
			child._sceneManager = _sceneManager;
			_children.push (child);
			
			return child;
		}
		public function removeChild (child : SceneNode) : SceneNode
		{
			if(child == null) return null;
			var idx:int = _children.indexOf(child);
			_children.splice(idx,1);
			child._parent=null;
			child._sceneManager=null;
			return child;
		}
		public function removeAll () : void
		{
			var len : int = _children.length;
			var child_node : SceneNode;
			for (var i : int = 0; i < len; i+=1)
			{
				child_node = _children [i];
				child_node._parent = null;
				child_node._sceneManager = null;
			}
			_children = new Vector.<SceneNode>();
		}
		public function remove () : void
		{
			if (_parent)
			{
				_parent.removeChild (this);
			} else
			{
				_sceneManager = null;
			}
		}
		public function getChildren () : Vector.<SceneNode>
		{
			return _children;
		}
		public function getChildAt (i : int) : SceneNode
		{
			if (i < 0 || i >= _children.length) return null;
			return _children [i];
		}
		public function getChildById (i:int) : SceneNode
		{
			var l : int = _children.length;
			var node : SceneNode;
			for (var j : int = 0; j < l; j+=1)
			{
				node = _children [j];
				if (node.id == i)
				{
					return _children[j];
				}
			}
			return null;
		}
		public function set parent (newParent : SceneNode) : void
		{
			remove ();
			_parent = newParent;
			_sceneManager = _parent._sceneManager;
		}
		public function get parent():SceneNode
		{
	          return _parent;
		}
		public function set sceneManager (manager : SceneManager) : void
		{
			_sceneManager = manager;
			var len : int = _children.length;
			var child_node : SceneNode;
			for (var i : int = 0; i < len; i+=1)
			{
				child_node = _children [i];
				child_node._sceneManager =manager;
			}
		}
		public function get sceneManager():SceneManager
		{
	          return _sceneManager;
		}
		
		
		public function set debug(d:Boolean):void
        {
        	_debug=d;
        }
		public function get debug():Boolean
		{
	         return _debug;
		}

		public function addAnimator (animator : ISceneNodeAnimator) : ISceneNodeAnimator
		{
			if (!animator) return null;
			_animators.push (animator);
			return animator;
		}
		public function removeAnimator (animator : ISceneNodeAnimator) : ISceneNodeAnimator
		{
			if(!animator) return null;
			var idx:int = _animators.indexOf(animator);
			_animators.splice(idx,1);
			return animator;
		}
		
		public function removeAnimators () : void
		{
			_animators=new Vector.<ISceneNodeAnimator>();
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
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					material.setFlag (flag, value);
				}
			}
		}
		//现在一个Material只使用一个texture
		public function setMaterialTexture (texture : Texture, textureLayer : int = 1) : void
		{
			if (textureLayer < 1 || textureLayer > 2) return;
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					material.setTexture (texture, textureLayer);
				}
			}
		}
		/**
		* 设置所有materials的透明度
		*/
		public function setMaterialAlpha (alpha : Number) : void
		{
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					material.alpha = alpha;
				}
			}
		}
		public function setMaterialColor (diffuse : uint = 0xFFFFFF, ambient : uint = 0xFFFFFF, emissive : uint = 0x0000FF, specular : uint = 0x0000FF) : void
		{
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					material.diffuseColor.color = diffuse;
					material.ambientColor.color = ambient;
					material.emissiveColor.color = emissive;
					//material.specularColor.color = specular;
				}
			}
		}
		public function setMaterialDiffuseColor (color : uint) : void
		{
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					material.diffuseColor.color = color;
				}
			}
		}
		public function setMaterialAmbientColor (color : uint) : void
		{
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					material.ambientColor.color = color;
				}
			}
		}
		public function setMaterialEmissiveColor (color : uint) : void
		{
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					material.emissiveColor.color = color;
				}
			}
		}
		public function setMaterialSpecularColor (color : uint) : void
		{
			var count:int=this.getMaterialCount();
			var material:Material;
			for (var i : int = 0; i < count; i+=1)
			{
				material=getMaterial (i);
				if(material)
				{
					//material.specularColor.color = color;
				}
			}
		}
		public function onPreRender () : void
		{
			if (_visible)
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
		public function onAnimate (timeMs : int) : void
		{
			if (_visible)
			{
				var len:int=_animators.length;
				var animator:ISceneNodeAnimator;
				for (var i : int = 0; i < len; i+=1)
				{
					animator=_animators [i];
					animator.animateNode (this, timeMs);
				}
				
				updateAbsoluteMatrix ();
				
				len=_children.length;
				var child:SceneNode;
				for (i = 0; i < len; i ++)
				{
					child=_children[i];
					child.onAnimate (timeMs);
				}
			}
		}
		public function render () : void
		{
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
			
			
			_relativeMatrix.m00 = (cp * cy );
			_relativeMatrix.m01 = (cp * sy );
			_relativeMatrix.m02 = ( - sp );
			_relativeMatrix.m03 = 0;
			_relativeMatrix.m10 = (srsp * cy - cr * sy );
			_relativeMatrix.m11 = (srsp * sy + cr * cy );
			_relativeMatrix.m12 = (sr * cp );
			_relativeMatrix.m13 = 0;
			_relativeMatrix.m20 = (crsp * cy + sr * sy );
			_relativeMatrix.m21 = (crsp * sy - sr * cy );
			_relativeMatrix.m22 = (cr * cp );
			_relativeMatrix.m23 = 0;
			_relativeMatrix.m30 = _relativeTranslation.x;
			_relativeMatrix.m31 = _relativeTranslation.y;
			_relativeMatrix.m32 = _relativeTranslation.z;
			_relativeMatrix.m33 = 1;

			_relativeMatrix.m00 *= _relativeScale.x ;
			_relativeMatrix.m01 *= _relativeScale.x ;
			_relativeMatrix.m02 *= _relativeScale.x ;
			_relativeMatrix.m10 *= _relativeScale.y ;
			_relativeMatrix.m11 *= _relativeScale.y ;
			_relativeMatrix.m12 *= _relativeScale.y ;
			_relativeMatrix.m20 *= _relativeScale.z ;
			_relativeMatrix.m21 *= _relativeScale.z ;
			_relativeMatrix.m22 *= _relativeScale.z ;

			if (_parent)
			{
				var absolute:Matrix4=_parent.getAbsoluteMatrix ();
				
				_absoluteMatrix.m00 = absolute.m00 * _relativeMatrix.m00 + absolute.m10 * _relativeMatrix.m01 + absolute.m20 * _relativeMatrix.m02;
			    _absoluteMatrix.m01 = absolute.m01 * _relativeMatrix.m00 + absolute.m11 * _relativeMatrix.m01 + absolute.m21 * _relativeMatrix.m02;
			    _absoluteMatrix.m02 = absolute.m02 * _relativeMatrix.m00 + absolute.m12 * _relativeMatrix.m01 + absolute.m22 * _relativeMatrix.m02;
			    _absoluteMatrix.m03 = 0.;
			    _absoluteMatrix.m10 = absolute.m00 * _relativeMatrix.m10 + absolute.m10 * _relativeMatrix.m11 + absolute.m20 * _relativeMatrix.m12;
			    _absoluteMatrix.m11 = absolute.m01 * _relativeMatrix.m10 + absolute.m11 * _relativeMatrix.m11 + absolute.m21 * _relativeMatrix.m12;
			    _absoluteMatrix.m12 = absolute.m02 * _relativeMatrix.m10 + absolute.m12 * _relativeMatrix.m11 + absolute.m22 * _relativeMatrix.m12;
			    _absoluteMatrix.m13 = 0.;
			    _absoluteMatrix.m20 = absolute.m00 * _relativeMatrix.m20 + absolute.m10 * _relativeMatrix.m21 + absolute.m20 * _relativeMatrix.m22;
			    _absoluteMatrix.m21 = absolute.m01 * _relativeMatrix.m20 + absolute.m11 * _relativeMatrix.m21 + absolute.m21 * _relativeMatrix.m22;
			    _absoluteMatrix.m22 = absolute.m02 * _relativeMatrix.m20 + absolute.m12 * _relativeMatrix.m21 + absolute.m22 * _relativeMatrix.m22;
			    _absoluteMatrix.m23 = 0.;
			    _absoluteMatrix.m30 = absolute.m00 * _relativeMatrix.m30 + absolute.m10 * _relativeMatrix.m31 + absolute.m20 * _relativeMatrix.m32 + absolute.m30;
			    _absoluteMatrix.m31 = absolute.m01 * _relativeMatrix.m30 + absolute.m11 * _relativeMatrix.m31 + absolute.m21 * _relativeMatrix.m32 + absolute.m31;
			    _absoluteMatrix.m32 = absolute.m02 * _relativeMatrix.m30 + absolute.m12 * _relativeMatrix.m31 + absolute.m22 * _relativeMatrix.m32 + absolute.m32;
			    _absoluteMatrix.m33 = 1.;
			} 
			else
			{
				_absoluteMatrix.m00 = _relativeMatrix.m00;
				_absoluteMatrix.m01 = _relativeMatrix.m01;
				_absoluteMatrix.m02 = _relativeMatrix.m02;
				_absoluteMatrix.m03 = 0;
				_absoluteMatrix.m10 = _relativeMatrix.m10;
				_absoluteMatrix.m11 = _relativeMatrix.m11;
				_absoluteMatrix.m12 = _relativeMatrix.m12;
				_absoluteMatrix.m13 = 0;
				_absoluteMatrix.m20 = _relativeMatrix.m20;
				_absoluteMatrix.m21 = _relativeMatrix.m21;
				_absoluteMatrix.m22 = _relativeMatrix.m22;
				_absoluteMatrix.m23 = 0;
				_absoluteMatrix.m30 = _relativeMatrix.m30;
				_absoluteMatrix.m31 = _relativeMatrix.m31;
				_absoluteMatrix.m32 = _relativeMatrix.m32;
				_absoluteMatrix.m33 = 1;
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
		public function copy (node : SceneNode) : void
		{
		}
		public function getTriangleSelector () : TriangleSelector
		{
			return _triangleSelector;
		}
		public function setTriangleSelector (selector : TriangleSelector) : void
		{
			_triangleSelector = selector;
		}
		override public function toString () : String
		{
			return _name;
		}
		
		
		public function get visible():Boolean
		{
	          return _visible;
		}
		public function set visible(vis:Boolean):void
		{
	          _visible=vis;
		}
		
		public function get name():String
		{
	          return _name;
		}
		public function set name(n:String):void
		{
	          _name=n;
		}

		public function get hasShadow():Boolean
		{
	           return _hasShadow;
		}
		public function set hasShadow(shadow:Boolean):void
		{
	           _hasShadow=shadow;
		}
		
		public function get autoCulling():Boolean
		{
	           return _autoCulling;
		}
		public function set autoCulling(cull:Boolean):void
		{
	           _autoCulling=cull;
		}
		
		public function get distance():Number
		{
	           return _distance;
		}
		public function set distance(distance:Number):void
		{
	           _distance=distance;
		}
		
		//read only
		public function get children():Vector.<SceneNode>
		{
	           return _children;
		}
		
		public function get animators():Vector.<ISceneNodeAnimator>
		{
	           return _animators;
		}
		public function get id():int
		{
			return _id;
		}
	}
}

package linda.scene
{
	import __AS3__.vec.Vector;
	
	import linda.animator.ISceneNodeAnimator;
	import linda.collision.TriangleSelector;
	import linda.material.Material;
	import linda.material.Texture;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	
	import flash.events.IEventDispatcher;
	import flash.geom.Vector3D;
	
	public interface ISceneNode extends IEventDispatcher
	{
		//position
		function get x():Number;
		function set x(px:Number):void;
		function get y():Number;
		function set y(py:Number):void;
		function get z():Number;
		function set z(pz:Number):void;
		function setPositionXYZ(x:Number,y:Number,z:Number):void;
		function setPosition(pos:Vector3D):void;
		function getPosition():Vector3D;
		//rotation,use degree
		function get rotationX():Number;
		function set rotationX(rx:Number):void;
		function get rotationY():Number;
		function set rotationY(ry:Number):void;
		function get rotationZ():Number;
		function set rotationZ(rz:Number):void;
		function setRotationXYZ(rx:Number,ry:Number,rz:Number):void;
		function setRotation(rot:Vector3D):void;
		function getRotation():Vector3D;
		//scale, 0 ~ 1
		function get scaleX():Number;
		function set scaleX(sx:Number):void;
		function get scaleY():Number;
		function set scaleY(sy:Number):void;
		function get scaleZ():Number;
		function set scaleZ(sz:Number):void;
		function setScaleXYZ(sx:Number,sy:Number,sz:Number):void;
		function setScale(sca:Vector3D):void;
		function getScale():Vector3D;
		
		function get visible():Boolean;
		function set visible(vis:Boolean):void;
		
		function get parent():SceneNode;
		function set parent(p:SceneNode):void;
		
		function get name():String;
		function set name(n:String):void;
		
		function get sceneManager():SceneManager;
		function set sceneManager(manager:SceneManager):void;
		
		function get hasShadow():Boolean;
		function set hasShadow(shadow:Boolean):void;
		
		function get autoCulling():Boolean;
		function set autoCulling(cull:Boolean):void;
		
		function get distance():Number;
		function set distance(d:Number):void;
		
		//read only
		function get children():Vector.<SceneNode>;//<ISceneNode>
		
		function get animators():Vector.<ISceneNodeAnimator>;
		
		function get id():int;
		
		function set debug(d:Boolean):void;
		function get debug():Boolean;
		
		//render
		function onPreRender():void;
		function render():void;
		function onAnimate(timeMs:int):void;
		
		function getBoundingBox():AABBox3D;

		function getAbsoluteMatrix () : Matrix4;
		function getRelativeMatrix () : Matrix4;
		function updateAbsoluteMatrix () : void;

		function copy (node : SceneNode) : void;
		function clone():SceneNode;

		function getTriangleSelector () : TriangleSelector;
		function setTriangleSelector (selector : TriangleSelector) : void;
		
		function addChild (child : SceneNode) : SceneNode;
		function removeChild (child : SceneNode) : SceneNode;
		function removeAll () : void;
		function remove () : void;
		function getChildren () : Vector.<SceneNode>;
		function getChildAt (i : int) : SceneNode;
		function getChildById(i:int):SceneNode;

		function addAnimator (animator : ISceneNodeAnimator) : ISceneNodeAnimator;
		function removeAnimator (animator : ISceneNodeAnimator) : ISceneNodeAnimator;
		function removeAnimators () : void;
		function getMaterial (i : int = 0) : Material;
		function getMaterialCount () : int;
		function setMaterialFlag (flag : int, value : Boolean) : void;

		function setMaterialTexture (texture : Texture, textureLayer : int = 1) : void;
		
		/**
		 * 设置所有materials的透明度,如果几个SceneNode使用的是同一个Mesh,
		 * 以下设置将同时改变其它几个的Material属性,因为修改的都是同一个Mesh
		 */
		function setMaterialAlpha (alpha : Number) : void;
		function setMaterialColor (diffuse : uint = 0xFFFFFF, ambient : uint = 0xFFFFFF, emissive : uint = 0x0000FF, specular : uint = 0x0000FF) : void;
		function setMaterialDiffuseColor (color : uint) : void;
		function setMaterialAmbientColor (color : uint) : void;
		function setMaterialEmissiveColor (color : uint) : void;
		function setMaterialSpecularColor (color : uint) : void;
		//清除数据
		function destroy():void;
	}
}
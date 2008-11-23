package linda.video
{
	import flash.display.*;
	import flash.geom.Vector3D;
	
	import linda.light.Light;
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Color;
	import linda.math.Dimension2D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	import linda.mesh.IMeshBuffer;
	public interface IVideoDriver
	{
		function beginScene (backBuffer : Boolean = true, zBuffer : Boolean = true, color : uint = 0x0) : Boolean;
		function endScene () : Boolean;

		function setTransformViewProjection (mat : Matrix4) : void;
		function setTransformWorld (mat : Matrix4) : void;
		function setTransformView (mat : Matrix4) : void;
		function setTransformProjection (mat : Matrix4) : void;
		
		function setMaterial (material : Material) : void;
		function setPerspectiveCorrectDistance(distance:Number=400):void;
		function getPerspectiveCorrectDistance():Number;
		function setMipMapDistance(distance:Number=800):void;
		function getMipMapDistance():Number;

		function setRenderTarget (target : Sprite) : void;
		function getRenderTarget () : Sprite;
		function drawIndexedTriangleList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void;
		function drawMeshBuffer(mb:IMeshBuffer):void;
		/**
		*用来渲染由线段组成的物体,此类物体不需要进行光照，贴图，和贴图坐标计算等
		* @vertices  Array 点的集合
		* @vertexCount int vertices的长度
		* @indexList 点与点之间的顺序
		* @indexCount int indexList.length
		*/
		function drawIndexedLineList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void;
		function drawStencilShadowVolume (vertices : Vector.<Vertex>, vertexCount : int, useZFailMethod : Boolean) : void;
		//投影面大小
		function getScreenSize ():Dimension2D;
		function setScreenSize (size:Dimension2D):void;
		function getPrimitiveCountDrawn () : int;
		
		//fog
		function setFog(color:Color,start:Number=50,end:Number=100):void;

		//动态灯光相关
		function removeAllLights () : void;
		function addLight (light : Light) : void;
		
		function getLight (i : int) : Light;
		function getLightCount () : int;
		
		function setAmbient (color : uint) : void;

		function getDriverType () : String;
		function createScreenShot():BitmapData;

		function setCameraPosition(ps:Vector3D):void;
		
		//draw debug box
		function draw3DBox(box:AABBox3D,color:uint):void;
		function draw3DLine(vs:Vector3D,ve:Vector3D,color:uint):void;
		function draw3DTriangle(v0:Vertex,v1:Vertex,v2:Vertex,color:uint):void;
		function setDebugColor(color:uint):void;
		function getDebugColor():uint;
	}
}

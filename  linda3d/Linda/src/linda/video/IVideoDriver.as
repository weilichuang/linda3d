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
	import linda.mesh.MeshBuffer;
	public interface IVideoDriver
	{
		function beginScene () : void;
		function endScene () : void;

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
		function drawMeshBuffer(mb:MeshBuffer):void;
		function drawStencilShadowVolume (vertices : Vector.<Vertex>, vertexCount : int, useZFailMethod : Boolean) : void;

		function getScreenSize ():Dimension2D;
		function setScreenSize (size:Dimension2D):void;
		function getPrimitiveCountDrawn () : int;

		//动态灯光相关
		function removeAllLights () : void;
		function addLight (light : Light) : void;
		function getLight (i : int) : Light;
		function getLightCount () : int;
		
		function setAmbient (color : uint) : void;
		
		function setFog(color:Color,start:Number=50,end:Number=100):void;

		function getDriverType () : String;
		function createScreenShot():BitmapData;

		function setCameraPosition(ps:Vector3D):void;
		
		//draw debug box
		function draw3DBox(box:AABBox3D,color:uint):void;
		function draw3DLine(vs:Vector3D,ve:Vector3D,color:uint):void;
		function draw3DTriangle(v0:Vertex,v1:Vertex,v2:Vertex,color:uint):void;
		function drawIndexedLineList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void;
		function setDebugColor(color:uint):void;
		function getDebugColor():uint;
	}
}

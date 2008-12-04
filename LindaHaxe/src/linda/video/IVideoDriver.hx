package linda.video;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.Vector;
	import linda.math.Vector3;
	
	import linda.light.Light;
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Color;
	import linda.math.Dimension2D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	import linda.mesh.MeshBuffer;
	interface IVideoDriver
	{
		function beginScene () : Void;
		function endScene () : Void;
        
		function setCameraPosition(ps:Vector3):Void;
		function setTransformViewProjection (mat : Matrix4) : Void;
		function setTransformWorld (mat : Matrix4) : Void;
		function setTransformView (mat : Matrix4) : Void;
		function setTransformProjection (mat : Matrix4) : Void;
		
		function setMaterial (material : Material) : Void;
		function setDistance(distance:Float):Void ;//根据物体的深度来判断是否使用MipMap和PerspectiveCorrect
		function setPerspectiveCorrectDistance(?distance:Float=400.):Void;
		function getPerspectiveCorrectDistance():Float;
		function setMipMapDistance(?distance:Float=500.):Void;
		function getMipMapDistance():Float;

		function setRenderTarget (target : Sprite) : Void;
		function getRenderTarget () : Sprite;
		
		function drawIndexedLineList (vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void;
		function drawIndexedTriangleList (vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void;
		function drawMeshBuffer(mb:MeshBuffer):Void;

		function getScreenSize ():Dimension2D;
		function setScreenSize (size:Dimension2D):Void;
		function getPrimitiveCountDrawn () : Int;

		//动态灯光相关
		function setAmbient (color : UInt) : Void;
		function removeAllLights () : Void;
		function addLight (light : Light) : Void;
		function getLight (i : Int) : Light;
		function getLightCount () : Int;
		
		function getDriverType () : String;
		function createScreenShot():BitmapData;
		// debug 
		function draw3DBox(box:AABBox3D,color:UInt):Void;
		function draw3DLine(vs:Vector3,ve:Vector3,color:UInt):Void;
		function draw3DTriangle(v0:Vertex,v1:Vertex,v2:Vertex,color:UInt):Void;
		function setDebugColor(color:UInt):Void;
		function getDebugColor():UInt;
	}


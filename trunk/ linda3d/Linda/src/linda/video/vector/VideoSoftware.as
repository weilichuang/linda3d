package linda.video.vector
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.Vector3D;
	
	import linda.material.Material;
	import linda.math.*;
	import linda.mesh.IMeshBuffer;
	import linda.video.IVideoDriver;
	import linda.video.VideoNull;
	import linda.video.VideoType;

	public class VideoSoftware extends VideoNull implements IVideoDriver
	{
		public function VideoSoftware()
		{
			super();
		}
		
		override public function beginScene(backBuffer:Boolean=true, zBuffer:Boolean=true, color:uint=0x0):Boolean
		{
			return false;
		}
		
		override public function endScene():Boolean
		{
			return false;
		}
		
		override public function setTransformViewProjection(mat:Matrix4):void
		{
		}
		
		override public function setTransformWorld(mat:Matrix4):void
		{
		}
		
		override public function setTransformView(mat:Matrix4):void
		{
		}
		
		override public function setTransformProjection(mat:Matrix4):void
		{
		}
		
		override public function setMaterial(material:Material):void
		{
		}
		
		override public function setPerspectiveCorrectDistance(distance:Number=400):void
		{
		}
		
		override public function getPerspectiveCorrectDistance():Number
		{
			return 0;
		}
		
		override public function setMipMapDistance(distance:Number=800):void
		{
		}
		
		override public function getMipMapDistance():Number
		{
			return 0;
		}
		
		override public function setRenderTarget(target:Sprite):void
		{
		}
		
		override public function getRenderTarget():Sprite
		{
			return null;
		}
		
		override public function drawIndexedTriangleList(vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int):void
		{
		}
		
		override public function drawMeshBuffer(mb:IMeshBuffer):void
		{
		}
		
		override public function drawIndexedLineList(vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
		}
		override public function setScreenSize(size:Dimension2D):void
		{
		}
		override public function getName():String
		{
			return "VideoVector";
		}
		
		override public function getDriverType():String
		{
			return VideoType.VECTOR;
		}
		
		override public function setCameraPosition(ps:Vector3D):void
		{
		}
		
		override public function createScreenShot():BitmapData
		{
			return null;
		}
	}
}
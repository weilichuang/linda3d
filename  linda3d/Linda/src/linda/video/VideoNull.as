package linda.video
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.*;
	
	import linda.light.Light;
	import linda.material.*;
	import linda.math.*;
	import linda.mesh.IMeshBuffer;
	import linda.scene.*;
	public class VideoNull implements IVideoDriver
	{
		protected var primitivesDrawn : int;
		protected var screenSize :Dimension2D;

		protected var ambientColor : Color = new Color (0, 0, 0);
		protected var fogColor : Color = new Color (0, 0, 0);
		protected var fogStart : Number = 50;
		protected var fogEnd : Number = 100;
		
		protected var renderTarget : Sprite;
		protected var _lights : Vector.<Light>;
		private var _lightCount:int;
		
		
		private var _debugColor : uint = 0x00ff00;
		
		protected var perspectiveDistance:Number=400;
		protected var mipMapDistance:Number=800;
		
		private var _tmp_lines : Vector.<Vertex> ;
		private var _tmp_lines_indices : Vector.<int>;
		
		public function VideoNull ()
		{
			primitivesDrawn = 0;
			renderTarget = new Sprite ();
			screenSize = new Dimension2D(300, 300);
			_lights = new Vector.<Light>(8,true);
			_lightCount=0;
			
			_tmp_lines= new Vector.<Vertex>(3,true);
			_tmp_lines[0]=new Vertex ();
			_tmp_lines[1]=new Vertex ();
			_tmp_lines[2]=new Vertex ();
			_tmp_lines_indices = new Vector.<int>(6,true);
			_tmp_lines_indices[0]=0;
			_tmp_lines_indices[1]=1;
			_tmp_lines_indices[2]=1;
			_tmp_lines_indices[3]=2;
			_tmp_lines_indices[4]=2;
			_tmp_lines_indices[5]=0;
		}
		public function getScreenSize () : Dimension2D
		{
			return screenSize;
		}
		public function setScreenSize (size : Dimension2D) : void
		{
		}
		public function beginScene (backbuffer : Boolean = true, zbuffer : Boolean = true , color : uint = 0x0) : Boolean
		{
			primitivesDrawn = 0;
			return true;
		}
		public function endScene () : Boolean
		{
			return true;
		}
		public function setTransformWorld (mat : Matrix4) : void
		{
		}
		public function setTransformView (mat : Matrix4) : void
		{
		}
		public function setTransformViewProjection (mat : Matrix4) : void
		{
		}

		public function setTransformProjection (mat : Matrix4) : void
		{
		}
		
		public function setMaterial (material : Material) : void
		{
		}

		public function setRenderTarget (target : Sprite) : void
		{
			renderTarget = target;
		}
		public function getRenderTarget () : Sprite
		{
			return renderTarget;
		}
		public function drawIndexedTriangleList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
		}
		public function drawMeshBuffer (mesh : IMeshBuffer) : void
		{
		}
		/**
		*用来渲染由线段组成的物体,此类物体不需要进行光照，贴图，和贴图坐标计算等
		* @vertices  Array 点的集合
		* @vertexCount int vertices的长度
		* @indexList 点与点之间的顺序
		* @indexCount int indexList.length
		*/
		public function drawIndexedLineList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
		}
		public function drawStencilShadowVolume (vertices : Vector.<Vertex>, vertexCount : int, useZFailMethod : Boolean) : void
		{
		}
		public function getDriverType () : String
		{
			return VideoType.NULL;
		}
		public function setFog (color : Color, start : Number = 50, end : Number = 100) : void
		{
			fogColor = color;
			fogStart = start;
			fogEnd = end;
		}
		//lights
		/**
		* 环境光，环境光只需要一个，默认颜色为黑色。
		*/
		public function setAmbient (color : uint) : void
		{
			ambientColor.color = color;
		}
		public function getAmbient () : Color
		{
			return ambientColor;
		}
		/**
		* 场景中被渲染物体的多边形数量
		*/
		public function getPrimitiveCountDrawn () : int
		{
			return primitivesDrawn;
		}
		public function setCameraPosition (ps : Vector3D) : void
		{
		}
		public function createScreenShot () : BitmapData
		{
			return null;
		}

		public function setDebugColor (color : uint) : void
		{
			_debugColor = color;
		}
		public function getDebugColor () : uint
		{
			return _debugColor;
		}
		//--------------------------------light--------------------------------//
		public function removeAllLights () : void
		{
			_lights = new Vector.<Light>();
			_lightCount=0;
		}
		/**
		 * 如果灯光数量大于最大数量，则新加入的会替换第一个
		 */
		public function addLight (light : Light) : void
		{
			if ( ! light) return;
			if (_lightCount >= getMaxLightAmount ())
			{
				_lights[0]=light;
			}else
			{
				_lights[_lightCount]=light;
				_lightCount++;
			}
		}
		public static function getMaxLightAmount () : int
		{
			return 8;
		}
		public function getLightCount () : int
		{
			return _lightCount;
		}
		public function getLight (index : int) : Light
		{
			if (index < 0 || index >= getLightCount()) return null;
			return _lights[index];
		}
		
		public function draw3DBox (box : AABBox3D, color : uint) : void
		{
			var edges : Vector.<Vector3D> = box.getEdges ();
			draw3DLine (edges [5] , edges [1] , color);
			draw3DLine (edges [1] , edges [3] , color);
			draw3DLine (edges [3] , edges [7] , color);
			draw3DLine (edges [7] , edges [5] , color);
			draw3DLine (edges [0] , edges [2] , color);
			draw3DLine (edges [2] , edges [6] , color);
			draw3DLine (edges [6] , edges [4] , color);
			draw3DLine (edges [4] , edges [0] , color);
			draw3DLine (edges [1] , edges [0] , color);
			draw3DLine (edges [3] , edges [2] , color);
			draw3DLine (edges [7] , edges [6] , color);
			draw3DLine (edges [5] , edges [4] , color);
		}
		
		private var _tmp_material : Material = new Material ();
		public function draw3DLine (start : Vector3D, end : Vector3D, color : uint) : void
		{
			setMaterial (_tmp_material);
			var vertex : Vertex = _tmp_lines [0];
			vertex.x = start.x;
			vertex.y = start.y;
			vertex.z = start.z;
			vertex.color = color;
			vertex = _tmp_lines [1];
			vertex.x = end.x;
			vertex.y = end.y;
			vertex.z = end.z;
			vertex.color = color;
			drawIndexedLineList (_tmp_lines, 2, _tmp_lines_indices, 2);
		}
		public function draw3DTriangle (v0 : Vertex, v1 : Vertex, v2 : Vertex, color : uint) : void
		{
			setMaterial (_tmp_material);
			var vertex : Vertex = _tmp_lines [0];
			vertex.copy (v0);
			vertex.color = color;
			vertex = _tmp_lines [1];
			vertex.copy (v1);
			vertex.color = color;
			vertex = _tmp_lines [2];
			vertex.copy (v2);
			vertex.color = color;
			drawIndexedLineList (_tmp_lines, 3, _tmp_lines_indices, 6);
		}
		public function setPerspectiveCorrectDistance(distance:Number=400):void
		{
			perspectiveDistance=distance;
		}
		public function getPerspectiveCorrectDistance():Number
		{
			return perspectiveDistance;
		}
		public function setMipMapDistance(distance:Number=500):void
		{
	        mipMapDistance=distance;
		}
		public function getMipMapDistance():Number
		{
	        return mipMapDistance;
		}
	}
}

package linda.video;

	import flash.Vector;
	import flash.display.Sprite;
	
	import linda.light.Light;
	import linda.material.Material;
	import linda.math.Vector3;
	import linda.math.Dimension2D;
	import linda.scene.SceneNode;
	import linda.math.Color;
	import linda.math.Vertex;
	import linda.math.Vertex4D;
	import linda.math.AABBox3D;
	import linda.math.Dimension2D;
	class VideoNull
	{
		private var primitivesDrawn : Int;
		private var screenSize :Dimension2D;

		private var ambientColor : Color ;
		
		private var renderTarget : Sprite;
		private var _lights : Vector<Light>;
		private var _lightCount:Int;
		
		
		private var _debugColor : UInt;
		
		private var persDistance:Float;
		private var mipMapDistance:Float;
		
		private var _tmp_lines : Vector<Vertex> ;
		private var _tmp_lines_indices : Vector<Int>;

		public function new ()
		{
			primitivesDrawn = 0;
			renderTarget    = new Sprite ();
			screenSize      = new Dimension2D(300, 300);
			_lights         = new Vector<Light>(8,true);
			_lightCount     = 0;
			
			persDistance   = 400.;
			mipMapDistance = 500.;
			
			_debugColor = 0x00ff00;
			ambientColor = new Color (0, 0, 0);
			
			_tmp_lines = new Vector<Vertex>(3,true);
			_tmp_lines[0] = new Vertex ();
			_tmp_lines[1] = new Vertex ();
			_tmp_lines[2] = new Vertex ();
			_tmp_lines_indices = new Vector<Int>(6,true);
			_tmp_lines_indices[0] = 0;
			_tmp_lines_indices[1] = 1;
			_tmp_lines_indices[2] = 1;
			_tmp_lines_indices[3] = 2;
			_tmp_lines_indices[4] = 2;
			_tmp_lines_indices[5] = 0;
		}
		public function getScreenSize () : Dimension2D
		{
			return screenSize;
		}

		public function setRenderTarget (target : Sprite) : Void
		{
			renderTarget = target;
		}
		public function getRenderTarget () : Sprite
		{
			return renderTarget;
		}
		//lights
		/**
		* 环境光，环境光只需要一个，默认颜色为黑色。
		*/
		public function setAmbient (color : UInt) : Void
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
		public function getPrimitiveCountDrawn () : Int
		{
			return primitivesDrawn;
		}
		public function setMaterial (mat:Material) : Void
		{
		}
		public function setDebugColor (color : UInt) : Void
		{
			_debugColor = color;
		}
		public function getDebugColor () : UInt
		{
			return _debugColor;
		}
		//--------------------------------light--------------------------------//
		public function removeAllLights () : Void
		{
			_lightCount=0;
		}
		/**
		 * 如果灯光数量大于最大数量，则新加入的会替换最后一个
		 */
		public function addLight (light : Light) : Void
		{
			if ( light==null) return;
			if (_lightCount >= getMaxLightAmount ())
			{
				_lights[getMaxLightAmount()-1]=light;
			}else
			{
				_lights[_lightCount]=light;
				_lightCount++;
			}
		}
		public function getMaxLightAmount () : Int
		{
			return 8;
		}
		public function getLightCount () : Int
		{
			return _lightCount;
		}
		public function getLight (index : Int) : Light
		{
			if (index < 0 || index >= getLightCount()) return null;
			return _lights[index];
		}
		
		public function draw3DBox (box : AABBox3D, color : UInt) : Void
		{
			var edges : Vector<Vector3> = box.getEdges ();
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
		
		public  function draw3DLine (start : Vector3, end : Vector3, color : UInt) : Void
		{
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
		public  function draw3DTriangle (v0 : Vertex, v1 : Vertex, v2 : Vertex, color : UInt) : Void
		{
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
		public  function drawIndexedLineList (vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
		{
		}
		public function getMipMapDistance():Float
		{
			return mipMapDistance;
		}
		public function getPerspectiveCorrectDistance():Float
		{
			return persDistance;
		}
	}

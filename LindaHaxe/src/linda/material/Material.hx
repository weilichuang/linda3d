package linda.material;

	import linda.math.Color;
	class Material
	{
		//设置可以一次修改多个的方式，用 0x0001等等
		public static inline var WIREFRAME:Int=0;
		public static inline var BACKFACE:Int=1;
		public static inline var LIGHT:Int=2;
		public static inline var TRANSPARTENT:Int=3;
		public static inline var GOURAUD_SHADE:Int = 4;
		public static inline var FRONTFACE:Int = 5;
		public static inline var ZBUFFER:Int=6;

		public var backfaceCulling : Bool ;//背面剔除
		public var frontfaceCulling:Bool;//正面剔除
		public var transparenting : Bool ;//透明
		public var gouraudShading : Bool ;//平滑着色
		public var lighting : Bool ;//灯光
		public var wireframe : Bool ;//网格
		public var zBuffer:Bool;
        
		public var ambientColor:Color;
		public var diffuseColor:Color;
		public var emissiveColor:Color;
		public var specularColor:Color;

		//纹理图
		public var texture : Texture;
		//光照图
		public var texture1 : Texture;
		
		public var shininess:Int;//指数，用于高光部分
		
		private var _alpha:Float;
		
		public var alpha(getAlpha, setAlpha):Float;
		
		public var name:String;

		public function new ()
		{
			name="";
			shininess=0;
			_alpha=1.;
			
			lighting=false;
			backfaceCulling = true;
			frontfaceCulling = false;
			transparenting  = false;
			gouraudShading  = false;
			lighting  = false;
			wireframe  = false;
			zBuffer = true;
			
			ambientColor=new Color(255,255,255);
			diffuseColor=new Color(255,255,255);
			emissiveColor=new Color(0,0,0);
			specularColor=new Color(0,0,0);
			
		}
		public function setAlpha(value:Float):Float
		{
			if (value > 1.0) value = 1.0;
			if (value < 0.0) value = 0.0;
			_alpha = value;
			return _alpha;
		}
		public function getAlpha():Float
		{
			return _alpha;
		}
		public function setTexture(texture:Texture,?layer:Int=1):Void
		{
			if(layer == 1)
			{
				this.texture = texture;
				return;
			}else 
			{
				texture1=texture;
			}
		}
		public function getTexture():Texture
		{
			return texture;
		}
		public function getTexture1():Texture
		{
			return texture1;
		}
		public function setFlag(flag:Int,value:Bool):Void
		{
			switch(flag)
			{
				case BACKFACE :
				     backfaceCulling=value;
				case GOURAUD_SHADE :
				     gouraudShading=value;
				case LIGHT :
				     lighting=value;
				case TRANSPARTENT:
				     transparenting=value;
				case WIREFRAME:
				     wireframe = value;
				case FRONTFACE:
				     frontfaceCulling = value;	
				case ZBUFFER:
				     zBuffer = value;
			}
		}
		public function clone():Material
		{
			var mat:Material = new Material();
			
			mat.backfaceCulling = backfaceCulling;
			mat.frontfaceCulling = frontfaceCulling;
			mat.transparenting = transparenting;
			mat.gouraudShading = gouraudShading;
			mat.wireframe = wireframe;
			mat.lighting = lighting;
			mat.zBuffer = zBuffer;
			
			mat.ambientColor.copy(ambientColor);
			mat.diffuseColor.copy(diffuseColor);
			mat.emissiveColor.copy(emissiveColor);
			
			mat._alpha = _alpha;
			mat.shininess = shininess;
			
			mat.texture = texture;
			mat.texture1 = texture1;
			
			return mat;
		}
		public function copy(mat:Material):Void
		{
			frontfaceCulling = mat.frontfaceCulling;
			backfaceCulling = mat.backfaceCulling;
			transparenting = mat.transparenting;
			gouraudShading = mat.gouraudShading;
			wireframe = mat.wireframe;
			lighting = mat.lighting;
			zBuffer = mat.zBuffer;
			
			ambientColor.copy(mat.ambientColor);
		    diffuseColor.copy(mat.diffuseColor);
			emissiveColor.copy(mat.emissiveColor);
			
			_alpha = mat._alpha;
			shininess = mat.shininess;
			
			texture  = mat.texture;
			texture1 = mat.texture1;
		}
		public function toString():String
		{
			return name;
		}
		
	}

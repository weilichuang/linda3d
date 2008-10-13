package linda.material
{
	import linda.math.Color;
	public class Material
	{
		public static const WIREFRAME:int=0;
		public static const BACKFACE:int=2;
		public static const LIGHT:int=4;
		public static const TRANSPARTENT:int=8;
		public static const GOURAUD_SHADE:int=16;

		public var backfaceCulling : Boolean = true;//背面裁剪
		public var transparenting : Boolean = false;//透明
		public var gouraudShading : Boolean = false;//平滑着色
		public var lighting : Boolean = false;//灯光
		public var wireframe : Boolean = false;//网格
        
		public var ambientColor:Color=new Color(255,255,255);
		public var diffuseColor:Color=new Color(255,255,255);
		public var emissiveColor:Color=new Color(0,0,0);
		public var specularColor:Color=new Color(0,0,0);

		//纹理图
		public var texture1 : ITexture;
		public var texture2 : ITexture;
		
		public var shininess:int=0;//指数，用于高光部分
		
		private var _alpha:Number=1;
		
		public var name:String;
		
		private static var _id:int=0;

		public function Material ()
		{
			name='material'+(_id++);
		}
		public function setTexture(texture:ITexture,layer:int=1):void
		{
			if(layer == 1)
			{
				texture1=texture;
			}else if(layer == 2)
			{
				texture2=texture;
			}
		}
		public function getTexture(layer:int=1):ITexture
		{
			if(layer == 1)
			{
				return texture1;
			}
			if(layer == 2)
			{
				return texture2;
			}
			return null;
		}
		public function set alpha(a:Number):void
		{
			if(a >=0 && a<= 1)
			{
				_alpha=a;
			}
		}
		public function get alpha():Number
		{
			return _alpha;
		}
		public function setFlag(flag:int,value:Boolean):void
		{
			switch(flag)
			{
				case BACKFACE :
				     backfaceCulling=value;
				break;
				case GOURAUD_SHADE :
				     gouraudShading=value;
				     break;
				case LIGHT :
				     lighting=value;
				     break;
				case TRANSPARTENT:
				     transparenting=value;
				     break;
				case WIREFRAME:
				     wireframe=value;
				     break;
			}
		}
		public function clone():Material
		{
			var mat:Material=new Material();
			mat.backfaceCulling=backfaceCulling;
			mat.transparenting=transparenting;
			mat.gouraudShading=gouraudShading;
			mat.wireframe=wireframe;
			mat.lighting=lighting;
			
			mat.ambientColor=ambientColor.clone();
			mat.diffuseColor=diffuseColor.clone();
			mat.emissiveColor=emissiveColor.clone();
			
			mat.alpha=alpha;
			mat.shininess=shininess;
			
			mat.texture1=texture1;//这里没有必要创建新的Texture了，直接引用原来的就行
			mat.texture2=texture2;
			
			return mat;
		}
		public function copy(mat:Material):void
		{
			backfaceCulling=mat.backfaceCulling;
			transparenting=mat.transparenting;
			gouraudShading=mat.gouraudShading;
			wireframe=mat.wireframe;
			lighting=mat.lighting;
			
			ambientColor.copy(mat.ambientColor);
		    diffuseColor.copy(mat.diffuseColor);
			emissiveColor.copy(mat.emissiveColor);
			
			alpha=mat.alpha;
			shininess=mat.shininess;
			
			texture1=mat.texture1;//这里没有必要创建新的Texture了，直接引用原来的就行
			texture2=mat.texture2;
		}
		public function toString():String
		{
			return name;
		}
		
	}
}

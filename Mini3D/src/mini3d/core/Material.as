package mini3d.core
{
	import mini3d.texture.ITexture;
	public class Material
	{
		public var fillColor : uint;
		public var lineColor : uint;
		public var alpha : Number;
		public var backfaceCulling : Boolean;
		public var fillWithLine : Boolean;
		public var fillWithColor : Boolean;
		
		
		public var texture : ITexture;
		public var name : String;
		
		
		public static const BACKFACE : int = 0;
		public static const FILLWITHCOLOR : int = 1;
		public static const FILLWITHLINE : int = 2;
		
		public function Material()
		{
			backfaceCulling = true;
			fillWithLine = false;
			fillWithColor= true;
			fillColor = 0x555555;
			lineColor = 0xff0000;
			alpha = 1;
		}

		public function setTexture(value : ITexture) : void
		{
			this.texture = value;
		}

		public function setFlag(i : int , value : Boolean) : void
		{
			switch(i)
			{
				case BACKFACE : 
				backfaceCulling = value;
				break;
				case FILLWITHCOLOR : 
				fillWithColor = value;
				break;
				case FILLWITHLINE : 
				fillWithLine = value;
				break;
			}
		}

		public function clone() : Material
		{
			var mat : Material = new Material();
			mat.backfaceCulling = backfaceCulling;
			mat.fillWithLine = fillWithLine;
			mat.fillWithColor = fillWithColor;
			mat.texture = texture;
			mat.fillColor = fillColor;
			mat.lineColor = lineColor;
			mat.alpha = alpha;
			mat.name = name;
			return mat;
		}

		public function copy(other : Material) : void
		{
			backfaceCulling = other.backfaceCulling;
			fillWithLine = other.fillWithLine;
			fillWithColor = other.fillWithColor;
			texture = other.texture;
			fillColor = other.fillColor;
			lineColor = other.lineColor;
			alpha = other.alpha;
			name = other.name;
		}
	}
}

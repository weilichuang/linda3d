package linda.light
{
	import flash.geom.Vector3D;
	
	import linda.math.Color;
	public class Light
	{
		public static const DIRECTIONAL : int = 0;
		public static const POINT : int = 1;
		public static const SPOT : int = 2;
		
		public var ambientColor : Color;//散射光
		public var diffuseColor : Color;//反射光
		public var specularColor : Color;//高光
		
		public var position : Vector3D;
		public var direction : Vector3D;
		
		public var kc : Number;//constant衰减因子常量
		public var kl : Number;//linear衰减因子线性
		public var kq : Number;//quadratic衰减因子二次衰减因子

		public var powerFactor:int=1;

		public var type : int;//类型
		
		public var radius:Number;
		
		public var castShadows : Boolean = false;
		
		public function Light ()
		{
			ambientColor = new Color (0,0,0);//散射光
			diffuseColor = new Color (0,0,0);//反射光
			specularColor = new Color (0,0,0);//高光
		
			position = new Vector3D ();
			direction = new Vector3D (0.,0.,1.);
			kc=0;
			kl=0.002;
			kq=0;
			powerFactor=1;
			type=0;
			radius=1000;
		}
		public function copy(l:Light):void
		{
			diffuseColor.r=l.diffuseColor.r;
			diffuseColor.g=l.diffuseColor.g;
			diffuseColor.b=l.diffuseColor.b;

			ambientColor.r=l.ambientColor.r;
			ambientColor.g=l.ambientColor.g;
			ambientColor.b=l.ambientColor.b;

			specularColor.r=l.specularColor.r;
			specularColor.g=l.specularColor.g;
			specularColor.b=l.specularColor.b;

			position.x=l.position.x;
			position.y=l.position.y;
			position.z=l.position.z;
			
			direction.x=l.direction.x;
			direction.y=l.direction.y;
			direction.z=l.direction.z;

			kc=l.kc;
			kl=l.kl;
			kq=l.kq;
			
			powerFactor=l.powerFactor;

			type=l.type;
			
			castShadows=l.castShadows;
		}
		public function clone():Light
		{
			var l:Light=new Light();
			l.diffuseColor.r = diffuseColor.r;
			l.diffuseColor.g = diffuseColor.g;
			l.diffuseColor.b = diffuseColor.b;

			l.ambientColor.r = ambientColor.r;
			l.ambientColor.g = ambientColor.g;
			l.ambientColor.b = ambientColor.b;

			l.specularColor.r = specularColor.r;
			l.specularColor.g = specularColor.g;
			l.specularColor.b = specularColor.b;
			
			l.position.x= position.x;
			l.position.y= position.y;
			l.position.z= position.z;
			
			l.direction.x= direction.x;
			l.direction.y= direction.y;
			l.direction.z= direction.z;

			l.kc=kc;
			l.kl=kl;
			l.kq=kq;
            l.radius=radius;
			l.powerFactor=powerFactor;
			l.castShadows=castShadows;
			return l;
		}
	}
}

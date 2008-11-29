package linda.light;

	import linda.math.Vector3;
	import linda.math.Color;
	
	class Light
	{
		public static inline var DIRECTIONAL : Int = 0;
		public static inline var POINT : Int = 1;
		public static inline var SPOT : Int = 2;
		
		public var ambientColor : Color;//散射光
		public var diffuseColor : Color;//反射光
		public var specularColor : Color;//高光
		
		public var position : Vector3;
		public var direction : Vector3;
		
		public var kc : Float;//constant衰减因子常量
		public var kl : Float;//linear衰减因子线性
		public var kq : Float;//quadratic衰减因子二次衰减因子

		public var powerFactor:Int;

		public var type : Int;//类型
		
		public var radius:Float;
		
		public var castShadows : Bool ;
		
		public function new ()
		{
			ambientColor = new Color (0,0,0);//散射光
			diffuseColor = new Color (0,0,0);//反射光
			specularColor = new Color (0,0,0);//高光
		
			position = new Vector3();
			direction = new Vector3(0.,0.,1.);
			kc=0;
			kl=0.002;
			kq=0;
			powerFactor=1;
			type=0;
			radius = 1000;
			
			castShadows = false;
			
		}
		public inline function copy(l:Light):Void
		{
			diffuseColor.copy(l.diffuseColor);
			ambientColor.copy(l.ambientColor);
			specularColor.copy(l.specularColor);
            
			position.copy(l.position);
			direction.copy(l.direction);
			
			kc=l.kc;
			kl=l.kl;
			kq=l.kq;
			
			powerFactor=l.powerFactor;

			type=l.type;
			
			castShadows=l.castShadows;
		}
		public inline function clone():Light
		{
			var l:Light = new Light();
			
			l.diffuseColor.copy(diffuseColor);
			l.ambientColor.copy(ambientColor);
			l.specularColor.copy(specularColor);
            
			l.position.copy(position);
			l.direction.copy(direction);
			
			l.kc=kc;
			l.kl=kl;
			l.kq=kq;
            l.radius=radius;
			l.powerFactor=powerFactor;
			l.castShadows=castShadows;
			return l;
		}
	}

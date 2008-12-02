package linda.scene;

	import linda.light.Light;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.video.IVideoDriver;
	
	import linda.math.Vector3;
	class LightSceneNode extends SceneNode
	{
		public var light : Light ;
		
		private var box : AABBox3D;
		public function new (mgr:SceneManager, ?color : UInt = 0xFFFFFF,?radius:Float=200., ?type : Int = 0)
		{
			super (mgr);
			
			light = new Light ();
			light.diffuseColor.color = color;
			light.radius =radius;
			light.type   = type;
			
			box = new AABBox3D ();
			box.addXYZ (-5., -5., -5.);
			box.addXYZ (5., 5., 5.);
			autoCulling = false;
		}
		override public function destroy():Void
		{
			light = null;
			box   = null;
			super.destroy();
		}
		public inline function setDiffuseColor (color : UInt) : Void
		{
			light.diffuseColor.color = color;
		}
		public inline function setAmbientColor(color : UInt) : Void
		{
			light.ambientColor.color = color;
		}
		public inline function setSpecularColor(color : UInt) : Void
		{
			light.specularColor.color = color;
		}
		override public function onRegisterSceneNode () : Void
		{
			if (visible)
			{
				if (light.type == Light.DIRECTIONAL || light.type == Light.SPOT)
				{
					light.direction.x = 0.;
					light.direction.y = 0.;
					light.direction.z = 1.;
					
					_absoluteMatrix.rotateVector(light.direction);
					light.direction.normalize();
				}
				if (light.type == Light.POINT || light.type == Light.SPOT)
				{
					var matrix:Matrix4 = _absoluteMatrix;
					light.position.x = matrix.m30;
					light.position.y = matrix.m31;
					light.position.z = matrix.m32;
				}				
				sceneManager.registerNodeForRendering (this, SceneNode.LIGHT);
				super.onRegisterSceneNode ();
			}
		}
		override public function render () : Void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			driver.addLight (light);
			if(debug)
			{
				driver.setTransformWorld(_absoluteMatrix);
				driver.draw3DBox(box,light.diffuseColor.color);
			}
		}
		override public function getBoundingBox () : AABBox3D
		{
			return box;
		}
	}


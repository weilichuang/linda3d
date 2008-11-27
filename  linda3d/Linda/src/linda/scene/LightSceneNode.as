package linda.scene
{
	import linda.light.Light;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.video.IVideoDriver;
	
	import flash.geom.Vector3D;
	public class LightSceneNode extends SceneNode
	{
		public var light : Light ;
		
		private var box : AABBox3D;
		public function LightSceneNode (mgr:SceneManager, color : uint = 0xFFFFFF,radius:Number=200, type : int = 0)
		{
			super (mgr);
			light = new Light ();
			light.diffuseColor.color = color;
			light.radius=radius;
			light.type = type;
			
			box = new AABBox3D ();
			box.addXYZ (-5, -5, -5);
			box.addXYZ (5, 5, 5);
			autoCulling = false;
		}
		override public function destroy():void
		{
			light=null;
			box=null;
			super.destroy();
		}

		public function setDiffuseColor (color : uint) : void
		{
			light.diffuseColor.color = color;
		}
		override public function onPreRender () : void
		{
			if (visible)
			{
				if (light.type == Light.DIRECTIONAL || light.type == Light.SPOT)
				{
					light.direction.x=0;
					light.direction.y=0;
					light.direction.z=1;
					
					_absoluteMatrix.rotateVector(light.direction);
					light.direction.normalize();
				}
				if (lightData.type == Light.POINT || lightData.type == Light.SPOT)
				{
					var matrix:Matrix4=_absoluteMatrix;
					light.position.x=matrix.m30;
					light.position.y=matrix.m31;
					light.position.z=matrix.m32;
				}				
				sceneManager.registerNodeForRendering (this, LIGHT);
				super.onPreRender ();
			}
		}
		override public function render () : void
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
}

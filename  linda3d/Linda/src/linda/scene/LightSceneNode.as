package linda.scene
{
	import linda.light.Light;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.video.IVideoDriver;
	
	import flash.geom.Vector3D;
	public class LightSceneNode extends SceneNode
	{
		private var lightData : Light ;
		private var box : AABBox3D;
		public function LightSceneNode (mgr:SceneManager, color : uint = 0xFFFFFF,radius:Number=200, type : int = 0)
		{
			super (mgr);
			lightData = new Light ();
			lightData.diffuseColor.color = color;
			lightData.radius=radius;
			lightData.type = type;
			
			box = new AABBox3D ();
			box.addXYZ (-5, -5, -5);
			box.addXYZ (5, 5, 5);
			autoCulling = false;
		}
		override public function destroy():void
		{
			lightData=null;
			box=null;
			super.destroy();
		}
		public function get light () : Light
		{
			return lightData;
		}
		public function set light (l : Light) : void
		{
			if(l)
			{
				lightData = l;
			}
		}
		public function setDiffuseColor (color : uint) : void
		{
			lightData.diffuseColor.color = color;
		}
		override public function onPreRender () : void
		{
			if (visible)
			{
				if (lightData.type == Light.DIRECTIONAL || lightData.type == Light.SPOT)
				{
					lightData.direction.x=0;
					lightData.direction.y=0;
					lightData.direction.z=1;
					
					_absoluteMatrix.rotateVector(lightData.direction);
					lightData.direction.normalize();
				}
				if (lightData.type == Light.POINT || lightData.type == Light.SPOT)
				{
					var matrix:Matrix4=_absoluteMatrix;
					lightData.position.x=matrix.m30;
					lightData.position.y=matrix.m31;
					lightData.position.z=matrix.m32;
				}				
				sceneManager.registerNodeForRendering (this, LIGHT);
				super.onPreRender ();
			}
		}
		override public function render () : void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			if ( ! driver) return;
			
			driver.addLight (lightData);
			
			if(debug)
			{
				driver.setTransformWorld(_absoluteMatrix);
				driver.draw3DBox(box,lightData.diffuseColor.color);
			}
		}
		override public function getBoundingBox () : AABBox3D
		{
			return box;
		}
	}
}

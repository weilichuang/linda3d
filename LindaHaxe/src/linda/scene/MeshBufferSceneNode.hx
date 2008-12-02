package linda.scene;

	import flash.Vector;
	
	import linda.math.Vector3;
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.Mesh;
	import linda.mesh.MeshManipulator;
	import linda.video.IVideoDriver;
	/**
	 * only one MeshBuffer
	 */
	class MeshBufferSceneNode extends SceneNode
	{
		private var meshBuffer:MeshBuffer;
		private var useDefaultMaterial:Bool ;
		private var material:Material;
		/**
		 * 
		 * @param	mgr  SceneManager
		 * @param	?buffer MeshBuffer
		 * @param	?useDefaultMaterial
		 */
		public function new (mgr:SceneManager,?buffer : MeshBuffer = null,?useDefaultMaterial:Bool=true)
		{
			super (mgr);
			this.useDefaultMaterial = useDefaultMaterial;
			setMeshBuffer(buffer);
		}
		override public function destroy():Void
		{
			super.destroy();
			meshBuffer=null;
		}
		public  function clear () : Void
		{
			meshBuffer = null;
		}
		public  function setMeshBuffer (buffer : MeshBuffer) : Void
		{
			meshBuffer = buffer;
			setMaterial(useDefaultMaterial);
		}
		private inline function setMaterial(value:Bool):Void 
		{
			material = null;
			if (meshBuffer!=null)
			{
				if (value)
				{
					material = meshBuffer.material;
				}else
				{
					material = meshBuffer.material.clone();
				}
			}
		}
		public function setUseDefaultMaterial(value:Bool):Void 
		{
			useDefaultMaterial = value;
				
			setMaterial(useDefaultMaterial);
		}
		public function getUseDefaultMaterial():Bool 
		{
			return useDefaultMaterial;
		}
		public function getMeshBuffer () : MeshBuffer
		{
			return meshBuffer;
		}
		override public function onRegisterSceneNode() : Void
		{
			if (visible)
			{
				if (meshBuffer.material.transparenting)
				{
					sceneManager.registerNodeForRendering(this, SceneNode.TRANSPARENT);
				}else
				{
					sceneManager.registerNodeForRendering(this, SceneNode.SOLID);
				}
				super.onRegisterSceneNode();
			}
		}
		override public function render() : Void
		{
			if (meshBuffer == null) return;
			
			var driver : IVideoDriver = sceneManager.getVideoDriver();
			driver.setTransformWorld(_absoluteMatrix);
			driver.setMaterial(material);
			driver.drawMeshBuffer(meshBuffer);

			if(debug)
			{
				driver.draw3DBox(meshBuffer.boundingBox,driver.getDebugColor());
			}
		}
		override  public function getBoundingBox () : AABBox3D
		{
			return meshBuffer.boundingBox;
		}
		override  public function getMaterial (?i : Int = 0) : Material
		{
			return material;
		}
		override public function getMaterialCount () : Int
		{
			return 1;
		}
	}

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
		public function new (mgr:SceneManager,?buffer : MeshBuffer = null)
		{
			super (mgr);
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
		}
		public function getMeshBuffer () : MeshBuffer
		{
			return meshBuffer;
		}
		override public function onRegisterSceneNode() : Void
		{
			if (visible && meshBuffer!=null)
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
			var driver : IVideoDriver = sceneManager.getVideoDriver();

			driver.setTransformWorld(_absoluteMatrix);

			driver.setMaterial(meshBuffer.material);
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
			if (meshBuffer == null) return null;
			return meshBuffer.material;
		}
		override public function getMaterialCount () : Int
		{
			return 1;
		}
	}

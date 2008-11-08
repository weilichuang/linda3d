package mini3d.scene
{
	import mini3d.core.Material;
	import mini3d.math.AABBox3D;
	import mini3d.math.Vector3D;
	import mini3d.mesh.IMeshBuffer;
	import mini3d.mesh.Mesh;
	import mini3d.render.RenderManager;
	public class MeshSceneNode extends SceneNode
	{
		private var materials : Array;
		private var mesh : Mesh;
		public function MeshSceneNode (mesh : Mesh = null, pos : Vector3D = null, rotation : Vector3D = null, scale : Vector3D = null)
		{
			super (pos, rotation, scale);
			materials = new Array ();
			setMesh (mesh);
		}
		override public function destroy():void
		{
			super.destroy();
			materials=null;
			mesh=null;
		}
		public function setMesh (m : Mesh) : void
		{
			if(m)
			{
				mesh = m;
				cloneMaterials ();
			}
			
		}
		public function getMesh () :Mesh
		{
			return mesh;
		}
		public function cloneMaterials () : void
		{
			materials = [];
			if (mesh)
			{
				var mb : IMeshBuffer;
				var count:int=mesh.getMeshBufferCount ();
				for (var i : int = 0; i < count; i+=1)
				{
					mb = mesh.getMeshBuffer (i);
					if (mb) materials.push (mb.getMaterial().clone());
				}
			}
		}

		override public function onPreRender () : void
		{
			if (visible)
			{
				sceneManager.registerNodeForRendering (this, SceneNode.NODE);
				super.onPreRender ();
			}
		}
		override public function render () : void
		{
            var driver : RenderManager = sceneManager.getRenderManager ();
			if ( ! mesh || ! driver) return;
            
			driver.setTransformWorld (_absoluteMatrix);
			
			var mb : IMeshBuffer;
			var len:int=mesh.getMeshBufferCount ();
			for (var i : int = 0; i < len; i+=1)
			{
				mb = mesh.getMeshBuffer (i);
				if (mb)
				{
					driver.setMaterial (materials[i]);
					driver.drawMeshBuffer(container,mb);
				}
			}
		}
		override public function getBoundingBox () : AABBox3D
		{
			if (mesh)
			{
				return  mesh.getBoundingBox ();
			}
			return null;
		}
		override public function getMaterial (i : int = 0) : Material
		{
			return materials [i];
		}
		override public function getMaterialCount () : int
		{
			return materials.length;
		}
	}
}

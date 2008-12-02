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
	class MeshSceneNode extends SceneNode
	{
		private var materials : Vector<Material>;
		private var mesh : IMesh;
		public function new (mgr:SceneManager,?mesh : IMesh = null)
		{
			super (mgr);
			materials = new Vector<Material> ();
			setMesh (mesh);
		}
		override public function destroy():Void
		{
			super.destroy();
			materials=null;
			mesh=null;
		}
		public  function clear () : Void
		{
			mesh = null;
			materials.length = 0;
		}
		public  function setMesh (m : IMesh) : Void
		{
			if(m!=null)
			{
				mesh = m;
				cloneMaterials();
			}
		}
		public function getMesh () : IMesh
		{
			return mesh;
		}
		public function cloneMaterials():Void
		{
			materials.length = 0;
			if (mesh!=null)
			{
				var mb : MeshBuffer;
				var count:Int=mesh.getMeshBufferCount();
				for (i in 0...count)
				{
					mb = mesh.getMeshBuffer(i);
					materials.push(mb.material.clone());
				}
			}
		}
		override public function onRegisterSceneNode() : Void
		{
			if (visible)
			{
				var len:Int = materials.length;
				var mt : Material;
				var transparentCount:Int = 0;
				var solidCount:Int = 0;
				for ( i in 0...len)
				{
					mt = materials [i];
					if (mt.transparenting) 
					{
						transparentCount++;
					}else 
					{
						solidCount++;
					}

					if (solidCount>0 && transparentCount>0)
						break;
				}
				
				if (transparentCount > 0)
				{
					sceneManager.registerNodeForRendering(this, SceneNode.TRANSPARENT);
				}
				if ( solidCount > 0)
				{
					sceneManager.registerNodeForRendering(this, SceneNode.SOLID);
				}
				super.onRegisterSceneNode();
			}
		}
		override public function render() : Void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver();
			if ( mesh==null) return;

			driver.setTransformWorld(_absoluteMatrix);
			
			var mb : MeshBuffer;
			var len:Int=mesh.getMeshBufferCount();
			for (i in 0...len)
			{
				mb = mesh.getMeshBuffer(i);
				if (mb!=null)
				{
					driver.setMaterial(materials[i]);
					driver.drawMeshBuffer(mb);
				}
			}
			if(debug)
			{
				driver.draw3DBox(getBoundingBox(),driver.getDebugColor());
			}
		}
		override  public function getBoundingBox () : AABBox3D
		{
			if (mesh!=null)
			{
				return mesh.getBoundingBox ();
			}
			return null;
		}
		override  public function getMaterial (?i : Int = 0) : Material
		{
			if (i < 0 || i >= materials.length) return null;
			return materials[i];
		}
		override  public function getMaterialCount () : Int
		{
			return materials.length;
		}
	}

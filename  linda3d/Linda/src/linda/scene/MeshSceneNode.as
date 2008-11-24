package linda.scene
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.Mesh;
	import linda.mesh.utils.MeshManipulator;
	import linda.video.IVideoDriver;
	public class MeshSceneNode extends SceneNode
	{
		private var materials : Vector.<Material>;
		private var mesh : IMesh;
		public function MeshSceneNode (mgr:SceneManager,mesh : IMesh = null)
		{
			super (mgr);
			materials = new Vector.<Material> ();
			setMesh (mesh);
		}
		override public function destroy():void
		{
			super.destroy();
			materials=null;
			mesh=null;
		}
		public function clear () : void
		{
			mesh = null;
			materials = new Vector.<Material>();
		}
		public function setMesh (m : IMesh) : void
		{
			if(m)
			{
				mesh = m;
				cloneMaterials();
			}
		}
		public function getMesh () : IMesh
		{
			return mesh;
		}
		public function cloneMaterials():void
		{
			materials=new Vector.<Material>();
			if (mesh)
			{
				var mat : Material;
				var mb : MeshBuffer;
				var count:int=mesh.getMeshBufferCount ();
				for (var i : int = 0; i < count; i+=1)
				{
					mb = mesh.getMeshBuffer (i);
					if (mb) mat = mb.material;
					materials.push (mat.clone());
				}
			}
		}
		override public function onPreRender () : void
		{
			if (visible)
			{
				var len:int=materials.length;
				var transparent:Boolean=false;
				var mt : Material;
				for (var i : int = 0; i < len; i+=1)
				{
					mt = materials [i];
					if (mt.transparenting)
					{
						transparent = true;
						break;
					}
				}
				if (transparent)
				{
					sceneManager.registerNodeForRendering (this, TRANSPARENT);
				} else
				{
					sceneManager.registerNodeForRendering (this, SOLID);
				}
				super.onPreRender ();
			}
		}
		override public function render () : void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			if ( ! mesh || ! driver) return;

			driver.setTransformWorld (_absoluteMatrix);
			
			var mb : MeshBuffer;
			var material : Material;
			var len:int=mesh.getMeshBufferCount ();
			for (var i : int = 0; i < len; i+=1)
			{
				mb = mesh.getMeshBuffer (i);
				if (mb)
				{
					material = materials [i];
					driver.setMaterial (material);
					driver.drawMeshBuffer(mb);
				}
			}
			if(debug)
			{
				driver.draw3DBox(getBoundingBox(),driver.getDebugColor());
			}
		}
		override public function getBoundingBox () : AABBox3D
		{
			if (mesh)
			{
				return mesh.getBoundingBox ();
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
		
		public function localToGlobal():IMesh
		{
			var clone:IMesh;
			//首先更新一下坐标
			updateAbsoluteMatrix();
			
			if(mesh)
			{
			    clone=MeshManipulator.cloneMesh(mesh);
			
			    var absolute:Matrix4=getAbsoluteMatrix();
			
			    var len:int=clone.getMeshBufferCount();
			    var buffer:MeshBuffer;
			    var vertex:Vertex;
			    for(var i:int=0;i<len;i+=1)
			    {
				    buffer=clone.getMeshBuffer(i);
				    var blen:int=buffer.vertices.length;
				    for(var j:int=0;j<blen;j+=1)
				    {
					    vertex=buffer.getVertex(j);
					    absolute.transformVertex(vertex);
				    }
			    }
			}
			if(clone==null) clone=new Mesh();
			
			var child:MeshSceneNode;
			var childClone:IMesh;
			len=children.length;
			for(i=0;i<len;i+=1)
			{
				child=children[i] as MeshSceneNode;
				if(child)
				{
					childClone=child.localToGlobal();
					clone.appendMesh(childClone);
				}
			}
			return clone;
		}
	}
}

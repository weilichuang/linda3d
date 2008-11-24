package linda.mesh.animation
{
	import __AS3__.vec.Vector;
	
	import linda.math.AABBox3D;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	public class AnimatedMesh implements IAnimateMesh
	{
		public var boundingBox : AABBox3D;
		public var meshes : Vector.<IMesh>;
		public var type : int = 0;
		public var name:String;
		public function AnimatedMesh ()
		{
			type=AnimatedMeshType.AMT_MD2;
			name="";
			boundingBox = new AABBox3D ();
			meshes = new Vector.<IMesh> ();
		}
		public function getFrameCount () : int
		{
			return meshes.length;
		}
		public function getMesh (frame : int, detailLevel : int = 255, startFrameLoop : int = - 1, endFrameLoop : int = - 1) : IMesh
		{
			if (meshes.length == 0 || frame < 0) return null;
			return meshes [frame];
		}
		public function addMesh (mesh : IMesh) : void
		{
			if (!mesh) return;
			meshes.push (mesh);
		}
		public function recalculateBoundingBox () : void
		{
			if (meshes.length > 0)
			{
				var mesh:IMesh=meshes [0];
				var len:int=meshes.length;
				boundingBox.resetAABBox(mesh.getBoundingBox());
				for (var i : int = 1; i < len; i+=1)
				{
					mesh=meshes[i];
					boundingBox.addAABBox(mesh.getBoundingBox ());
				}
			}
		}
		public function setBoundingBox (box : AABBox3D) : void
		{
			boundingBox = box;
		}
		public function getBoundingBox () : AABBox3D
		{
			return boundingBox;
		}
		public function setMaterialFlag (flag : int, value : Boolean) : void
		{
		}
		public function getMeshType () : int
		{
			return type;
		}
		public function getMeshBuffer (nr : int) : MeshBuffer
		{
			return null;
		}
		public function getMeshBuffers():Vector.<MeshBuffer>
		{
			return null;
		}
		public function getMeshBufferCount () : int
		{
			return 0;
		}
		public function toString():String
		{
			return name;
		}
		public function appendMesh(m:IMesh):void
		{
		}
		public function getName():String
		{
			return name;
		}
	}
}

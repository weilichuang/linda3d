package mini3d.mesh
{
	import mini3d.math.AABBox3D;
	import mini3d.mesh.IMesh;
	import mini3d.mesh.IMeshBuffer;
	public class AnimatedMesh implements IAnimateMesh
	{
		public var boundingBox : AABBox3D;
		public var meshes : Array;
		public var type : int = 0;
		public var name:String='';
		public function AnimatedMesh ()
		{
			boundingBox = new AABBox3D ();
			meshes = new Array ();
			name='animatedMesh';
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
		public function appendMesh (mesh : IMesh) : void
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
				boundingBox.resetBox(mesh.getBoundingBox());
				for (var i : int = 1; i < len; i ++)
				{
					mesh=meshes[i];
					boundingBox.addBox (mesh.getBoundingBox ());
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
		public function getMeshBuffer (nr : int) : IMeshBuffer
		{
			return null;
		}
		public function getMeshBuffers():Array
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
		public function getName():String
		{
			return name;
		}
	}
}

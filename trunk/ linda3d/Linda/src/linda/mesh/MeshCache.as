package linda.mesh
{
	import __AS3__.vec.Vector;
	
	public class MeshCache
	{
		private var meshes : Vector.<IMesh>;
		private var meshCount:int;
		public function MeshCache ()
		{
			meshes=new Vector.<IMesh>();
			meshCount=0;
		}
		public function addMesh (mesh : IMesh) : void
		{
			meshes.push(mesh);
			meshCount++;
		}
		public function removeMesh (mesh : IMesh) :Boolean
		{
			if ( ! mesh) return false;
			var i:int=meshes.indexOf(mesh);			
			if(i == -1) return false;
			meshes.splice (i, 1);
			meshCount--;
			return true;
		}
		public function removeAll () : void
		{
			meshes.length=0;
		}
		public function getMeshCount () : int
		{
			return meshCount;
		}
		public function getMesh(num : int) : IMesh
		{
			if (num < 0 || num >= meshes.length) return null;
			return meshes [num];
		}
	}
}

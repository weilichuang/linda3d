package linda.mesh
{
	import __AS3__.vec.Vector;
	
	public class MeshCache
	{
		private var meshes : Vector.<IMesh>;
		public function MeshCache ()
		{
			meshes=new Vector.<IMesh>();
		}
		public function addMesh (mesh : IMesh) : void
		{
			meshes.push (mesh);
		}
		public function removeMesh (mesh : IMesh) :Boolean
		{
			if ( ! mesh) return false;
			var len:int=meshes.length;
			var _tmp:IMesh;
			for (var i:int = 0; i < len; i ++)
			{
				_tmp=meshes [i];
				if (_tmp == mesh)
				{
					meshes.splice (i, 1);
				 	return true;
				} 
			}
			return false;
		}
		public function removeAll () : void
		{
			meshes = new Vector.<IMesh>();
		}
		public function getMeshCount () : int
		{
			return meshes.length;
		}
		public function getMeshIndex (mesh : IMesh) : int
		{
			if ( ! mesh) return - 1;
			var len:int=meshes.length;
			var _tmp:IMesh;
			for (var i:int = 0; i < len; i ++)
			{
				_tmp=meshes [i];
				if (_tmp == mesh) return i;
			}
			return - 1;
		}
		public function getMeshAt (num : int) : IMesh
		{
			if (num < 0 || num >= meshes.length) return null;
			return meshes [num];
		}
	}
}

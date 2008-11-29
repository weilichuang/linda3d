package linda.mesh;

	import flash.Vector;
	
	class MeshCache
	{
		private var meshes : Vector<IMesh>;
		private var meshCount:Int;
		public function new ()
		{
			meshes=new Vector<IMesh>();
			meshCount=0;
		}
		public function addMesh (mesh : IMesh) : Void
		{
			meshes.push(mesh);
			meshCount++;
		}
		public function removeMesh (mesh : IMesh) :Bool
		{
			if ( ! mesh) return false;
			var i:Int=untyped meshes.indexOf(mesh);			
			if(i == -1) return false;
			meshes.splice (i, 1);
			meshCount--;
			return true;
		}
		public function removeAll () : Void
		{
			meshes.length = 0;
		}
		public function getMeshCount () : Int
		{
			return meshCount;
		}
		public function getMesh(num : Int) : IMesh
		{
			if (num < 0 || num >= meshes.length) return null;
			return meshes[num];
		}
	}


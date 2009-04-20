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
			meshes[meshCount] = mesh;
			meshCount++;
		}
		public function removeMesh (mesh : IMesh) :Bool
		{
			var i:Int=meshes.indexOf(mesh);			
			if (i == -1)
			{
				return false;
			}else
			{
				meshes.splice (i, 1);
				meshCount--;
				return true;
			}
		}
		public function removeAll () : Void
		{
			meshes.length = 0;
			meshCount = 0;
		}
		public function getMeshCount () : Int
		{
			return meshCount;
		}
		public function getMesh(num : Int) : IMesh
		{
			if ( num<0 || num >=meshCount) return null;
			return meshes[num];
		}
	}


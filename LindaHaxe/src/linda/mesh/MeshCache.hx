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
		public inline function removeMesh (mesh : IMesh) :Bool
		{
			if (!mesh)
			{
				return false;
			}else
			{
				var i:Int=untyped meshes.indexOf(mesh);			
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
		}
		public function removeAll () : Void
		{
			meshes.length = 0;
		}
		public inline function getMeshCount () : Int
		{
			return meshCount;
		}
		public inline function getMesh(num : Int) : IMesh
		{
			if (num < 0 || num >= meshes.length)
			{
				return null;
			}else
			{
				return meshes[num];
			}
			
		}
	}


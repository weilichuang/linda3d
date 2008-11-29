package linda.mesh.loader;
	import flash.utils.ByteArray;
	
	import linda.mesh.IMesh;
	import linda.mesh.animation.IAnimateMesh;
	
	class MeshLoader implements IMeshLoader
	{
		public function new()
		{
		}
		public function createMesh(data:ByteArray):IMesh
		{
			return null;
		}
		public function createAnimatedMesh(data:ByteArray):IAnimateMesh
		{
			return null;
		}
		//public function createSkinnedMesh(data:ByteArray):ISkinMesh
		//{
		//	return null;
		//}
		public function clear():Void
		{
			
		}

	}
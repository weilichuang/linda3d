package linda.mesh.loader;

import flash.utils.ByteArray;
import linda.mesh.IMesh;
import linda.mesh.IAnimatedMesh;
interface IMeshLoader
{
	function createMesh(data:ByteArray):IMesh;
	function createAnimatedMesh(data:ByteArray):IAnimatedMesh;
	//function createSkinnedMesh(data:ByteArray):ISkinnedMesh;
}

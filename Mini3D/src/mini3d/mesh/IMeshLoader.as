package mini3d.mesh
{
	import flash.utils.ByteArray;
	public interface IMeshLoader
	{
	   function createMesh(data:ByteArray):IMesh;
	   function createAnimatedMesh(data:ByteArray):IAnimateMesh;
	   function clear():void;
	}
}

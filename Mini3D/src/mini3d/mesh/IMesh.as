package mini3d.mesh
{
	import mini3d.math.AABBox3D;
	public interface IMesh
	{
		function getMeshBufferCount () : int;
		function getMeshBuffer (nr : int) : IMeshBuffer;
		function getMeshBuffers():Array;
		function getBoundingBox () : AABBox3D;
		function setBoundingBox (box : AABBox3D) : void;
		function setMaterialFlag (flag : int, value : Boolean) : void;
		function appendMesh(m:IMesh):void;
		function getName():String;
		function recalculateBoundingBox():void;
	}
}

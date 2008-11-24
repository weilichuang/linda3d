package linda.mesh
{
	import __AS3__.vec.Vector;
	
	import linda.math.AABBox3D;
	public interface IMesh
	{
		function getMeshBufferCount () : int;
		function getMeshBuffer (nr : int) : MeshBuffer;
		function getMeshBuffers():Vector.<MeshBuffer>;
		function getBoundingBox () : AABBox3D;
		function setBoundingBox (box : AABBox3D) : void;
		function setMaterialFlag (flag : int, value : Boolean) : void;
		function appendMesh(m:IMesh):void;
		function recalculateBoundingBox():void;
	}
}

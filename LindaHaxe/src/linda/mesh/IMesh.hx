package linda.mesh;

	import flash.Vector;
	import linda.math.AABBox3D;
	interface IMesh
	{
		function getMeshBufferCount () : Int;
		function getMeshBuffer (nr : Int) : MeshBuffer;
		function getMeshBuffers():Vector<MeshBuffer>;
		function getBoundingBox () : AABBox3D;
		function setBoundingBox (box : AABBox3D) : Void;
		function setMaterialFlag (flag : Int, value : Bool) : Void;
		function appendMesh(m:IMesh):Void;
		function recalculateBoundingBox():Void;
	}

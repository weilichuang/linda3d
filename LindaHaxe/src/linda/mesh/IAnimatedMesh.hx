package linda.mesh;

	import linda.mesh.IMesh;
	interface IAnimatedMesh implements IMesh
	{
		function getFrameCount () : Int;
		function getMesh (frame : Int, detailLevel : Int = 255, startFrameLoop : Int = - 1, endFrameLoop : Int = - 1) : IMesh;
		function getMeshType () : Int;
	}

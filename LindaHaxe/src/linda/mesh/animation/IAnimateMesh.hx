package linda.mesh.animation;

	import linda.mesh.IMesh;
	interface IAnimateMesh implements IMesh
	{
		function getFrameCount () : Int;
		function getMesh (frame : Int, ?detailLevel : Int = 255, ?startFrameLoop : Int = - 1, ?endFrameLoop : Int = - 1) : IMesh;
		function getMeshType () : Int;
	}

package mini3d.mesh
{
	public interface IAnimateMesh extends IMesh
	{
		function getFrameCount () : int;
		function getMesh (frame : int, detailLevel : int = 255, startFrameLoop : int = - 1, endFrameLoop : int = - 1) : IMesh;
		function getMeshType () : int;
	}
}

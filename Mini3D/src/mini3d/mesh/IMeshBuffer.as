package mini3d.mesh
{
	import mini3d.core.Material;
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	
	public interface IMeshBuffer
	{
		function getMaterial () : Material;
		function getVertices () : Array;
		function getVertexCount () : int;
		function getIndices () : Array;
		function getIndexCount () : int;
		function setBoundingBox (box : AABBox3D) : void;
		function getBoundingBox () : AABBox3D;
		function recalculateBoundingBox () : void;
		function getVertex(i:int):Vertex;
	}
}

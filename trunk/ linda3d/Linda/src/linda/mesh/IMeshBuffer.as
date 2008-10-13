package linda.mesh
{
	import __AS3__.vec.Vector;
	
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Vertex;
	
	public interface IMeshBuffer
	{
		function getMaterial () : Material;
		function getVertices () : Vector.<Vertex>;
		function getVertexCount () : int;
		function getIndices () : Vector.<int>;
		function getIndexCount () : int;
		function setBoundingBox (box : AABBox3D) : void;
		function getBoundingBox () : AABBox3D;
		function recalculateBoundingBox () : void;
		function getTriangleCount () : int;
		function setVertexColor (color : uint) : void
		function getVertex(i:int):Vertex;
	}
}

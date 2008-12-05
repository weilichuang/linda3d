package linda.video;

import flash.Vector;
import linda.math.Vertex4D;
import linda.material.Material;

interface ITriangleRenderer
{
	function setVector (target : Vector<UInt>, buffer : Vector<Float>) : Void;
	function setWidth(width:Int):Void;
	function setMaterial (material : Material) : Void;
	function drawIndexedTriangleList (vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void;
	function setPerspectiveCorrectDistance(?distance:Float=400.):Void;
	function setMipMapDistance(?distance:Float = 500.):Void;
	function setDistance(distance:Float):Void;
}

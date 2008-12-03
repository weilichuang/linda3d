package linda.video;

import flash.Vector;	
import linda.math.Vertex4D;

interface ILineRenderer 
{
    function setVector (target : Vector<UInt>, buffer : Vector<Float>) : Void;
	function setWidth(width:Int):Void;
	function drawIndexedLineList (vertices :Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void;
}
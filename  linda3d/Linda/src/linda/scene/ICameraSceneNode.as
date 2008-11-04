package linda.scene
{
	import linda.math.Matrix4;
	import linda.scene.ISceneNode;
	
	import flash.geom.Vector3D;
	
	public interface ICameraSceneNode extends ISceneNode
	{
		function getViewFrustum():ViewFrustum;
		function setTarget(t:Vector3D):void;
		function getTarget():Vector3D;
		function getUpVector():Vector3D;
		function setFOV(fov:Number):void;
		function getFOV():Number;
	    function setAspectRatio (asp : Number) : void
		function setNear (zn : int) : void;
		function setFar (zf : int) : void
		function getAspectRatio () : Number
		function getNear () : Number
		function getFar () : Number
		function getViewMatrix () : Matrix4;
		function getProjectionMatrix () : Matrix4;
		function getViewProjectionMatrix():Matrix4;
		function isOrthogonal () : Boolean;
		function setOrthogonal (ort : Boolean) : void;
		function recalculateProjectionMatrix () : void;
	}
}
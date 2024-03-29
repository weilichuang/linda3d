﻿package linda.mesh.loader
{
	import flash.utils.ByteArray;
	
	import linda.mesh.IMesh;
	import linda.mesh.animation.IAnimateMesh;
	public interface IMeshLoader
	{
	   function createMesh(data:ByteArray):IMesh;
	   function createAnimatedMesh(data:ByteArray):IAnimateMesh;
	   //function createSkinnedMesh(data:ByteArray):ISkinMesh;
	   function clear():void;
	}
}

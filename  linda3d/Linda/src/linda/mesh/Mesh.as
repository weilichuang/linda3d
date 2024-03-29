﻿package linda.mesh
{
	import linda.math.AABBox3D;
	public class Mesh implements IMesh
	{
		protected var meshBuffers : Vector.<MeshBuffer>;
		protected var boundingBox : AABBox3D;
		public function Mesh ()
		{
			meshBuffers = new Vector.<MeshBuffer> ();
			boundingBox = new AABBox3D ();
		}
		public function getMeshBufferCount () : int
		{
			return meshBuffers.length;
		}
		public function getMeshBuffer (nr : int) : MeshBuffer
		{
			return meshBuffers[nr];
		}
		public function getMeshBuffers():Vector.<MeshBuffer>
		{
			return meshBuffers;
		}
		public function removeMeshBuffer (buffer : MeshBuffer) : MeshBuffer
		{
			if(!buffer) return null;
			var idx:int = meshBuffers.indexOf(buffer);
			meshBuffers.splice(idx,1);
			return buffer;
		}
		public function removeMeshBufferByIndex (i : int) : MeshBuffer
		{
			if (i < 0 || i >= meshBuffers.length) return null;
			var buffer : MeshBuffer = meshBuffers.splice (i, 1)[0];
			return buffer;
		}
		public function setBoundingBox (box : AABBox3D) : void
		{
			boundingBox = box;
		}
		public function getBoundingBox () : AABBox3D
		{
			return boundingBox;
		}
		public function recalculateBoundingBox () : void
		{
			var len:int=meshBuffers.length;
			var buffer:MeshBuffer;
			if (len > 0)
			{
				buffer=meshBuffers [0];
				boundingBox.resetAABBox (buffer.boundingBox);
				for (var i:int = 1; i < len; i+=1)
				{
					buffer=meshBuffers [i];
					boundingBox.addAABBox (buffer.boundingBox);
				}
			}
		}
		public function setMaterialFlag (flag : int, value : Boolean) : void
		{
			var len:int=meshBuffers.length;
			var buffer:MeshBuffer;
			for (var i:int = 0; i < len; i+=1)
			{
				buffer = meshBuffers [i];
				buffer.material.setFlag (flag, value);
			}
		}
		public function addMeshBuffer (buf : MeshBuffer) : void
		{
			if(buf)
			{
				meshBuffers.push (buf);
			}
		}
		
		public function appendMesh(m:IMesh):void
		{
			var len:int=m.getMeshBufferCount();
			var buffer:MeshBuffer;
			for(var i:int =0; i < len; i+=1)
			{
				buffer=m.getMeshBuffer(i);
				meshBuffers.push(buffer);
			}
		}
	}
}

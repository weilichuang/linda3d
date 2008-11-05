package linda.mesh
{
	import linda.math.AABBox3D;
	public class Mesh implements IMesh
	{
		public var meshBuffers : Vector.<IMeshBuffer>;
		public var boundingBox : AABBox3D;
		public function Mesh ()
		{
			meshBuffers = new Vector.<IMeshBuffer> ();
			boundingBox = new AABBox3D ();
		}
		public function getMeshBufferCount () : int
		{
			return meshBuffers.length;
		}
		public function getMeshBuffer (nr : int) : IMeshBuffer
		{
			return meshBuffers[nr];
		}
		public function getMeshBuffers():Vector.<IMeshBuffer>
		{
			return meshBuffers;
		}
		public function removeMeshBuffer (buffer : IMeshBuffer) : IMeshBuffer
		{
			if(!buffer) return null;
			var idx:int = meshBuffers.indexOf(buffer);
			meshBuffers.splice(idx,1);
			return buffer;
		}
		public function removeMeshBufferByIndex (i : int) : IMeshBuffer
		{
			if (i < 0 || i >= meshBuffers.length) return null;
			var buffer : IMeshBuffer = meshBuffers.splice (i, 1)[0];
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
			var buffer:IMeshBuffer;
			if (len > 0)
			{
				buffer=meshBuffers [0];
				boundingBox.resetAABBox (buffer.getBoundingBox ());
				for (var i:int = 1; i < len; i+=1)
				{
					buffer=meshBuffers [i];
					boundingBox.addAABBox (buffer.getBoundingBox ());
				}
			}
		}
		public function setMaterialFlag (flag : int, value : Boolean) : void
		{
			var len:int=meshBuffers.length;
			var buffer:IMeshBuffer;
			for (var i:int = 0; i < len; i+=1)
			{
				buffer = meshBuffers [i];
				buffer.getMaterial().setFlag (flag, value);
			}
		}
		public function getTriangleCount () : int
		{
			var triangleCount : int;
			var len:int=meshBuffers.length;
			var buffer:IMeshBuffer;
			for (var i:int = 0; i < len; i+=1)
			{
				buffer = meshBuffers [i];
				triangleCount += buffer.getTriangleCount ();
			}
			return triangleCount;
		}
		public function addMeshBuffer (buf : IMeshBuffer) : void
		{
			if (!buf) return;
			meshBuffers.push (buf);
		}
		
		public function appendMesh(m:IMesh):void
		{
			var len:int=m.getMeshBufferCount();
			var buffer:IMeshBuffer;
			for(var i:int =0; i < len; i+=1)
			{
				buffer=m.getMeshBuffer(i);
				meshBuffers.push(buffer);
			}
		}
	}
}

package linda.mesh
{
	import linda.math.AABBox3D;
	public class Mesh implements IMesh
	{
		public var meshBuffers : Vector.<IMeshBuffer>;
		public var boundingBox : AABBox3D;
		public var name : String ;
		private static var _id:int=0;
		public function Mesh ()
		{
			meshBuffers = new Vector.<IMeshBuffer> ();
			boundingBox = new AABBox3D ();
			name="mesh"+(_id++);
		}
		public function getMeshBufferCount () : int
		{
			return meshBuffers.length;
		}
		public function getMeshBuffer (nr : int) : IMeshBuffer
		{
			return meshBuffers [nr];
		}
		public function getMeshBuffers():Vector.<IMeshBuffer>
		{
			return meshBuffers;
		}
		public function removeMeshBuffer (buffer : IMeshBuffer) : Boolean
		{
			var len : int = meshBuffers.length;
			for (var i:int = 0; i < len; i ++)
			{
				if (buffer == meshBuffers [i])
				{
					meshBuffers.splice (i, 1);
					return true;
				}
			}
			return false;
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
				boundingBox.resetFromAABBox3D (buffer.getBoundingBox ());
				for (var i:int = 1; i < len; i ++)
				{
					buffer=meshBuffers [i];
					boundingBox.addInternalBox (buffer.getBoundingBox ());
				}
			}
		}
		public function setMaterialFlag (flag : int, value : Boolean) : void
		{
			var len:int=meshBuffers.length;
			var buffer:IMeshBuffer;
			for (var i:int = 0; i < len; i ++)
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
			for (var i:int = 0; i < len; i ++)
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
			for(var i:int =0; i < len; i++)
			{
				buffer=m.getMeshBuffer(i);
				meshBuffers.push(buffer);
			}
		}
		public function getName():String
		{
			return name;
		}
		public function toString():String
		{
			return name;
		}
	}
}

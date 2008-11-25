package mini3d.mesh
{
	import mini3d.math.AABBox3D;
	public class Mesh implements IMesh
	{
		private var meshBuffers : Array;
		private var boundingBox : AABBox3D;
		private var name : String ;
		public function Mesh ()
		{
			meshBuffers = new Array ();
			boundingBox = new AABBox3D ();
			name="";
		}
		public function getMeshBufferCount () : int
		{
			return meshBuffers.length;
		}
		public function getMeshBuffer (nr : int) : MeshBuffer
		{
			return meshBuffers [nr];
		}
		public function getMeshBuffers():Array
		{
			return meshBuffers;
		}
		public function removeMeshBuffer (buffer : MeshBuffer) : Boolean
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
				boundingBox.resetBox (buffer.boundingBox);
				for (var i:int = 1; i < len; i ++)
				{
					buffer=meshBuffers [i];
					boundingBox.addBox (buffer.boundingBox);
				}
			}
		}
		public function setMaterialFlag (flag : int, value : Boolean) : void
		{
			var len:int=meshBuffers.length;
			var buffer:MeshBuffer;
			for (var i:int = 0; i < len; i ++)
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
		public function setName(n:String):void
		{
			this.name=n;
		}
		public function toString():String
		{
			return name;
		}
	}
}

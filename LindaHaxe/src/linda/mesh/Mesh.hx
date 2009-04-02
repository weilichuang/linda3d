package linda.mesh;
    import flash.Vector;
	import linda.math.AABBox3D;
	class Mesh implements IMesh
	{
		public var meshBuffers : Vector<MeshBuffer>;
		public var boundingBox : AABBox3D;
		public function new ()
		{
			meshBuffers = new Vector<MeshBuffer> ();
			boundingBox = new AABBox3D ();
		}
		public function getMeshBufferCount () : Int
		{
			return meshBuffers.length;
		}
		public function getMeshBuffer (nr : Int) : MeshBuffer
		{
			return meshBuffers[nr];
		}
		public function getMeshBuffers():Vector<MeshBuffer>
		{
			return meshBuffers;
		}
		public function removeMeshBuffer (buffer : MeshBuffer) : MeshBuffer
		{
			var idx:Int = meshBuffers.indexOf(buffer);
			if (idx != -1)
			{
				meshBuffers.splice(idx,1);
			    return buffer;
			}else
			{
				return null;
			}
		}
		public function removeMeshBufferByIndex (i : Int) : MeshBuffer
		{
			if (i < 0 || i >= meshBuffers.length) return null;
			var buffer : MeshBuffer = meshBuffers.splice (i, 1)[0];
			return buffer;
		}
		public function setBoundingBox (box : AABBox3D) : Void
		{
			boundingBox = box;
		}
		public function getBoundingBox () : AABBox3D
		{
			return boundingBox;
		}
		public function recalculateBoundingBox () : Void
		{
			var len:Int=meshBuffers.length;
			var buffer:MeshBuffer;
			if (len > 0)
			{
				buffer=meshBuffers [0];
				boundingBox.resetAABBox (buffer.boundingBox);
				for (i in 0...len)
				{
					buffer=meshBuffers[i];
					boundingBox.addAABBox (buffer.boundingBox);
				}
			}
		}
		public function setMaterialFlag (flag : Int, value : Bool) : Void
		{
			var len:Int=meshBuffers.length;
			var buffer:MeshBuffer;
			for (i in 0...len)
			{
				buffer = meshBuffers [i];
				buffer.material.setFlag (flag, value);
			}
		}
		public function addMeshBuffer (buf : MeshBuffer) : Void
		{
			if(buf!=null)
			{
				meshBuffers.push (buf);
			}
		}
		
		public function appendMesh(m:IMesh):Void
		{
			var len:Int=m.getMeshBufferCount();
			var buffer:MeshBuffer;
			for(i in 0...len)
			{
				meshBuffers.push(m.getMeshBuffer(i));
			}
		}
	}

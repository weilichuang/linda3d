package mini3d.mesh.md2
{
	import mini3d.core.Material;
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	import mini3d.mesh.AnimatedMeshType;
	import mini3d.mesh.IAnimateMesh;
	import mini3d.mesh.IMesh;
	import mini3d.mesh.IMeshBuffer;
	import mini3d.mesh.MeshBuffer;
	public class AnimatedMeshMD2 implements IAnimateMesh
	{
		private static const FRAME_SHIFT : int = 2;
		private static const FRAME_SHIFT_RECIPROCAL : Number = 1 / (1 << FRAME_SHIFT );
		public var interpolateBuffer : MeshBuffer;
		public var frameList : Array;
		public var boxList : Array;
		public var frameData : Array;
		public var frameCount : int;
		public var name:String='';
		public function AnimatedMeshMD2 ()
		{
			interpolateBuffer = new MeshBuffer ();
			frameList = new Array ();
			boxList = new Array ();
			frameData = new Array ();
			name='md2' ;
		}
		public function getFrameList () : Array
		{
			return frameList;
		}
		public function getBoxList () : Array
		{
			return boxList;
		}
		public function getFrameData () : Array
		{
			return frameData;
		}
		public function getInterpolateBuffer () : MeshBuffer
		{
			return interpolateBuffer;
		}
		public function getFrame(frame : MD2Frame) : MD2Frame
		{
			var data : MD2Frame = new MD2Frame();
			data.begin = frame.begin << FRAME_SHIFT;
			data.end = frame.end << FRAME_SHIFT;
			data.fps = frame.fps << FRAME_SHIFT;
			return data;
		}
		public function getMeshBuffer (i : int) : IMeshBuffer
		{
			return interpolateBuffer;
		}
		public function getMeshBuffers():Array
		{
			return null;
		}
		public function getMaterial () : Material
		{
			return interpolateBuffer.getMaterial ();
		}
		public function getVertices () : Array
		{
			return interpolateBuffer.getVertices ();
		}
		public function getVertexCount () : int
		{
			return interpolateBuffer.getVertexCount ();
		}
		public function getMeshBufferCount () : int
		{
			return 1;
		}
		public function getIndices () : Array
		{
			return interpolateBuffer.getIndices ();
		}
		public function getIndexCount () : int
		{
			return interpolateBuffer.getIndexCount ();
		}
		public function getAnimationCount () : int
		{
			return frameData.length;
		}
		public function getFrameCount () : int
		{
			return frameCount << FRAME_SHIFT;
		}
		public function getAnimationName (i : int) : String
		{
			if (i < 0 || i >= frameData.length) return null;
			return frameData [i].name;
		}
		private var _tmpBox:AABBox3D=new AABBox3D();
		public function updateInterpolationBuffer (frame : int, startFrameLoop : int, endFrameLoop : int) : void
		{
			var firstFrame : int, secondFrame : int;
			var div : Number;
			if (endFrameLoop - startFrameLoop == 0)
			{
				firstFrame = frame >> FRAME_SHIFT;
				secondFrame = frame >> FRAME_SHIFT;
				div = 1;
			} 
			else
			{
				//key frames
				var s : int = startFrameLoop >> FRAME_SHIFT;
				var e : int = endFrameLoop >> FRAME_SHIFT;
				firstFrame = frame >> FRAME_SHIFT;
				secondFrame = (firstFrame + 1 > e) ? s : firstFrame + 1;
				frame &= (1 << FRAME_SHIFT) - 1;
				div = frame * FRAME_SHIFT_RECIPROCAL;
			}
			var targetArray : Array = interpolateBuffer.getVertices ();
			var firstArray : Array = frameList [firstFrame];
			var secondArray : Array = frameList [secondFrame];
			var count : int = frameList [firstFrame].length;
			for (var i : int = 0; i < count; i ++)
			{
				var target : Vertex = targetArray [i];
				var first : Vertex = firstArray [i];
				var second : Vertex = secondArray [i];
				
				target.x = (second.x - first.x) * div + first.x;
				target.y = (second.y - first.y) * div + first.y;
				target.z = (second.z - first.z) * div + first.z;

			}
			//update bounding box
			var secondBox:AABBox3D=boxList [secondFrame];
			var firstBox:AABBox3D=boxList [firstFrame];
			var inv : Number = 1.0 - div;
			_tmpBox.minX = firstBox.minX * inv + secondBox.minX * div;
			_tmpBox.minY = firstBox.minY * inv + secondBox.minY * div;
			_tmpBox.minZ = firstBox.minZ * inv + secondBox.minZ * div;
			_tmpBox.maxX = firstBox.maxX * inv + secondBox.maxX * div;
			_tmpBox.maxY = firstBox.maxY * inv + secondBox.maxY * div;
			_tmpBox.maxZ = firstBox.maxZ * inv + secondBox.maxZ * div;
			
			interpolateBuffer.setBoundingBox (_tmpBox);
		}
		// returns the animated mesh based on a detail level. 0 is the lowest, 255 the highest detail. Note, that some Meshes will ignore the detail level.
		public function getMesh (frame : int, detailLevel : int = 255, startFrameLoop : int = - 1, endFrameLoop : int = - 1) : IMesh
		{
			if (frame >= getFrameCount () - 1) frame = (frame % getFrameCount ());
			if (startFrameLoop == - 1 && endFrameLoop == - 1)
			{
				startFrameLoop = 0;
				endFrameLoop = getFrameCount () - 1;
			}
			updateInterpolationBuffer (frame, startFrameLoop, endFrameLoop);
			return this;
		}
		public function setBoundingBox (box : AABBox3D) : void
		{
			interpolateBuffer.setBoundingBox (box);
		}
		public function getBoundingBox () : AABBox3D
		{
			return interpolateBuffer.getBoundingBox ();
		}
		public function setMaterialFlag (flag : int, value : Boolean) : void
		{
			interpolateBuffer.getMaterial ().setFlag (flag, value);
		}
		public function setMaterial (mat : Material) : void
		{
			interpolateBuffer.setMaterial(mat);
		}
		public function getMeshType () : int
		{
			return AnimatedMeshType.AMT_MD2;
		}
		public function toString():String
		{
			return name;
		}
		public function appendMesh(m:IMesh):void
		{
		}
		public function getName():String
		{
			return name;
		}
		public function recalculateBoundingBox () : void
		{
		}
	}
}

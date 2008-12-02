package linda.mesh.animation;

	import flash.Vector;
	
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	class AnimatedMeshMD2 implements IAnimateMesh
	{
		private static inline var FRAME_SHIFT : Int = 2;
		private static inline var FRAME_SHIFT_RECIPROCAL : Float = 1 / (1 << FRAME_SHIFT );
		
		public var interpolateBuffer : MeshBuffer;
		public var frameList         : Vector<Vector<Vertex>>;
		public var boxList           : Vector<AABBox3D>;
		public var frameData         : Vector<MD2Frame>;
		public var frameCount        : Int;
		public var name              : String;
		
		public function new ()
		{
			interpolateBuffer = new MeshBuffer ();
			frameList = new Vector<Vector<Vertex>> ();
			boxList = new Vector<AABBox3D> ();
			frameData = new Vector<MD2Frame> ();
			name = '';
		}
		public function getFrameList () : Vector<Vector<Vertex>>
		{
			return frameList;
		}
		public function getBoxList () : Vector<AABBox3D>
		{
			return boxList;
		}
		public function getFrameData () : Vector<MD2Frame>
		{
			return frameData;
		}
		public function getInterpolateBuffer () : MeshBuffer
		{
			return interpolateBuffer;
		}
		public inline function getFrame(frame : MD2Frame) : MD2Frame
		{
			var data : MD2Frame = new MD2Frame();
			data.begin = frame.begin << FRAME_SHIFT;
			data.end = frame.end << FRAME_SHIFT;
			data.fps = frame.fps << FRAME_SHIFT;
			return data;
		}
		public function getMeshBuffer(i : Int) : MeshBuffer
		{
			return interpolateBuffer;
		}
		public function getMeshBuffers():Vector<MeshBuffer>
		{
			return null;
		}
		public function getMaterial() : Material
		{
			return interpolateBuffer.material;
		}
		public function getVertices() : Vector<Vertex>
		{
			return interpolateBuffer.vertices;
		}
		public function getVertexCount() : Int
		{
			return interpolateBuffer.vertices.length;
		}
		public function getMeshBufferCount() : Int
		{
			return 1;
		}
		public function getIndices() : Vector<Int>
		{
			return interpolateBuffer.indices;
		}
		public function getIndexCount() : Int
		{
			return interpolateBuffer.indices.length;
		}
		public function getAnimationCount() : Int
		{
			return frameData.length;
		}
		public function getFrameCount() : Int
		{
			return frameCount << FRAME_SHIFT;
		}
		public function getAnimationName (i : Int) : String
		{
			if (i < 0 || i >= frameData.length) return null;
			return frameData [i].name;
		}
		
		public inline function updateInterpolationBuffer (frame : Int, startFrameLoop : Int, endFrameLoop : Int) : Void
		{
			var firstFrame : Int, secondFrame : Int;
			var div : Float;
			if (endFrameLoop - startFrameLoop == 0)
			{
				firstFrame = frame >> FRAME_SHIFT;
				secondFrame = frame >> FRAME_SHIFT;
				div = 1;
			} 
			else
			{
				//key frames
				var s : Int = startFrameLoop >> FRAME_SHIFT;
				var e : Int = endFrameLoop >> FRAME_SHIFT;
				firstFrame = frame >> FRAME_SHIFT;
				secondFrame = (firstFrame + 1 > e) ? s : firstFrame + 1;
				frame &= (1 << FRAME_SHIFT) - 1;
				div = frame * FRAME_SHIFT_RECIPROCAL;
			}
			var targetArray :Vector<Vertex> = interpolateBuffer.vertices;
			var firstArray : Vector<Vertex> = frameList [firstFrame];
			var secondArray : Vector<Vertex> = frameList [secondFrame];
			var count : Int = frameList[firstFrame].length;
			for ( i in 0...count)
			{
				var target : Vertex = targetArray [i];
				var first  : Vertex = firstArray [i];
				var second : Vertex = secondArray [i];
				
				target.x = (second.x - first.x) * div + first.x;
				target.y = (second.y - first.y) * div + first.y;
				target.z = (second.z - first.z) * div + first.z;
				
				target.nx=(second.nx-first.nx)*div+first.nx;
				target.ny=(second.ny-first.ny)*div+first.ny;
				target.nz=(second.nz-first.nz)*div+first.nz;
				
			}
			//update bounding box
			interpolateBuffer.boundingBox.interpolate(boxList[secondFrame], boxList[firstFrame], div);
		}
		// returns the animated mesh based on a detail level. 0 is the lowest, 255 the highest detail. Note, that some Meshes will ignore the detail level.
		public function getMesh (frame : Int, ?detailLevel : Int = 255, ?startFrameLoop : Int = - 1, ?endFrameLoop : Int = - 1) : IMesh
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
		public function setBoundingBox (box : AABBox3D) : Void
		{
			interpolateBuffer.boundingBox=box;
		}
		public function getBoundingBox () : AABBox3D
		{
			return interpolateBuffer.boundingBox;
		}
		public function setMaterialFlag (flag : Int, value : Bool) : Void
		{
			interpolateBuffer.material.setFlag (flag, value);
		}
		public function setMaterial (mat : Material) : Void
		{
			interpolateBuffer.material = mat;
		}
		public function getMeshType () : Int
		{
			return AnimatedMeshType.AMT_MD2;
		}
		public function toString():String
		{
			return name;
		}
		public function appendMesh(m:IMesh):Void
		{
		}
		public function getName():String
		{
			return name;
		}
		public function recalculateBoundingBox () : Void
		{
		}
	}

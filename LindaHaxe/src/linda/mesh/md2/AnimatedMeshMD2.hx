package linda.mesh.md2;

	import flash.Lib;
	import flash.Vector;
	import linda.math.MathUtil;
	import linda.math.Vector3;
	
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.IAnimatedMesh;
	import linda.mesh.AnimatedMeshType;
	class AnimatedMeshMD2 implements IAnimatedMesh
	{
		private static inline var FRAME_SHIFT : Int = 2;
		private static inline var FRAME_SHIFT_RECIPROCAL : Float = 1 / (1 << FRAME_SHIFT );
		
		public var interpolateBuffer : MeshBuffer;
		
		// keyframe transformations
		public var frameTransforms:Vector<MD2KeyFrameTransform>;
		
		// keyframe vertex data
		public var frameList:Vector<Vector<MD2Vertex>>;

		// bounding boxes for each keyframe
		public var boxList           : Vector<AABBox3D>;
        
		// named animations
		public var animationData     : Vector<AnimationData>;
		
		public var numFrames         : Int;
		public var numTriangles      : Int;
		public var name              : String;
		
		public function new (?name:String="AnimatedMeshMD2")
		{
			this.name = name;
			
			interpolateBuffer = new MeshBuffer ();
			frameTransforms = new Vector<MD2KeyFrameTransform> ();
			boxList = new Vector<AABBox3D> ();
			animationData = new Vector<AnimationData> ();
			
			numFrames = 0;
			numTriangles = 0;
			
		}
		
		public inline function getFrame(frame : AnimationData) : AnimationData
		{
			var data : AnimationData = new AnimationData();
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
			return animationData.length;
		}
		public function getFrameCount() : Int
		{
			return numFrames << FRAME_SHIFT;
		}
		public function getAnimationName (i : Int) : String
		{
			if (i < 0 || i >= animationData.length) return null;
			return animationData [i].name;
		}
		
		private static var one:Vector3= new Vector3();
		private static var tow:Vector3= new Vector3();
		public function updateInterpolationBuffer (frame : Int, startFrameLoop : Int, endFrameLoop : Int) : Void
		{
			var firstFrame : Int, secondFrame : Int;
			var div : Float;
			var normalTable:Vector<Float>=VERTEX_NORMAL_TABLE;
			
			if (endFrameLoop == startFrameLoop)
			{
				firstFrame = frame >> FRAME_SHIFT;
				secondFrame = firstFrame;
				div = 1.0;
			} 
			else
			{
				//key frames
				var s : Int = startFrameLoop >> FRAME_SHIFT;
				var e : Int = endFrameLoop >> FRAME_SHIFT;
				
				firstFrame = frame >> FRAME_SHIFT;
				secondFrame = (firstFrame + 1 > e) ? s : firstFrame + 1;
				
				firstFrame = MathUtil.minInt(numFrames - 1, firstFrame);
				secondFrame = MathUtil.minInt(numFrames - 1, secondFrame);
				
				frame &= (1 << FRAME_SHIFT) - 1;
				div = frame * FRAME_SHIFT_RECIPROCAL;
			}
				
			var targetVertexs :Vector<Vertex>  = interpolateBuffer.vertices;
			var firstVertexs  :Vector<MD2Vertex> = frameList [firstFrame];
			var secondVertexs :Vector<MD2Vertex> = frameList [secondFrame];
			
			var target : Vertex ;
			var first  : MD2Vertex;
			var second : MD2Vertex;

			var transform:MD2KeyFrameTransform;
			
			var count : Int = frameList[firstFrame].length;
			for ( i in 0...count)
			{
				target  = targetVertexs [i];
				first   = firstVertexs  [i];
				second  = secondVertexs [i];
				
				transform = frameTransforms[firstFrame];
				
				one.x = first.x * transform.sx + transform.tx;
				one.y = first.y * transform.sy + transform.ty;
				one.z = first.z * transform.sz + transform.tz;
				
				transform = frameTransforms[secondFrame];
				
				tow.x = second.x * transform.sx + transform.tx;
				tow.y = second.y * transform.sy + transform.ty;
				tow.z = second.z * transform.sz + transform.tz;
				
				target.x = (tow.x - one.x) * div + one.x;
				target.y = (tow.y - one.y) * div + one.y;
				target.z = (tow.z - one.z) * div + one.z;
				
				target.nx = (normalTable[second.normalIdx * 3] - normalTable[first.normalIdx * 3]) * div + normalTable[first.normalIdx * 3];
				target.ny = (normalTable[second.normalIdx * 3 + 1] - normalTable[first.normalIdx * 3 + 1]) * div + normalTable[first.normalIdx * 3 + 1];
				target.nz = (normalTable[second.normalIdx * 3 + 2] - normalTable[first.normalIdx * 3 + 2]) * div + normalTable[first.normalIdx * 3 + 2];
				
			}
			//update bounding box
			interpolateBuffer.boundingBox.interpolate(boxList[secondFrame], boxList[firstFrame], div);
		}
		// returns the animated mesh based on a detail level. 0 is the lowest, 255 the highest detail. Note, that some Meshes will ignore the detail level.
		public function getMesh (frame : Int, ?detailLevel : Int = 255, ?startFrameLoop : Int = - 1, ?endFrameLoop : Int = - 1) : IMesh
		{
			if (frame > getFrameCount ()) frame = (frame % getFrameCount ());
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
			interpolateBuffer.boundingBox = box;
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
		public function recalculateBoundingBox () : Void
		{
		}
		public static inline var VERTEX_NORMAL_TABLE_SIZE:Int = 162;
		public static inline var VERTEX_NORMAL_TABLE:Vector<Float>=Lib.vectorOfArray([
			-0.525731, 0.000000, 0.850651, 
			-0.442863, 0.238856, 0.864188, 
			-0.295242, 0.000000, 0.955423, 
			-0.309017, 0.500000, 0.809017, 
			-0.162460, 0.262866, 0.951056, 
			0.000000, 0.000000, 1.000000, 
			0.000000, 0.850651, 0.525731, 
			-0.147621, 0.716567, 0.681718, 
			0.147621, 0.716567, 0.681718, 
			0.000000, 0.525731, 0.850651, 
			0.309017, 0.500000, 0.809017, 
			0.525731, 0.000000, 0.850651, 
			0.295242, 0.000000, 0.955423, 
			0.442863, 0.238856, 0.864188, 
			0.162460, 0.262866, 0.951056, 
			-0.681718, 0.147621, 0.716567, 
			-0.809017, 0.309017, 0.500000, 
			-0.587785, 0.425325, 0.688191, 
			-0.850651, 0.525731, 0.000000, 
			-0.864188, 0.442863, 0.238856, 
			-0.716567, 0.681718, 0.147621, 
			-0.688191, 0.587785, 0.425325, 
			-0.500000, 0.809017, 0.309017, 
			-0.238856, 0.864188, 0.442863, 
			-0.425325, 0.688191, 0.587785, 
			-0.716567, 0.681718, -0.147621, 
			-0.500000, 0.809017, -0.309017, 
			-0.525731, 0.850651, 0.000000, 
			0.000000, 0.850651, -0.525731, 
			-0.238856, 0.864188, -0.442863, 
			0.000000, 0.955423, -0.295242, 
			-0.262866, 0.951056, -0.162460, 
			0.000000, 1.000000, 0.000000, 
			0.000000, 0.955423, 0.295242, 
			-0.262866, 0.951056, 0.162460, 
			0.238856, 0.864188, 0.442863, 
			0.262866, 0.951056, 0.162460, 
			0.500000, 0.809017, 0.309017, 
			0.238856, 0.864188, -0.442863, 
			0.262866, 0.951056, -0.162460, 
			0.500000, 0.809017, -0.309017, 
			0.850651, 0.525731, 0.000000, 
			0.716567, 0.681718, 0.147621, 
			0.716567, 0.681718, -0.147621, 
			0.525731, 0.850651, 0.000000, 
			0.425325, 0.688191, 0.587785, 
			0.864188, 0.442863, 0.238856, 
			0.688191, 0.587785, 0.425325, 
			0.809017, 0.309017, 0.500000, 
			0.681718, 0.147621, 0.716567, 
			0.587785, 0.425325, 0.688191, 
			0.955423, 0.295242, 0.000000, 
			1.000000, 0.000000, 0.000000, 
			0.951056, 0.162460, 0.262866, 
			0.850651, -0.525731, 0.000000, 
			0.955423, -0.295242, 0.000000, 
			0.864188, -0.442863, 0.238856, 
			0.951056, -0.162460, 0.262866, 
			0.809017, -0.309017, 0.500000, 
			0.681718, -0.147621, 0.716567, 
			0.850651, 0.000000, 0.525731, 
			0.864188, 0.442863, -0.238856, 
			0.809017, 0.309017, -0.500000, 
			0.951056, 0.162460, -0.262866, 
			0.525731, 0.000000, -0.850651, 
			0.681718, 0.147621, -0.716567, 
			0.681718, -0.147621, -0.716567, 
			0.850651, 0.000000, -0.525731, 
			0.809017, -0.309017, -0.500000, 
			0.864188, -0.442863, -0.238856, 
			0.951056, -0.162460, -0.262866, 
			0.147621, 0.716567, -0.681718, 
			0.309017, 0.500000, -0.809017, 
			0.425325, 0.688191, -0.587785, 
			0.442863, 0.238856, -0.864188, 
			0.587785, 0.425325, -0.688191, 
			0.688191, 0.587785, -0.425325, 
			-0.147621, 0.716567, -0.681718, 
			-0.309017, 0.500000, -0.809017, 
			0.000000, 0.525731, -0.850651, 
			-0.525731, 0.000000, -0.850651, 
			-0.442863, 0.238856, -0.864188, 
			-0.295242, 0.000000, -0.955423, 
			-0.162460, 0.262866, -0.951056, 
			0.000000, 0.000000, -1.000000, 
			0.295242, 0.000000, -0.955423, 
			0.162460, 0.262866, -0.951056, 
			-0.442863, -0.238856, -0.864188, 
			-0.309017, -0.500000, -0.809017, 
			-0.162460, -0.262866, -0.951056, 
			0.000000, -0.850651, -0.525731, 
			-0.147621, -0.716567, -0.681718, 
			0.147621, -0.716567, -0.681718, 
			0.000000, -0.525731, -0.850651, 
			0.309017, -0.500000, -0.809017, 
			0.442863, -0.238856, -0.864188, 
			0.162460, -0.262866, -0.951056, 
			0.238856, -0.864188, -0.442863, 
			0.500000, -0.809017, -0.309017, 
			0.425325, -0.688191, -0.587785, 
			0.716567, -0.681718, -0.147621, 
			0.688191, -0.587785, -0.425325, 
			0.587785, -0.425325, -0.688191, 
			0.000000, -0.955423, -0.295242, 
			0.000000, -1.000000, 0.000000, 
			0.262866, -0.951056, -0.162460, 
			0.000000, -0.850651, 0.525731, 
			0.000000, -0.955423, 0.295242, 
			0.238856, -0.864188, 0.442863, 
			0.262866, -0.951056, 0.162460, 
			0.500000, -0.809017, 0.309017, 
			0.716567, -0.681718, 0.147621, 
			0.525731, -0.850651, 0.000000, 
			-0.238856, -0.864188, -0.442863, 
			-0.500000, -0.809017, -0.309017, 
			-0.262866, -0.951056, -0.162460, 
			-0.850651, -0.525731, 0.000000, 
			-0.716567, -0.681718, -0.147621, 
			-0.716567, -0.681718, 0.147621, 
			-0.525731, -0.850651, 0.000000, 
			-0.500000, -0.809017, 0.309017, 
			-0.238856, -0.864188, 0.442863, 
			-0.262866, -0.951056, 0.162460, 
			-0.864188, -0.442863, 0.238856, 
			-0.809017, -0.309017, 0.500000, 
			-0.688191, -0.587785, 0.425325, 
			-0.681718, -0.147621, 0.716567, 
			-0.442863, -0.238856, 0.864188, 
			-0.587785, -0.425325, 0.688191, 
			-0.309017, -0.500000, 0.809017, 
			-0.147621, -0.716567, 0.681718, 
			-0.425325, -0.688191, 0.587785, 
			-0.162460, -0.262866, 0.951056, 
			0.442863, -0.238856, 0.864188, 
			0.162460, -0.262866, 0.951056, 
			0.309017, -0.500000, 0.809017, 
			0.147621, -0.716567, 0.681718, 
			0.000000, -0.525731, 0.850651, 
			0.425325, -0.688191, 0.587785, 
			0.587785, -0.425325, 0.688191, 
			0.688191, -0.587785, 0.425325, 
			-0.955423, 0.295242, 0.000000, 
			-0.951056, 0.162460, 0.262866, 
			-1.000000, 0.000000, 0.000000, 
			-0.850651, 0.000000, 0.525731, 
			-0.955423, -0.295242, 0.000000, 
			-0.951056, -0.162460, 0.262866, 
			-0.864188, 0.442863, -0.238856, 
			-0.951056, 0.162460, -0.262866, 
			-0.809017, 0.309017, -0.500000, 
			-0.864188, -0.442863, -0.238856, 
			-0.951056, -0.162460, -0.262866, 
			-0.809017, -0.309017, -0.500000, 
			-0.681718, 0.147621, -0.716567, 
			-0.681718, -0.147621, -0.716567, 
			-0.850651, 0.000000, -0.525731, 
			-0.688191, 0.587785, -0.425325, 
			-0.587785, 0.425325, -0.688191, 
			-0.425325, 0.688191, -0.587785, 
			-0.425325, -0.688191, -0.587785, 
			-0.587785, -0.425325, -0.688191, 
			-0.688191, -0.587785, -0.425325
			]);
	}

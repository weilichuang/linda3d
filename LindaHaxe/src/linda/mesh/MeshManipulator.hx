package linda.mesh;

	import flash.Vector;
	import linda.math.Matrix4;
	import linda.mesh.IAnimatedMesh;
	import linda.video.ILineRenderer;
	
	import flash.geom.Rectangle;
	
	import linda.math.MathUtil;
	import linda.math.Vector3;
	import linda.math.AABBox3D;
	import linda.math.Plane3D;
	import linda.math.Vertex;
	
class MeshManipulator
{
		public function new()
		{
			
		}
		public static inline function scale(mesh:IMesh, value:Vector3):Void 
		{
			var count : Int = mesh.getMeshBufferCount();
			for (j in 0...count)
			{
				mesh.getMeshBuffer(j).scale(value);
			}
		}
		
		public static inline function translate(mesh:IMesh, value:Vector3):Void 
		{
			var count : Int = mesh.getMeshBufferCount();
			for (j in 0...count)
			{
				mesh.getMeshBuffer(j).translate(value);
			}
		}
		
		public static inline function setColor(mesh : IMesh, color : UInt) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for ( i in 0...count)
			{
				mesh.getMeshBuffer(i).setColor(color);
			}
		}

		public static inline function flipSurfaces (mesh : IMesh) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				mesh.getMeshBuffer(j).flipSurfaces();
			}
		}
		public static inline function recalculateNormals (mesh : IMesh,?smooth=false) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				mesh.getMeshBuffer(j).recalculateNormals(smooth);
			}
		}
		
		public static inline function makePlanarTextureMapping (mesh : IMesh, ?resolution : Float = 0.01) : Void
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				mesh.getMeshBuffer(j).makePlanarTextureMapping(resolution);
			}
		}
		
		public static inline function transform(mesh:IMesh,m:Matrix4):Void 
		{
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				mesh.getMeshBuffer(j).transform(m);
			}
		}
		
		public static inline function cloneMesh (mesh : IMesh) : Mesh
		{
			var newMesh : Mesh = new Mesh ();
			var count : Int = mesh.getMeshBufferCount ();
			for (j in 0...count)
			{
				var buffer:MeshBuffer = mesh.getMeshBuffer(j).clone();
				newMesh.addMeshBuffer(buffer);
			}
			newMesh.recalculateBoundingBox ();
			return newMesh;
		}
		public static inline function getPolyCount(mesh:IMesh):Int
		{
			if (mesh == null)
			{
				return 0;
			}else
			{
				var trianglecount:Int = 0;
            
				var count:Int = mesh.getMeshBufferCount();
				for (i in 0...count)
					trianglecount += Std.int(mesh.getMeshBuffer(i).indices.length/3);

				return trianglecount;
			}
		}
		public static inline function getAnimateMeshPolyCount(mesh:IAnimatedMesh):Int
		{
			if (mesh != null && mesh.getFrameCount() != 0)
			{
			    return getPolyCount(mesh.getMesh(0));
			}else
			{
				return 0;
			}
			
		}
}


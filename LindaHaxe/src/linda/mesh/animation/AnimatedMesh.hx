﻿package linda.mesh.animation;

	import flash.Vector;
	
	import linda.math.AABBox3D;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	class AnimatedMesh implements IAnimateMesh
	{
		public var boundingBox : AABBox3D;
		public var meshes : Vector<IMesh>;
		public var type : Int ;
		public var name:String;
		public function new ()
		{
			type=AnimatedMeshType.AMT_MD2;
			name="";
			boundingBox = new AABBox3D ();
			meshes = new Vector<IMesh> ();
			type = 0;
		}
		public function getFrameCount () : Int
		{
			return meshes.length;
		}
		public function getMesh (frame : Int, ?detailLevel : Int = 255, ?startFrameLoop : Int = - 1, ?endFrameLoop : Int = - 1) : IMesh
		{
			if (meshes.length == 0 || frame < 0) return null;
			return meshes [frame];
		}
		public function addMesh (mesh : IMesh) : Void
		{
			if (mesh != null)
			{
				meshes.push (mesh);
			}
		}
		public function recalculateBoundingBox () : Void
		{
			if (meshes.length > 0)
			{
				var mesh:IMesh=meshes [0];
				var len:Int=meshes.length;
				boundingBox.resetAABBox(mesh.getBoundingBox());
				for (i in 0...len)
				{
					mesh=meshes[i];
					boundingBox.addAABBox(mesh.getBoundingBox ());
				}
			}
		}
		public function setBoundingBox (box : AABBox3D) : Void
		{
			boundingBox = box;
		}
		public function getBoundingBox () : AABBox3D
		{
			return boundingBox;
		}
		public function setMaterialFlag (flag : Int, value : Bool) : Void
		{
		}
		public function getMeshType () : Int
		{
			return type;
		}
		public function getMeshBuffer (nr : Int) : MeshBuffer
		{
			return null;
		}
		public function getMeshBuffers():Vector<MeshBuffer>
		{
			return null;
		}
		public function getMeshBufferCount () : Int
		{
			return 0;
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
	}
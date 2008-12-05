﻿package linda.mesh.loader;

	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.Lib;
	import flash.Vector;
	import haxe.Log;
	
	import linda.math.Vector3;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	import linda.mesh.MeshBuffer;
	import linda.mesh.animation.AnimatedMeshMD2;
	import linda.mesh.animation.IAnimateMesh;
	import linda.mesh.animation.MD2Frame;
	

	class MD2MeshFileLoader extends MeshLoader
	{
		public static inline var MD2_MAGIC_Float:Int = 844121161;
		public static inline var MD2_VERSION     :Int = 8;
		public static inline var MD2_MAX_VERTS   :Int = 2048;
		public static inline var MD2_FRAME_SHIFT :Int = 3;
		public static inline var Normal_Table_Size:Int = 162;
		public static var normalTable:flash.Vector<Float>;
		public function new()
		{
			super();
			if (normalTable == null || normalTable.length == 0)
			{
				var table:Array<Float> = [
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
			];
			normalTable = Lib.vectorOfArray(table);
			table = null;
			}
		}
		override public function createAnimatedMesh(data : ByteArray) : IAnimateMesh
		{
			if (data == null) return null;
			
			var regexp:EReg = ~/([0-9])/g; 
			
			var mesh:AnimatedMeshMD2 = new AnimatedMeshMD2();

			// read file header
			data.endian = Endian.LITTLE_ENDIAN;
			data.position=0;
			var header:MD2Header = new MD2Header();
			header.magic = data.readInt();
			header.version = data.readInt();
			header.skinWidth = data.readInt();
			header.skinHeight = data.readInt();
			header.frameSize = data.readInt();
			header.numSkins = data.readInt();
			header.numVertices = data.readInt();
			header.numTexcoords = data.readInt();
			header.numTriangles = data.readInt();
			header.numGlCommands = data.readInt();
			header.numFrames = data.readInt();
			header.offsetSkins = data.readInt();
			header.offsetTexcoords = data.readInt();
			header.offsetTriangles = data.readInt();
			header.offsetFrames = data.readInt();
			header.offsetGlCommands = data.readInt();
			header.offsetEnd = data.readInt();

			if (header.magic != MD2_MAGIC_Float || header.version != MD2_VERSION)
			{
				Log.trace("不是正确的MD2文件");
				return null;
			}
		    
		    var frameCount:Int=header.numFrames;
		    var triangleCount:Int=header.numTriangles;
		    var verticesCount:Int=header.numVertices;

			mesh.frameCount = frameCount;
			for (i in 0...frameCount)
			{
				mesh.vertexList[i] = new Vector<Vertex>();
			}

			// read TextureCoords
			data.position=header.offsetTexcoords;
			var invWidth:Float=1/header.skinWidth;
			var invHeight:Float=1/header.skinHeight;
			var uvList:Vector<Point> = new Vector<Point>(header.numTexcoords);
			for(i in 0...header.numTexcoords)
			{
				var uv:Point = new Point();
				uv.x = data.readShort()*invWidth;
				uv.y = data.readShort()*invHeight;
				uvList[i] = uv;
			}
		
			// read Triangles
			data.position=header.offsetTriangles;
			var triangles:Vector<Vector<Int>> = new Vector<Vector<Int>>(triangleCount);
			for(i in 0...triangleCount)
			{
				var tri:Vector<Int> = new Vector<Int>(6);
				tri[0] = data.readShort();
				tri[1] = data.readShort();
				tri[2] = data.readShort();
				tri[3] = data.readShort();
				tri[4] = data.readShort();
				tri[5] = data.readShort();
				triangles[i] = tri;
			}
			
			// read Vertices	
			var vertices:Vector<Vector<Vector3>> = new Vector<Vector<Vector3>>(frameCount);
			var normals:Vector<Vector<Vector3>> = new Vector<Vector<Vector3>>(frameCount);
			mesh.boxList = new Vector<AABBox3D>(frameCount);
			
			var transMatrix:Matrix4 = new Matrix4();
			transMatrix.setRotation(new Vector3(0,-90,0));
		
			// read Frames
			data.position=header.offsetFrames;
			for (i in 0...frameCount)
			{
				var vts:Vector<Vector3> = new Vector<Vector3>();
				vertices[i] = vts;
				
				var nmls:Vector<Vector3> = new Vector<Vector3>();
 
 				normals[i] = nmls;

				var box:AABBox3D=new AABBox3D();
				mesh.boxList[i]=box;
				
				// read data into frame
				var sx:Float = data.readFloat();
				var sy:Float = data.readFloat();
				var sz:Float = data.readFloat();
				
				var tx:Float = data.readFloat();
				var ty:Float = data.readFloat();
				var tz:Float = data.readFloat();
				
				var name:String = data.readUTFBytes(16);
				
				// vertices are after frame data, there are header.numVertices total vertices
				// vertices are encoded - x,y,z,normalIndex
				for(  j in 0...verticesCount)
				{
					// read vertex
					var v:Vector3 = new Vector3();
					v.x = (data.readUnsignedByte() * sx) + tx;
					v.z = (data.readUnsignedByte() * sy) + ty;
					v.y = (data.readUnsignedByte() * sz) + tz;

					transMatrix.transformVector(v);
		
					vts.push(v);

					// read normal index
					var index:Int = data.readUnsignedByte();
					var nml:Vector3 = new Vector3();
					if (index > -1 && index < Normal_Table_Size)
					{
					 	nml.x = normalTable[(index*3)];
					 	nml.z = normalTable[(index*3+1)];
					 	nml.y = normalTable[(index*3+2)];
					 	transMatrix.transformVector(nml);
					}else{
    					 nml.x = v.x;
   						 nml.y = v.y;
   						 nml.z = v.z;
   						 nml.normalize();
					}
					nmls.push(nml);

					if(j == 0)
					{
						box.resetVector(v);
					}else
					{
						box.addVector(v);
					}
				}
				
				// store frame data
				var frame:MD2Frame = new MD2Frame();
				frame.begin = i;
				frame.end = i;
				frame.fps = 7;
				frame.name = '';

				// find the current frame's name
				var sl:Int = name.length;
				if (sl > 0)
				{
					frame.name = regexp.replace(name,"");

					if (mesh.frameList.length == 0)
					{
						mesh.frameList.push(frame);
					}
					else
					{
						var last:MD2Frame = mesh.frameList[mesh.frameList.length-1];
						if(last.name == last.name)
						{
							last.end++;
						}
						else
						{
							mesh.frameList.push(frame);
						}
					}
				}
			}  

			// put triangles into frame list
			for (i in 0...frameCount)
			{
				// get vertices for this frame
				var vers:Vector<Vector3> = vertices[i];
				var nmls:flash.Vector<Vector3> = normals[i];
				var vts:Vector<Vertex> = mesh.vertexList[i];
				var uv:Point;
				var tri:Vector<Int>;
				var vertex:Vertex;
				var vec:Vector3;
				var nor:Vector3;
				// get triangles for frame
				for (j in 0...triangleCount)
				{
					tri= triangles[j];
					// 3 verts to a tri
					vertex = new Vertex();
					vec = vers[tri[0]];
					vertex.x = vec.x;
					vertex.y = vec.y;
					vertex.z = vec.z;
					nor=nmls[tri[0]];
					vertex.nx = nor.x;
					vertex.ny = nor.y;
					vertex.nz = nor.z;
					uv = uvList[tri[3]];
					vertex.u = uv.x ;
					vertex.v = uv.y ;
					vts.push(vertex);
					
					vertex = new Vertex();
					vec = vers[tri[1]];
					vertex.x = vec.x;
					vertex.y = vec.y;
					vertex.z = vec.z;
					nor=nmls[tri[1]];
					vertex.nx = nor.x;
					vertex.ny = nor.y;
					vertex.nz = nor.z;
					uv = uvList[tri[4]];
					vertex.u = uv.x ;
					vertex.v = uv.y ;
					vts.push(vertex);
					
					vertex = new Vertex();
					vec = vers[tri[2]];
					vertex.x = vec.x;
					vertex.y = vec.y;
					vertex.z = vec.z;
					nor=nmls[tri[2]];
					vertex.nx = nor.x;
					vertex.ny = nor.y;
					vertex.nz = nor.z;
					uv = uvList[tri[5]];
					vertex.u = uv.x ;
					vertex.v = uv.y ;
					vts.push(vertex);
				} 
			} 
			
			
		    var interpolateBuffer:MeshBuffer=mesh.interpolateBuffer;
		    var indices:Vector<Int>=interpolateBuffer.indices;
			indices.length = 0;
			var n:Int = 0;
			while ( n < triangleCount * 3)
			{
				indices.push(n);
				indices.push(n+1);
				indices.push(n + 2);
				n += 3;
			}
			
			
			// reallocate interpolate buffer
			var bufferVts:Vector<Vertex>=interpolateBuffer.vertices;
			if (frameCount!=0)
			{
				var vertexs:Vector<Vertex> = mesh.vertexList[0];
				var len:Int = vertexs.length;
				for (i in 0...len)
				{
					var vtx:Vertex = vertexs[i];

					var vertex:Vertex = new Vertex();
					
					vertex.copy(vtx);
					
					bufferVts[i] = vertex;
				}
				interpolateBuffer.boundingBox.copy(mesh.boxList[0]);
			}
		 
            transMatrix = null;
			vertices.length = 0;
			triangles.length = 0;
			uvList.length = 0;
			vertices = null;
			triangles= null;	
            uvList=null;
            header = null;
			regexp = null;

			return mesh;
		}
	}

class MD2Header
{
	public var magic : Int;
	public var version : Int;
	public var skinWidth : Int;
	public var skinHeight : Int;
	public var frameSize : Int;
	public var numSkins : Int;
	public var numVertices : Int;
	public var numTexcoords : Int;
	public var numTriangles : Int;
	public var numGlCommands : Int;
	//opengl commands
	public var numFrames : Int;
	public var offsetSkins : Int;
	public var offsetTexcoords : Int;
	public var offsetTriangles : Int;
	public var offsetFrames : Int;
	public var offsetGlCommands : Int;
	public var offsetEnd : Int;
	public function new()
	{
		
	}
}
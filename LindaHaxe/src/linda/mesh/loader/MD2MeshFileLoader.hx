package linda.mesh.loader;

	import flash.geom.Vector3D;
	import flash.Vector;
	
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
		
		override public function createAnimatedMesh(data : ByteArray) : IAnimateMesh
		{
			if (data == null) return null;
			
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
				return null;
			}
		    
		    var frameCount:Int=header.numFrames;
		    var triangleCount:Int=header.numTriangles;
		    var verticesCount:Int=header.numVertices;
			var i:Int;
		
			mesh.frameCount = frameCount;
			for (i in 0...frameCount)
			{
				mesh.frameList[i] = new Vector<Vertex>();
			}

			// read TextureCoords
			data.position=header.offsetTexcoords;

			// uv 
			var invWidth:Float=1/header.skinWidth;
			var invHeight:Float=1/header.skinHeight;
			var uvList:Vector<Vector<Float>> = new Vector<Vector<Float>>(header.numTexcoords,true);
			for(i in 0...header.numTexcoords)
			{
				var uv:Vector<Float> = new Vector<Float>(2,true);
				uv[0] = data.readShort()*invWidth;
				uv[1] = data.readShort()*invHeight;
				uvList[i] = uv;
			}
		
			// read Triangles
			data.position=header.offsetTriangles;
		
			//Triangle
			var triangles:Vector<Vector<Int>> = new Vector<Vector<Int>>(triangleCount,true);
			for(i in 0...triangleCount)
			{
				var tri:Vector<Int> = new Vector<Int>(6,true);

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
			
			var transformation_matrix:Matrix4 = new Matrix4();
			transformation_matrix.setRotation(new Vector3(0,-90.0,0));
		
			// seek to start of frames
			data.position=header.offsetFrames;
			
			for (i in 0...frameCount)
			{
				
				var frame_vertices:Vector<Vector3> = new Vector<Vector3>();
				vertices[i] = frame_vertices;
				
				var frame_normals:Vector<Vector3> = new Vector<Vector3>();
				normals[i] = frame_normals;
				
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
				// vertices are encoded - X,Y,Z,normalIndex
				for(  j in 0...verticesCount)
				{
					// read vertex
					var v:Vector3 = new Vector3();
					v.x = (data.readUnsignedByte() * sx) + tx;
					v.z = (data.readUnsignedByte() * sy) + ty;
					v.y = (data.readUnsignedByte() * sz) + tz;

					transformation_matrix.transformVector(v);
		
					frame_vertices.push(v);
					
					// read normal index
					var normal_index:Int = data.readUnsignedByte();				
					var nml:Vector3 = new Vector3();
					
					if (normal_index > -1 && normal_index < VERTEX_NORMAL_TABLE_SIZE)
					{
						nml.x = VERTEX_NORMAL_TABLE[((normal_index*3)+0)];
						nml.z = VERTEX_NORMAL_TABLE[((normal_index*3)+1)];
						nml.y = VERTEX_NORMAL_TABLE[((normal_index*3)+2)];
						
						transformation_matrix.transformVector(nml);
					}
					else
					{
						nml.x = v.x;
						nml.y = v.y;
						nml.z = v.z;
						nml.normalize();
					}
					if(j == 0)
					{
						box.resetVector(v);
					}else
					{
						box.addVector(v);
					}
					frame_normals.push(nml);
				}
				
				// store frame data
				var frame_data:MD2Frame = new MD2Frame();
				frame_data.begin = i;
				frame_data.end = i;
				frame_data.fps = 7;
				frame_data.name = '';
		        
				// find the current frame's name
				var sl:Int = name.length;
				if (sl > 0)
				{
					var replace_pattern:EReg = new EReg("/([0-9])/g"); 
					frame_data.name = replace_pattern.replace(name,"");

					if (mesh.frameData.length == 0)
					{
						mesh.frameData.push(frame_data);
					}
					else
					{
						var frame_data_last:MD2Frame = mesh.frameData[mesh.frameData.length-1];
						if(frame_data_last.name == frame_data.name)
						{
							frame_data_last.end++;
						}
						else
						{
							mesh.frameData.push(frame_data);
						}
					}
				}

			}  

			// put triangles into frame list
			var color:UInt = 0xFFFFFFFF;

			for (i in 0...frameCount)
			{
				// get vertices for this frame
				frame_vertices = vertices[i];
				frame_normals = normals[i];
				var frame_list:Vector<Vertex> = mesh.frameList[i];
				
				// get triangles for frame
				for (j in 0...triangleCount)
				{
					
					var triangle:Vector<Int>= triangles[j];

					// 3 verts to a tri
					var vertex0:Vertex = new Vertex();
					vertex0.position = frame_vertices[triangle[0]];
					vertex0.normal = frame_normals[triangle[0]];
					vertex0.color =	color;
					uv = uvList[triangle[3]];
					vertex0.u = uv[0] ;
					vertex0.v = uv[1] ;
					
					frame_list.push(vertex0);
					
					
					var vertex1:Vertex = new Vertex();
					vertex1.position = frame_vertices[triangle[1]];
					vertex1.normal = frame_normals[triangle[1]];
					vertex1.color =	color;
					uv = uvList[triangle[4]];
					vertex1.u = uv[0];
					vertex1.v = uv[1];

					frame_list.push(vertex1);
					
					
					var vertex2:Vertex = new Vertex();
					vertex2.position = frame_vertices[triangle[2]];
					vertex2.normal = frame_normals[triangle[2]];
					vertex2.color = color;
					uv = uvList[triangle[5]];
					vertex2.u = uv[0];
					vertex2.v = uv[1];
					
					frame_list.push(vertex2);
				} 
			} 
			
			
		    var interpolateBuffer:MeshBuffer=mesh.interpolateBuffer;
		    var indices:Vector<Int>=interpolateBuffer.indices;
			var n:Int = 0;
			while ( n < triangleCount * 3)
			{
				indices.push(n);
				indices.push(n+1);
				indices.push(n + 2);
				n += 3;
			}
			// reallocate interpolate buffer
			var bufferVertices:Vector<Vertex>=interpolateBuffer.vertices;
			if (frameCount!=0)
			{
				var first_frame:Vector<Vertex> = mesh.frameList[0];
				var len:Int = first_frame.length;
				for (i in 0...len)
				{
					var vtx:Vertex = first_frame[i];
					// create the vertex buffer
					var vertex:Vertex = new Vertex();
					vertex.copy(vtx);
					bufferVertices[i] = vertex;
				}
				interpolateBuffer.boundingBox=mesh.boxList[0];
			}
		
            transformation_matrix=null;
			normals = null;
			vertices = null;
			triangles= null;	
            uvList=null;
            header=null;

			return mesh;
		}
	// normal array
	public static inline var  VERTEX_NORMAL_TABLE_SIZE:Int = 162;
	public static inline var VERTEX_NORMAL_TABLE:Array<Float> = [
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
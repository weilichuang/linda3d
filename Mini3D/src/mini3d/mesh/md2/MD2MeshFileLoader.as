package mini3d.mesh.md2
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mini3d.core.Vertex;
	import mini3d.math.AABBox3D;
	import mini3d.math.Matrix4;
	import mini3d.math.Vector3D;
	import mini3d.mesh.IAnimateMesh;
	import mini3d.mesh.MeshBuffer;
	import mini3d.mesh.MeshLoader;
	

	public class MD2MeshFileLoader extends MeshLoader
	{
		public static const MD2_MAGIC_NUMBER:int = 844121161;
		public static const MD2_VERSION:int	= 8;
		public static const MD2_MAX_VERTS:int = 2048;
		public static const MD2_FRAME_SHIFT:int = 3;
		
		override public function createAnimatedMesh(data : ByteArray) : IAnimateMesh
		{
			if (!data)
			{
				throw new Error("data is null");
				return null;
			} 
			
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

			if (header.magic != MD2_MAGIC_NUMBER || header.version != MD2_VERSION)
			{
				throw new Error("MD2MeshFileLoader: 不是合适的MD2文件");
				return null;
			}
		    
		    var frameCount:int=header.numFrames;
		    var triangleCount:int=header.numTriangles;
		    var verticesCount:int=header.numVertices;
			var i:int;
		
			mesh.frameCount = frameCount;
			for (i=0; i<frameCount; i++)
			{
				mesh.frameList[i] = new Array();
			}

			// read TextureCoords
			data.position=header.offsetTexcoords;

			// uv 
			var uvList:Array = new Array();
			for(i=0;i<header.numTexcoords;i++)
			{
				var uv:Array = new Array();
				uv[0] = data.readShort()/header.skinWidth;
				uv[1] = data.readShort()/header.skinHeight;
				
				uvList[i] = uv;
			}
		
			// read Triangles
			data.position=header.offsetTriangles;
		
			//Triangle
			var triangles:Array = new Array();
			for(i=0;i<triangleCount;i++)
			{
				var tri:Array = new Array();

				tri[0] = data.readShort();
				tri[1] = data.readShort();
				tri[2] = data.readShort();
				tri[3] = data.readShort();
				tri[4] = data.readShort();
				tri[5] = data.readShort();
				
				triangles[i] = tri;
			}
			
			// read vertices	
		
			var vertices:Array = new Array(frameCount);
			mesh.boxList = new Array(frameCount);
			
			var transformation_matrix:Matrix4 = new Matrix4();
			transformation_matrix.setRotation(new Vector3D(0,-Math.PI/2,0));
		
			// seek to start of frames
			data.position=header.offsetFrames;
			
			for (i=0; i<frameCount; i++)
			{
				
				var frame_vertices:Array = new Array();
				vertices[i] = frame_vertices;
				
				var box:AABBox3D=new AABBox3D();
				mesh.boxList[i]=box;
				
				// read data into frame
				var sx:Number = data.readFloat();
				var sy:Number = data.readFloat();
				var sz:Number = data.readFloat();
				
				var tx:Number = data.readFloat();
				var ty:Number = data.readFloat();
				var tz:Number = data.readFloat();
				
				var name:String = data.readUTFBytes(16);
				
				// vertices are after frame data, there are header.numVertices total vertices
				// vertices are encoded - X,Y,Z,normalIndex
				for( var j:int=0;j<verticesCount; j++)
				{
					// read vertex
					var v:Vector3D = new Vector3D();
					v.x = (data.readUnsignedByte() * sx) + tx;
					v.z = (data.readUnsignedByte() * sy) + ty;
					v.y = (data.readUnsignedByte() * sz) + tz;

					transformation_matrix.transformVector(v);
		
					frame_vertices.push(v);
					
					// read normal index
					data.readUnsignedByte();	
					
					if(j == 0)
					{
						box.resetVector(v);
					}else
					{
						box.addPoint(v);
					}
				}
				
				// store frame data
				var frame_data:MD2Frame = new MD2Frame();
				frame_data.begin = i;
				frame_data.end = i;
				frame_data.fps = 7;
				frame_data.name = '';
		
				// find the current frame's name
				var sl:int = name.length;
				if (sl > 0)
				{
					var replace_pattern:RegExp = /([0-9])/g; 
					frame_data.name = name.replace(replace_pattern,"");

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
			var color:uint = 0xFFFFFFFF;

			for (i = 0; i<frameCount; i++)
			{
				// get vertices for this frame
				frame_vertices = vertices[i];
				var frame_list:Array = mesh.frameList[i];
				
				// get triangles for frame
				for (j=0; j<triangleCount; j++)
				{
					
					var triangle:Array= triangles[j];

					// 3 verts to a tri
					var vertex0:Vertex = new Vertex();
					vertex0.position = frame_vertices[triangle[0]];
					uv = uvList[triangle[3]];
					vertex0.u = uv[0] ;
					vertex0.v = uv[1] ;
					
					frame_list.push(vertex0);
					
					
					var vertex1:Vertex = new Vertex();
					vertex1.position = frame_vertices[triangle[1]];
					uv = uvList[triangle[4]];
					vertex1.u = uv[0];
					vertex1.v = uv[1];

					frame_list.push(vertex1);
					
					
					var vertex2:Vertex = new Vertex();
					vertex2.position = frame_vertices[triangle[2]];
					uv = uvList[triangle[5]];
					vertex2.u = uv[0];
					vertex2.v = uv[1];
					
					frame_list.push(vertex2);
				} 
			} 
			
			
		    var interpolateBuffer:MeshBuffer=mesh.interpolateBuffer;
		    var indices:Array=interpolateBuffer.getIndices();
			for (var n:int=0; n<triangleCount*3; n+=3)
			{
				indices.push(n);
				indices.push(n+1);
				indices.push(n+2);
			}

			// reallocate interpolate buffer
			var bufferVertices:Array=interpolateBuffer.getVertices();
			if (frameCount!=0)
			{
				var first_frame:Array = mesh.frameList[0];
				var len:int = first_frame.length;
				for (i=0; i<len; i++)
				{
					var vtx:Vertex = first_frame[i];

					// create the vertex buffer
					var vertex:Vertex = new Vertex();
					bufferVertices[i] = vertex;
					
					vertex.copy(vtx);
				}
				interpolateBuffer.setBoundingBox(mesh.boxList[0]);
			}
		
            transformation_matrix=null;
			vertices = null;
			triangles= null;	
            uvList=null;

			return mesh;
		}
	}
}
class MD2Header
{
	public var magic : int;
	public var version : int;
	public var skinWidth : int;
	public var skinHeight : int;
	public var frameSize : int;
	public var numSkins : int;
	public var numVertices : int;
	public var numTexcoords : int;
	public var numTriangles : int;
	public var numGlCommands : int;//opengl commands
	public var numFrames : int;
	public var offsetSkins : int;
	public var offsetTexcoords : int;
	public var offsetTriangles : int;
	public var offsetFrames : int;
	public var offsetGlCommands : int;
	public var offsetEnd : int;
}
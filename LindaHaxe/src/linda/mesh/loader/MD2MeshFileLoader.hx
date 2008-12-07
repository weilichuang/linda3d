package linda.mesh.loader;

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
		public static inline var MD2_MAGIC_NUMBER:Int = 844121161;
		public static inline var MD2_VERSION     :Int = 8;
		public static inline var MD2_MAX_VERTS   :Int = 2048;
		public static inline var MD2_FRAME_SHIFT :Int = 3;
		public static inline var Normal_Table_Size:Int = 162;
		public var normalTable:flash.Vector<Float>;
		public function new()
		{
			super();
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
		override public function createAnimatedMesh(data : ByteArray) : IAnimateMesh
		{
			if (data == null) return null;
			
			var regexp:EReg = ~/([0-9])/g; 

			var mesh:AnimatedMeshMD2 = new AnimatedMeshMD2();

			// read file header
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			
			var magic:Int            = data.readInt();
			var version:Int          = data.readInt();
			var skinWidth:Int        = data.readInt();
			var skinHeight:Int       = data.readInt();
			var frameSize:Int        = data.readInt();
			var numSkins:Int         = data.readInt();
			var numVertices:Int      = data.readInt();
			var numTexcoords:Int     = data.readInt();
			var numTriangles:Int     = data.readInt();
			var numGlCommands:Int    = data.readInt();
			var numFrames:Int        = data.readInt();
			var offsetSkins:Int      = data.readInt();
			var offsetTexcoords:Int  = data.readInt();
			var offsetTriangles:Int  = data.readInt();
			var offsetFrames:Int     = data.readInt();
			var offsetGlCommands:Int = data.readInt();
			var offsetEnd:Int        = data.readInt();

			if (magic != MD2_MAGIC_NUMBER || version != MD2_VERSION)
			{
				Log.trace("不是正确的MD2文件");
				return null;
			}

			mesh.numFrames = numFrames;
			for (i in 0...numFrames)
			{
				mesh.vertexList[i] = new Vector<Vertex>();
			}

			// read TextureCoords
			data.position=offsetTexcoords;
			var invWidth:Float=1/skinWidth;
			var invHeight:Float=1/skinHeight;
			var uvList:Vector<Point> = new Vector<Point>(numTexcoords);
			for(i in 0...numTexcoords)
			{
				var uv:Point = new Point();
				uv.x = data.readShort()*invWidth;
				uv.y = data.readShort()*invHeight;
				uvList[i] = uv;
			}
		
			// read Triangles
			data.position=offsetTriangles;
			var triangles:Vector<Vector<Int>> = new Vector<Vector<Int>>(numTriangles);
			for(i in 0...numTriangles)
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
			var total:Int = numFrames * numVertices;
			var vertices:Vector<Vector3> = new Vector<Vector3>(total);
			var normals:Vector<Vector3> = new Vector<Vector3>(total);
			mesh.boxList = new Vector<AABBox3D>(numFrames);
			
			var transMatrix:Matrix4 = new Matrix4();
			transMatrix.setRotation(new Vector3(0,-90,0));
		
			// read Frames
			data.position=offsetFrames;
			for (i in 0...numFrames)
			{
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
				
				//x,y,z,normalIndex
				for( j in 0...numVertices)
				{
					// read vertex
					var v:Vector3 = new Vector3();
					v.x = data.readUnsignedByte() * sx + tx;
					v.z = data.readUnsignedByte() * sy + ty;
					v.y = data.readUnsignedByte() * sz + tz;
					
					transMatrix.transformVector(v);
					
					vertices[i * numVertices + j] = v;

					// read normal index
					var index:Int = data.readUnsignedByte();
					var nml:Vector3 = new Vector3();
					if (index > -1 && index < Normal_Table_Size)
					{
					 	nml.x = normalTable[(index*3)];
					 	nml.z = normalTable[(index*3+1)];
					 	nml.y = normalTable[(index * 3 + 2)];
						
					 	transMatrix.transformVector(nml);
					}else{
    					 nml.x = v.x;
   						 nml.y = v.y;
   						 nml.z = v.z;
   						 nml.normalize();
					}
					normals[i * numVertices + j] = nml;

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
				frame.end   = i;
				frame.fps   = 7;
				frame.name  = '';
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
						} else
						{
							mesh.frameList.push(frame);
						}
					}
				}
			}
            
			mesh.vertexList = new Vector < Vector < Vertex >> (numFrames,true);
            var t:Int = Lib.getTimer();
			// put triangles into frame list
			for (i in 0...numFrames)
			{
				var vts:Vector<Vertex> = new Vector<Vertex>(numTriangles*3,true);
				mesh.vertexList[i] = vts;
				
				var uv:Point;
				var tri:Vector<Int>;
				var vertex:Vertex;
				var vec:Vector3;
				var nor:Vector3;
				// get triangles for frame
				for (j in 0...numTriangles)
				{
					tri= triangles[j];
					vertex = new Vertex();
					var id:Int = tri[0]+i*numVertices;
					vec = vertices[id];
					nor = normals[id];
					
					vertex.x = vec.x;
					vertex.y = vec.y;
					vertex.z = vec.z;
					
					vertex.nx = nor.x;
					vertex.ny = nor.y;
					vertex.nz = nor.z;
					
					if (i == 0)
					{
						uv = uvList[tri[3]];
						vertex.u = uv.x ;
						vertex.v = uv.y ;
					}
					vts[j * 3] = vertex;
					
					vertex = new Vertex();
					id = tri[1]+i*numVertices;
					vec = vertices[id];
					nor = normals[id];
					
					vertex.x = vec.x;
					vertex.y = vec.y;
					vertex.z = vec.z;
					
					vertex.nx = nor.x;
					vertex.ny = nor.y;
					vertex.nz = nor.z;
					
					if (i == 0)
					{
						uv = uvList[tri[4]];
						vertex.u = uv.x ;
						vertex.v = uv.y ;
					}
					vts[j * 3 + 1] = vertex;
					
					vertex = new Vertex();
					id  = tri[2]+i*numVertices;
					vec = vertices[id];
					nor = normals[id];
					
					vertex.x = vec.x;
					vertex.y = vec.y;
					vertex.z = vec.z;
					
					vertex.nx = nor.x;
					vertex.ny = nor.y;
					vertex.nz = nor.z;
					
					if (i == 0)
					{
						uv = uvList[tri[5]];
						vertex.u = uv.x ;
						vertex.v = uv.y ;
					}
					vts[j * 3 + 2] = vertex;
				} 
			} 
			
			Log.trace("put triangles into frame list time:"+(Lib.getTimer() - t));
			
		    var interpolateBuffer:MeshBuffer=mesh.interpolateBuffer;
		    var indices:Vector<Int>=interpolateBuffer.indices;
			indices.length = 0;
			var n:Int = 0;
			while ( n < numTriangles * 3)
			{
				indices.push(n);
				indices.push(n+1);
				indices.push(n + 2);
				n += 3;
			}
			
			
			// reallocate interpolate buffer
			var bufferVts:Vector<Vertex>=interpolateBuffer.vertices;
			if (numFrames!=0)
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
			normals.length = 0;
			triangles.length = 0;
			uvList.length = 0;
			vertices = null;
			triangles= null;	
            uvList = null;
			normals = null;
			regexp = null;
            
			return mesh;
		}
}
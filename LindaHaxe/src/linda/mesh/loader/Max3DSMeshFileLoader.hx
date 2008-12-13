package linda.mesh.loader;

	import flash.Vector;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import haxe.Log;
	
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.loader.Max3DSChunk;
	import linda.mesh.loader.MeshLoader;
	import linda.mesh.MeshManipulator;
	class Max3DSMeshFileLoader extends MeshLoader
	{
		public function new()
		{
			super();
		}
		override public function createMesh (data : ByteArray) : IMesh
		{
			if (data == null) return null;

			var frameCount : Int;
			var count : Int;
			var mesh : Mesh = new Mesh ();
			
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			
			var meshBuffer : MeshBuffer= new MeshBuffer ();
			var vertices : Vector<Vertex>=new Vector<Vertex>();
			
			var maxLength : Int = data.length;
			while (data.position < maxLength)
			{
				var header : UInt = data.readUnsignedShort ();
				var length : UInt = data.readUnsignedInt ();
				switch (header)
				{
					case Max3DSChunk.MAIN3DS :
					{
					}
					case Max3DSChunk.EDIT3DS :
					{
					}
					case Max3DSChunk.VERSION :
					{
						var position : Int = data.position;
						var _version : Int = data.readUnsignedShort ();
						data.position = position + length - 6;
					}
					//light
					case Max3DSChunk.LIGHT :
					{
						data.readFloat ();
						data.readFloat ();
						data.readFloat ();
					}
					case Max3DSChunk.EDIT_MATERIAL :
					{
					}
					case Max3DSChunk.MAT_NAME :
					{
							readString (data);
					}
					case Max3DSChunk.MAT_MAP :
					{
					}
					case Max3DSChunk.MAT_PATH :
					{
						readString (data);
					}
					case Max3DSChunk.OBJ_TRIMESH :
					{
					}
					//camera
					case Max3DSChunk.OBJ_CAMERA :
					{
							//position
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							//target
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							//angle
							data.readFloat ();
							//fov
							data.readFloat ();
					}
					case Max3DSChunk.EDIT_OBJECT :
					{
							meshBuffer = new MeshBuffer ();
							//meshBuffer.name = 
							readString (data);
							mesh.addMeshBuffer (meshBuffer);
					}
					//EDIT_OBJECT START:
					case Max3DSChunk.TRI_VERTEX :
					{
							count = data.readShort ();
							vertices = meshBuffer.vertices;
							for (i in 0...count)
							{
								var vertex : Vertex = new Vertex ();
								vertex.x = data.readFloat ();
								vertex.z = data.readFloat ();
								vertex.y = data.readFloat ();
								vertices.push (vertex);
							}
					}
					case Max3DSChunk.TRI_FACEVERT :
					{
							count = data.readShort ();
							var indices : Vector<Int> = meshBuffer.indices;
							for (i in 0...count)
							{
								var t0 : Int = data.readShort ();
								var t1 : Int = data.readShort ();
								var t2 : Int = data.readShort ();
								indices.push (t0);
								indices.push (t2);
								indices.push (t1);
								data.readShort ();
							}
					}
					case Max3DSChunk.TRI_FACEMAT :
					{
							var materialName : String = readString (data);
							//if (_list.indexOf(materialName) == -1) _list.push(materialName);
							//var materialFaceIndex:MaterialFaceIndex = new MaterialFaceIndex(materialName);
							count = data.readShort ();
							for (i in 0...count)
							{
								data.readShort ();
								//materialFaceIndex.addIndex(data.readShort());
							}
							//if (meshObject.materialFaceIndexList == null) meshObject.materialFaceIndexList = new MaterialFaceIndexList();
							//meshObject.materialFaceIndexList.add(materialFaceIndex);
					}
					case Max3DSChunk.TRI_UV :
					{
							count = data.readShort ();
							for (i in 0...count)
							{
								var vertex:Vertex = vertices [i];
								vertex.u = data.readFloat ();
								vertex.v = 1 - data.readFloat ();
							}
					}
					case Max3DSChunk.TRI_LOCAL :
					{
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
					}
					//EDIT_OBJECT END:
					case Max3DSChunk.KEYF3DS :
					{
					}
					//KEYF3DS START:
					case Max3DSChunk.KEYF_OBJDES :
					{
					}
					case Max3DSChunk.KEYF_FRAMES :
					{
							data.readUnsignedInt ();
							frameCount = data.readUnsignedInt ();
					}
					case Max3DSChunk.KEYF_OBJHIERARCH :
					{
							readString (data);
							//not use
							data.readShort ();
							data.readShort ();
							//
							data.readShort ();
					}
					case 0xb011 :
					{
					}
					case Max3DSChunk.KEYF_PIVOTPOINT :
					{
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
					}
					case 0xb014 :
					{
					}
					case 0xb015 :
					{
					}
					case Max3DSChunk.KEYF_OBJPIVOT :
					{
							//not use
							data.readShort ();
							data.readShort ();
							data.readShort ();
							data.readShort ();
							data.readShort ();
							//
							count = data.readShort ();
							for (i in 0...count)
							{
								data.readShort ();
								data.readUnsignedInt ();
								data.readFloat ();
								data.readFloat ();
								data.readFloat ();
							}
					}
					case 0xb021 :
					{
					}
					case 0xb022 :
					{
					}
					case 0xb030 :
					{
						data.readShort ();
					}
					//KEYF3DS END:
					default :
					{
						data.position += length - 6;
					}
				}
			}
			
			//recalculate normals
			var count:Int = mesh.getMeshBufferCount();
			for (j in 0...count)
			{
				var buffer : MeshBuffer = mesh.getMeshBuffer(j);
				buffer.recalculateBoundingBox ();
				MeshManipulator.recalculateNormals (buffer, true);
			}
			mesh.recalculateBoundingBox ();
			return mesh;
		}
		private inline function readString (data : ByteArray) : String
		{
			var n : Int;
			var str : String = '';
			do
			{
				n = data.readByte ();
				if (n == 0)
				{
					break;
				}
				str += String.fromCharCode (n);
			} while(true);
			return str;
		}
	}

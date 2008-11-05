package linda.mesh.loader.max3ds
{
	import __AS3__.vec.Vector;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.IMeshBuffer;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.export.max3ds.Max3DSChunk;
	import linda.mesh.loader.MeshLoader;
	import linda.mesh.utils.MeshManipulator;
	public class Max3DSMeshFileLoader extends MeshLoader
	{
		override public function createMesh (data : ByteArray) : IMesh
		{
			if (data == null) return null;
			try
			{
				var frameCount : int;
				var count : int;
				var mesh : Mesh = new Mesh ();
				var meshBuffer : MeshBuffer;
				data.endian = Endian.LITTLE_ENDIAN;
				data.position = 0;
				var maxLength : int = data.length;
				while (data.position < maxLength)
				{
					var header : uint = data.readUnsignedShort ();
					var length : uint = data.readUnsignedInt ();
					switch (header)
					{
						case Max3DSChunk.MAIN3DS :
						{
							break;
						}
						case Max3DSChunk.EDIT3DS :
						{
							break;
						}
						case Max3DSChunk.VERSION :
						{
							var position : int = data.position;
							var _version : int = data.readUnsignedShort ();
							data.position = position + length - 6;
							break;
						}
						//light
						case Max3DSChunk.LIGHT :
						{
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							break;
						}
						case Max3DSChunk.EDIT_MATERIAL :
						{
							break;
						}
						case Max3DSChunk.MAT_NAME :
						{
							readString (data);
							break;
						}
						case Max3DSChunk.MAT_MAP :
						{
							break;
						}
						case Max3DSChunk.MAT_PATH :
						{
							readString (data);
							break;
						}
						case Max3DSChunk.OBJ_TRIMESH :
						{
							break;
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
							break;
						}
						case Max3DSChunk.EDIT_OBJECT :
						{
							meshBuffer = new MeshBuffer ();
							//meshBuffer.name = 
							readString (data);
							mesh.addMeshBuffer (meshBuffer);
							break;
						}
						//EDIT_OBJECT START:
						case Max3DSChunk.TRI_VERTEX :
						{
							count = data.readShort ();
							var vertices : Vector.<Vertex> = meshBuffer.vertices;
							for (var i : int = 0; i < count; i ++)
							{
								var vertex : Vertex = new Vertex ();
								vertex.x = data.readFloat ();
								vertex.z = data.readFloat ();
								vertex.y = data.readFloat ();
								vertices.push (vertex);
							}
							break;
						}
						case Max3DSChunk.TRI_FACEVERT :
						{
							count = data.readShort ();
							var indices : Vector.<int> = meshBuffer.indices;
							for (i = 0; i < count; i ++)
							{
								var t0 : int = data.readShort ();
								var t1 : int = data.readShort ();
								var t2 : int = data.readShort ();
								indices.push (t0 , t2 , t1);
								data.readShort ();
							}
							break;
						}
						case Max3DSChunk.TRI_FACEMAT :
						{
							var materialName : String = readString (data);
							//if (_list.indexOf(materialName) == -1) _list.push(materialName);
							//var materialFaceIndex:MaterialFaceIndex = new MaterialFaceIndex(materialName);
							count = data.readShort ();
							for (i = 0; i < count; i ++)
							{
								data.readShort ();
								//materialFaceIndex.addIndex(data.readShort());
							}
							//if (meshObject.materialFaceIndexList == null) meshObject.materialFaceIndexList = new MaterialFaceIndexList();
							//meshObject.materialFaceIndexList.add(materialFaceIndex);
							break;
						}
						case Max3DSChunk.TRI_UV :
						{
							count = data.readShort ();
							for (i = 0; i < count; i ++)
							{
								vertex = vertices [i];
								vertex.u = data.readFloat ();
								vertex.v = 1 - data.readFloat ();
							}
							break;
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
							break;
						}
						//EDIT_OBJECT END:
						case Max3DSChunk.KEYF3DS :
						{
							break;
						}
						//KEYF3DS START:
						case Max3DSChunk.KEYF_OBJDES :
						{
							break;
						}
						case Max3DSChunk.KEYF_FRAMES :
						{
							data.readUnsignedInt ();
							frameCount = data.readUnsignedInt ();
							break;
						}
						case Max3DSChunk.KEYF_OBJHIERARCH :
						{
							readString (data);
							//not use
							data.readShort ();
							data.readShort ();
							//
							data.readShort ();
							break;
						}
						case 0xb011 :
						{
							//trace('0xb011');
							break;
						}
						case Max3DSChunk.KEYF_PIVOTPOINT :
						{
							data.readFloat ();
							data.readFloat ();
							data.readFloat ();
							break;
						}
						case 0xb014 :
						{
							//trace('0xb014');
							break;
						}
						case 0xb015 :
						{
							//trace('0xb015');
							break;
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
							for (i = 0; i < count; i ++)
							{
								data.readShort ();
								data.readUnsignedInt ();
								data.readFloat ();
								data.readFloat ();
								data.readFloat ();
							}
							break;
						}
						case 0xb021 :
						{
							//trace('0xb021');
							break;
						}
						case 0xb022 :
						{
							//trace('0xb022');
							break;
						}
						case 0xb030 :
						{
							data.readShort ();
							break;
						}
						//KEYF3DS END:
						default :
						{
							//trace(header.toString(16));
							//trace(_byteArray.readUTFBytes(length-6));
							data.position += length - 6;
						}
					}
				}
				//recalculate normals
				for (var j : int = 0; j < mesh.getMeshBufferCount (); j ++)
				{
					var buffer : IMeshBuffer = mesh.getMeshBuffer (j);
					buffer.recalculateBoundingBox ();
					MeshManipulator.recalculateNormals (buffer, true);
				}
				mesh.recalculateBoundingBox ();
				return mesh;
			}catch (e : Error)
			{
				throw new Error ("Could not parse this 3ds file!", e.message);
			}
			return null;
		}
		private function readString (data : ByteArray) : String
		{
			var n : int;
			var str : String = '';
			do
			{
				n = data.readByte ();
				if (n == 0)
				{
					break;
				}
				str += String.fromCharCode (n);
			} while (true);
			return str;
		}
	}
}

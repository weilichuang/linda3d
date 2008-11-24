package linda.mesh.export.max3ds
{
	import __AS3__.vec.Vector;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.export.IEncoder;
	public class Max3DSEncoder implements IEncoder
	{
		private var _bytes : ByteArray;
		public function get bytes () : ByteArray 
		{
			return _bytes;
		}
		public function clear () : void 
		{
			_bytes = null;
		}
		public function encode (m : IMesh) : void 
		{
			try 
			{
				var mesh:Mesh=m as Mesh;
				if(mesh == null) return;
				_bytes = new ByteArray ();
				_bytes.position=0;
				_bytes.endian = Endian.LITTLE_ENDIAN;
				_bytes.writeShort (Max3DSChunk.MAIN3DS);
				_bytes.writeUnsignedInt (0);
				
				_bytes.writeShort (Max3DSChunk.EDIT3DS);
				var edit3DSPos : uint = _bytes.position;
				_bytes.writeUnsignedInt (0);
				
				var meshbuffers :Vector.<MeshBuffer> = mesh.getMeshBuffers();
				var len : int = meshbuffers.length;
				var defaultNameCount:int = 0;
				for (var i : int = 0; i < len; i ++)
				{
					var buffer : MeshBuffer = meshbuffers [i] as MeshBuffer;
					
					_bytes.writeShort (Max3DSChunk.EDIT_OBJECT);
					var editObjPos : uint = _bytes.position;
					_bytes.writeUnsignedInt (0);
					_bytes.writeMultiByte ('Object'+(defaultNameCount++),'utf-8');
					_bytes.writeByte (0);
					
					_bytes.writeShort (Max3DSChunk.OBJ_TRIMESH);
					var objTriMeshPos : uint = _bytes.position;
					_bytes.writeUnsignedInt (0);
					
					
					_bytes.writeShort (Max3DSChunk.TRI_VERTEX);
					var triVertexPos : uint = _bytes.position;
					_bytes.writeUnsignedInt (0);
					
					var vertexArray : Vector.<Vertex> = buffer.vertices;
					var max : uint = vertexArray.length;
					_bytes.writeShort (max);
					for (var j : uint = 0; j < max; j ++)
					{
						var vertex : Vertex = vertexArray [j];
						_bytes.writeFloat (vertex.x);

						_bytes.writeFloat (vertex.z);
						_bytes.writeFloat (vertex.y);
					}
					_bytes.position = triVertexPos;
					_bytes.writeUnsignedInt (_bytes.length - triVertexPos + 2);
					_bytes.position = _bytes.length;
					
					//-------------------uv-----------//
					
					_bytes.writeShort (Max3DSChunk.TRI_UV);
					var triUVPos : uint = _bytes.position;
					_bytes.writeUnsignedInt (0);
						
					max = vertexArray.length;
					_bytes.writeShort (max);
					for (j = 0; j < max; j ++)
					{
							vertex = vertexArray [j];
							_bytes.writeFloat (vertex.u);
							_bytes.writeFloat (1 - vertex.v);
					}
					_bytes.position = triUVPos;
					_bytes.writeUnsignedInt (_bytes.length - triUVPos + 2);
					_bytes.position = _bytes.length;
					
					//-------------------uv-----------//
					
					_bytes.writeShort (Max3DSChunk.TRI_FACEVERT);
					var triFaceVertPos : uint = _bytes.position;
					_bytes.writeUnsignedInt (0);
					
					var indices : Vector.<int> = buffer.indices;
					max = int(indices.length/3);
					_bytes.writeShort (max);
					for (j = 0; j < max*3; j += 3)
					{
						_bytes.writeShort (indices [j + 1]);
						_bytes.writeShort (indices [j + 0]);
						_bytes.writeShort (indices [j + 2]);

						_bytes.writeShort (5);
					}
					//material
					_bytes.writeShort (Max3DSChunk.TRI_FACEMAT);
					var triFaceMatPos : uint = _bytes.position;
					_bytes.writeUnsignedInt (0);
					max = int(buffer.indices.length/3);
					_bytes.writeMultiByte (buffer.material.name, 'utf-8');
					_bytes.writeByte (0);
					_bytes.writeShort (max);
					for (j = 0; j < max; j ++)
					{
						_bytes.writeShort (j);
					}
					_bytes.position = triFaceMatPos;
					_bytes.writeUnsignedInt (_bytes.length - triFaceMatPos + 2);
					_bytes.position = _bytes.length;


					_bytes.position = triFaceVertPos;
					_bytes.writeUnsignedInt (_bytes.length - triFaceVertPos + 2);
					
					_bytes.position = objTriMeshPos;
					_bytes.writeUnsignedInt (_bytes.length - objTriMeshPos + 2);
					
					_bytes.position = editObjPos;
					_bytes.writeUnsignedInt (_bytes.length - editObjPos + 2);
					_bytes.position=_bytes.length;
				}
				
				
				_bytes.position = edit3DSPos;
				_bytes.writeUnsignedInt (_bytes.length - edit3DSPos + 2);
				_bytes.position = _bytes.length;
				
				_bytes.position = 2;
				_bytes.writeUnsignedInt (_bytes.length);
				
			} catch (e : Error)
			{
				clear ();
			}
		}
	}
}

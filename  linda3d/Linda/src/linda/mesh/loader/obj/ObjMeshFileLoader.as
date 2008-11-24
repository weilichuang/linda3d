package linda.mesh.loader.obj
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import linda.math.Vector2D;
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.loader.MeshLoader;
	import linda.mesh.utils.MeshManipulator;
	public class ObjMeshFileLoader extends MeshLoader
	{
		private var materials : Array = new Array ();
		/** variable: groups
		* Array of groups <ObjGroup>
		*/
		private var groups : Array = new Array ();
		private var _mesh : Mesh;
		private static const CHAR_RETURN : int = 13;
		private static const CHAR_NEWLINE : int = 10;
		private static const CHAR_SPACE : int = 32;
		private static const CHAR_TAB : int = 9;
		private static const STRING_TAB : String = String.fromCharCode (CHAR_TAB);

		/** function: createMesh
		* Creates an  animated mesh from the file type
		*
		* returns:
		* <IAnimatedMesh> - pointer to the created mesh, or null if loading failed.
		*/
		override public function createMesh(data:ByteArray):IMesh
		{
			// create the mesh
			_mesh = new Mesh ();
			// <Vector3D>
			var vertexBuffer : Array = new Array ();
			// <Vector2D>
			var textureCoordBuffer : Array = new Array ();
			// <Vector3D>
			var normalsBuffer : Array = new Array ();
			var pCurrGroup : ObjGroup = null;
			// create default material
			var pCurrMtl : ObjMtl = new ObjMtl ();
			materials.push (pCurrMtl);
			var filesize : int = data.length;
			if (filesize == 0)
			{
				trace ("空文件");
				return null;
			}
			// Process obj information
			var pBufPtr : ByteArray = data;
			pBufPtr.position = 0;
			while (pBufPtr.bytesAvailable > 0)
			{
				// read a line from the buffer
				var line : Array = readLine (pBufPtr);
				// check line has data
				if (line.length == 0)
				{
					continue;
				}
				var word0 : String = line [0];
				switch (word0.charAt (0)) // switch first character
				
				{
					case '#' : // comment
					// get next line
					break;
					case 'm' : // mtllib (material)
					//goAndCopyNextWord(wordBuffer, pBufPtr, WORD_BUFFER_LENGTH, pBufEnd);
					//readMTL(wordBuffer, obj_relpath);
					//pBufPtr = goNextLine(pBufPtr, pBufEnd);
					break;
					case 'v' : // v, vn, vt
					switch (word0.charAt (1)) // switch second character
					
					{
						case '' : // vertex
						
						{
							// vector
							if (line.length > 3)
							{
								var n0 : Number = - Number (line [1]);
								var n1 : Number = Number (line [2]);
								var n2 : Number = Number (line [3]);
								if (isNaN (n0) || isNaN (n1) || isNaN (n2))
								{
									trace ("Obj Mesh Loader - incorrect vertex data found");
									return null;
								} 
								else
								{
									vertexBuffer.push (new Vector3D (n0, n1, n2));
								}
							} 
							else
							{
								trace ("Obj Mesh Loader - incorrect vertex data found");
								return null;
							}
						}
						break;
						case 'n' : // normal
						
						{
							if (line.length > 3)
							{
								n0 = - Number (line [1]);
								n1 = Number (line [2]);
								n2 = Number (line [3]);
								normalsBuffer.push (new Vector3D (n0, n1, n2));
							} 
							else
							{
								trace ("Obj Mesh Loader - incorrect normal data found");
								return null;
							}
						}
						break;
						case 't' : // texcoord
						
						{
							// vector
							if (line.length > 2)
							{
								n0 = Number (line [1]);
								n1 = - Number (line [2]);
								textureCoordBuffer.push (new Vector2D (n0, n1));
							} 
							else
							{
								trace ("Obj Mesh Loader - incorrect texcoord data found");
								return null;
							}
						}
						break;
						default :
						break;
					}
					break;
					case 'g' : // group
					// get name of group
					
					{
						if (line.length > 1)
						{
							var group_name : String = line [1];
							pCurrGroup = findOrAddGroup (group_name);
						} 
						else
						{
							trace ("Obj Mesh Loader - incorrect group name data");
							return null;
						}
					}
					break;
					case 'u' : // usemtl  or usemap
					if (line.length < 2)
					{
						trace ("Obj Mesh Loader - incorrect usemtl or usemap data");
						return null;
						break;
					}
					switch (word0.substr (0, 6))
					{
						case 'usemtl' :
						{
							var mat_name : String = line [1];
							pCurrMtl = findMtl (mat_name);
							if ( ! pCurrMtl)
							{
								// make new material
								pCurrMtl = this.newMtl (mat_name);
							}
							break;
						}
						case 'usemap' :
						{
							var tex_name : String = line [1];
							break
						}
					}
					break;
					case 'f' : // face
					
					{
						/*	v 0.000000 2.000000 2.000000
						v 0.000000 0.000000 2.000000
						v 2.000000 0.000000 2.000000
						v 2.000000 2.000000 2.000000
						...
						f 1 2 3 4
						f 8 7 6 5
						...
						
						OR
						
						v 0.000000 2.000000 2.000000
						v 0.000000 0.000000 2.000000
						v 2.000000 0.000000 2.000000
						v 2.000000 2.000000 2.000000
						f -4 -3 -2 -1
						*/
						// check there is enough data
						if (line.length < 2)
						{
							break;
						}
						// get vertices for current buffer
						var vertices : Vector.<Vertex> = pCurrMtl.getMeshBuffer ().vertices;
						var vertices_length : int = vertices.length;
						// number of vertices in this face - because .objs support n-gons
						var facePointCount : int = 0;
						// loop all words - which in this case are the face's vertices
						var l : int = line.length;
						for (var i : int = 1; i < l; i ++)
						{
							// get word
							var wordN : String = line [i];
							// split of vert data - "/" sep
							var vert_data : Array = wordN.split ("/");
							var vert_data_length : int = vert_data.length;
							if (vert_data_length == 1) // vertex index only
							
							{
								// create vertex
								var idx_vx : int = int (vert_data [0])
								var idx_vt : int = 0;
								var idx_vn : int = 0;
							} 
							else if (vert_data_length == 2) // vertex & tex index
							
							{
								idx_vx = int (vert_data [0]);
								idx_vt = int (vert_data [1]);
								idx_vn = 0;
							} 
							else if (vert_data_length == 3) // vertex, tex & normal index
							
							{
								/*
								can be v/vt/vn or v//vn (no texture)
								*/
								if (vert_data [1] != "")
								{
									idx_vx = int (vert_data [0]);
									idx_vt = int (vert_data [1]);
									idx_vn = int (vert_data [2]);
								} 
								else
								{
									idx_vx = int (vert_data [0]);
									idx_vt = 0;
									idx_vn = int (vert_data [2]);
								}
							}
							// check for non-numbers
							if (isNaN (idx_vx) || isNaN (idx_vt) || isNaN (idx_vn))
							{
								trace ("Obj Mesh Loader - could not parse face");
								return null;
								break;
							}
							// check refrences (can be negative)
							if (idx_vx < 0)
							{
								idx_vx = (vertexBuffer.length + idx_vx);
							} 
							else
							{
								idx_vx -= 1;
							}
							if (idx_vt < 0)
							{
								idx_vt = (textureCoordBuffer.length + idx_vt);
							} 
							else
							{
								idx_vt -= 1;
							}
							if (idx_vn < 0)
							{
								idx_vn = (normalsBuffer.length + idx_vn);
							} 
							else
							{
								idx_vn -= 1;
							}
							// check range
							if (idx_vx >= vertexBuffer.length || idx_vt >= textureCoordBuffer.length || idx_vn >= normalsBuffer.length)
							{
								trace ("Obj Mesh Loader - could not parse face");
								return null;
								break;
							}
							// get pointers
							var p_vec : Vector3D = null;
							var p_tx : Vector2D = null;
							var p_nm : Vector3D = null;
							if (idx_vx > - 1)
							{
								p_vec = vertexBuffer [idx_vx];
							}
							if (idx_vt > - 1)
							{
								p_tx = textureCoordBuffer [idx_vt];
							}
							if (idx_vn > - 1)
							{
								p_nm = normalsBuffer [idx_vn]
							}
							var v : Vertex = new Vertex ();
							v.x = p_vec.x;
							v.y = p_vec.y;
							v.z = p_vec.z;
							v.nx = p_nm.x;
							v.ny = p_nm.y;
							v.nz = p_nm.z;
							v.color = pCurrMtl.getMeshBuffer ().material.diffuseColor.color;
							v.u = p_tx.x;
							v.v = p_tx.y;
							vertices.push (v)
							facePointCount ++;
						}
						// check we have 3 or more vertices
						if ((vertices.length - vertices_length) > 2)
						{
							var indices :Vector.<int> = pCurrMtl.getMeshBuffer ().indices;
							// Add indices for first 3 vertices
							indices.push (vertices_length );
							indices.push ((facePointCount - 1 ) + vertices_length );
							indices.push ((facePointCount - 2 ) + vertices_length );
							// Add indices for subsequent vertices
							l = (facePointCount - 3);
							for (i = 0; i < l; i ++)
							{
								indices.push (vertices_length );
								indices.push ((facePointCount - 2 - i ) + vertices_length );
								indices.push ((facePointCount - 3 - i ) + vertices_length );
							}
						}
					}
					break;
					default :
					// get next line
					break;
				}	// end switch()
				
			}	// end while(pBufPtr.bytesAvailable)
			// Combine all the groups (meshbuffers) into the mesh
			var mat0 : ObjMtl;
			var mesh_buffer : MeshBuffer;
			var ml : int = materials.length;
			for (var m : int = 0; m < ml; m ++)
			{
				mat0 = materials [m];
				mesh_buffer = mat0.getMeshBuffer ();
				if (mesh_buffer.indices.length > 0 )
				{
					mesh_buffer.recalculateBoundingBox ();
					MeshManipulator.recalculateNormals (mesh_buffer, true);
					_mesh.addMeshBuffer (mesh_buffer);
				}
			}

			_mesh.recalculateBoundingBox ();
			// more cleaning up
			materials = null;
			groups = null;
			return _mesh;
		}
		private function findMtl (matName : String) : ObjMtl
		{
			var l : int = materials.length;
			for (var i : int = 0; i < l; i ++)
			{
				var mat : ObjMtl = materials [i];
				if (mat.getName () == matName)
				{
					return mat;
				}
			}
			return null;
		}
		private function newMtl (matName : String) : ObjMtl
		{
			var mat : ObjMtl = new ObjMtl ();
			mat.setName (matName);
			materials.push (mat);
			return mat;
		}
		private function readLine (buf : ByteArray) : Array
		{
			var out : Array = new Array ();
			// look for tab or space characters to trim off start of line
			while (true)
			{
				if (buf.bytesAvailable == 0)
				{
					// end of buffer check
					break;
				}
				var char : int = buf.readUnsignedByte ();
				if ( ! (char == CHAR_SPACE || char == CHAR_TAB))
				{
					// found a non space or tab, start reading from here
					buf.position = (buf.position - 1);
					break;
				}
			}
			/* read into an array as string. array is delimitered by spaces or tabs
			only read to the end of the line*/
			var word : String = new String ('');
			while (true)
			{
				if (buf.bytesAvailable == 0)
				{
					// end of buffer check
					break;
				}
				char = buf.readUnsignedByte ();
				if (char == CHAR_NEWLINE || char == CHAR_RETURN)
				{
					// end of line - end reading here
					break;
				} 
				else if (char == CHAR_SPACE || char == CHAR_TAB)
				{
					// deliminator - add word to array
					if (word.length > 0)
					{
						out.push (word);
						word = new String ('');
					}
				} 
				else
				{
					// add to word
					word += String.fromCharCode (char);
				}
			}
			// add last word
			if (word.length > 0)
			{
				out.push (word);
			}
			// return array of words
			return out;
		}
		private function findGroup (groupName : String) : ObjGroup
		{
			var l : int = groups.length;
			for (var i : int = 0; i < l; i ++)
			{
				var group : ObjGroup = groups [i];
				if (group.name == groupName)
				{
					return group;
				}
			}
			return null;
		}
		private function findOrAddGroup (groupName : String) : ObjGroup
		{
			var group : ObjGroup = findGroup (groupName);
			if (group != null)
			{
				// group found, return it
				return group;
			}
			// group not found, create a new group
			group = new ObjGroup ();
			group.name = groupName;
			groups.push (group);
			return group;
		}
	}
}
class ObjGroup
{
	public var name : String
}
import linda.mesh.MeshBuffer;
class ObjMtl
{
	private var _mesh_buffer : MeshBuffer;
	private var _name : String;
	public function ObjMtl ()
	{
		_name = '';
		_mesh_buffer = new MeshBuffer ();
		_mesh_buffer.material.ambientColor.color = 0x333333;
		_mesh_buffer.material.diffuseColor.color = 0xdddddd;
	}
	public function setName (name : String) : void
	{
		_name = name;
		_mesh_buffer.material.name = _name;
	}
	public function getName () : String
	{
		return _name;
	}
	public function getMeshBuffer () : MeshBuffer
	{
		return _mesh_buffer;
	}
}

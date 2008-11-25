package mini3d.render
{
	import flash.display.Sprite;
	
	import mini3d.core.Material;
	import mini3d.core.Triangle3D;
	import mini3d.core.Vertex;
	import mini3d.core.Vertex4D;
	import mini3d.math.Dimension2D;
	import mini3d.math.Matrix4;
	import mini3d.math.Vector3D;
	import mini3d.math.Vector4D;
	import mini3d.mesh.MeshBuffer;
	import mini3d.scene.CameraSceneNode;

	public class RenderManager
	{
		private var _transformedFaceList:Array;
		
		private var _faceCount:int;

		private var _primitiveCount:int;
		
		private var _current:Matrix4;
		private var _view : Matrix4;
		private var _projection : Matrix4;
		private var _view_project : Matrix4;
		private var _world : Matrix4;
		private var _world_inv : Matrix4;
		private var _clip_scale : Matrix4;
		
		
		private var _inverse_Camera_Position : Vector3D;
		private var _camera_Position : Vector3D;
		
		private var _camera:CameraSceneNode;

		private var _screenSize:Dimension2D;

		private var _render:ITriangleRender;
		
		private var _target:Sprite;
		
		private var _material:Material;
		
		private var _ndc_planes : Array;
		
		private var _clipped_vertices : Array;
		private var _clipped_indices : Array;
		private var _unclipped_vertices : Array
		private var _clipped_vertices0 : Array;

		private var _transformedPoints:Array;
		
		private static var Width:int=400;
		private static var Height:int=400;
		
		public function RenderManager(size:Dimension2D=null)
		{
			if(size == null)
			{
				size = new Dimension2D(Width,Height);
			}
            init(size);            
		}
		private function init(size:Dimension2D):void
		{
			_transformedFaceList=new Array();
			for(var i:int=0;i<600;i++)
			{
				_transformedFaceList.push(new Triangle3D());
			}
			
			_transformedPoints = new Array();
			var required_points:int = 12;
			for(i=0; i< required_points; i++)
			{
				_transformedPoints[i] = new Vertex4D();
			}
			
			// arrays for storing clipped vertices & indices
			_clipped_indices = new Array ();
			_clipped_vertices = new Array ();
			_clipped_vertices0 = new Array ();
			_unclipped_vertices = new Array (); 

			_render=new TriangleRender();
	
			//matrix4
			_current = new Matrix4 ();
			_view = new Matrix4 ();
			_projection = new Matrix4 ();
			_view_project = new Matrix4 ();
			_world_inv = new Matrix4 ();
			_clip_scale=new Matrix4();
			
			_inverse_Camera_Position = new Vector3D ();
			_camera_Position = new Vector3D ();
			
			_ndc_planes = [new Vector4D (  0,  0,  1, -1 ) , // far
			               new Vector4D (  0,  0, -1, -1 ) , // near
			               new Vector4D (  1,  0,  0, -1 ) , // left
			               new Vector4D ( -1,  0,  0, -1 ) , // right
			               new Vector4D (  0,  1,  0, -1 ) , // bottom
			               new Vector4D (  0, -1,  0, -1 ) //top
			               ];
			               
			setScreenSize(size); 
		}

		public function beginScene():void
		{
			_faceCount=0;
			_primitiveCount=0;
		}
		
		public function endScene():void
		{
			_render.drawTriangleList(_transformedFaceList,_faceCount);
		}
		public function setRender(render:ITriangleRender):void
		{
			this._render=render;
		}
		public function setTransformWorld(mat:Matrix4):void
		{
			_world = mat;
		
			_current.copy (_view_project);
			_current.multiplyE (_world);
			_world.getInverse (_world_inv);
			_inverse_Camera_Position.copy(_camera_Position);
			_world_inv.transformVector(_inverse_Camera_Position);
		}
		
		public function setTransformView (mat : Matrix4) : void
		{
			_view = mat;
			_view_project.copy (_projection);
			_view_project.multiplyE (_view);
		}
		public  function setTransformProjection (mat : Matrix4) : void
		{
			_projection = mat;
		}
		public function setTransformViewProjection (mat : Matrix4) : void
		{
			_view_project = mat;
		}
		public function setMaterial(material:Material):void
		{
			_material=material;
		}

		public function drawTriangleList(target:Sprite,vertices:Array,vertexCount:int,indices:Array, indexCount:int):void
		{
			var requiredCount:int = (indexCount*2) + 1;
			if( _faceCount + requiredCount > _transformedFaceList.length)
			{
				for(i = _transformedFaceList.length; i< requiredCount; i+=1)
				{
					_transformedFaceList[i] = new Triangle3D();
				}
			}
			
			var v0 : Vertex;
			var v1 : Vertex;
			var v2 : Vertex;
			var tv0 : Vertex4D;
			var tv1 : Vertex4D;
			var tv2 : Vertex4D;
			var tCount : int;
			var iCount : int;
			var vCount : int;
			var vCount2 : int;

			tCount = 0;
			iCount = 0;
			vCount = 0;
			vCount2 = 0;

			var backfaceCulling : Boolean = _material.backfaceCulling;
			var hasTexture : Boolean =(_material.texture!=null && _material.texture.bitmapData!=null);

			var m00 : Number = _current.m00;var m10 : Number = _current.m10;var m20 : Number = _current.m20;var m30 : Number = _current.m30;
			var m01 : Number = _current.m01;var m11 : Number = _current.m11;var m21 : Number = _current.m21;var m31 : Number = _current.m31;
			var m02 : Number = _current.m02;var m12 : Number = _current.m12;var m22 : Number = _current.m22;var m32 : Number = _current.m32;
			var m03 : Number = _current.m03;var m13 : Number = _current.m13;var m23 : Number = _current.m23;var m33 : Number = _current.m33;
			var csm00 : Number = _clip_scale.m00;var csm30 : Number = _clip_scale.m30;
			var csm11 : Number = _clip_scale.m11;var csm31 : Number = _clip_scale.m31;
            
            var ii:int;
            var tc:int;
			for (tc = 0; tc < indexCount; tc += 3)
			{
				ii = indices [int(tc + 0)];
				v0 = vertices[ii];
				ii = indices [int(tc + 1)];
				v1 = vertices[ii];
				ii = indices [int(tc + 2)];
				v2 = vertices[ii];
				if (backfaceCulling)
				{
					if (((v1.y - v0.y) * (v2.z - v0.z) - (v1.z - v0.z) * (v2.y - v0.y)) * (_inverse_Camera_Position.x - v0.x) +
					    ((v1.z - v0.z) * (v2.x - v0.x) - (v1.x - v0.x) * (v2.z - v0.z)) * (_inverse_Camera_Position.y - v0.y) +
					    ((v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x)) * (_inverse_Camera_Position.z - v0.z) <= 0)
					{
						continue;
					}
				}
				
				var tri:Triangle3D=_transformedFaceList[_faceCount++];
				
				tri.target=target;
				tri.material=_material;
				if(hasTexture)
				{
					tri.bitmapData=_material.texture.bitmapData;
				}else
				{
					tri.bitmapData=null;
				}

				tv0 = tri.p0;
				tv1 = tri.p1;
				tv2 = tri.p2;
				
				//	- transform Model * World * Camera * Projection matrix ,then after clip and light * NDCSpace matrix
				tv0.x = m00 * v0.x + m10 * v0.y + m20 * v0.z + m30;
				tv0.y = m01 * v0.x + m11 * v0.y + m21 * v0.z + m31;
				tv0.z = m02 * v0.x + m12 * v0.y + m22 * v0.z + m32;
				tv0.w = m03 * v0.x + m13 * v0.y + m23 * v0.z + m33;
				
				tv1.x = m00 * v1.x + m10 * v1.y + m20 * v1.z + m30;
				tv1.y = m01 * v1.x + m11 * v1.y + m21 * v1.z + m31;
				tv1.z = m02 * v1.x + m12 * v1.y + m22 * v1.z + m32;
				tv1.w = m03 * v1.x + m13 * v1.y + m23 * v1.z + m33;
				
				tv2.x = m00 * v2.x + m10 * v2.y + m20 * v2.z + m30;
				tv2.y = m01 * v2.x + m11 * v2.y + m21 * v2.z + m31;
				tv2.z = m02 * v2.x + m12 * v2.y + m22 * v2.z + m32;
				tv2.w = m03 * v2.x + m13 * v2.y + m23 * v2.z + m33;
                
                
                //判断是否完全在视景体内
				var inside : Boolean = true;
				var clipcount : int = 0;
				for (var p : int = 0; p < 6; p+=1)
				{
					plane = _ndc_planes [p];
					if (((tv0.x * plane.x) + (tv0.y * plane.y) + (tv0.z * plane.z) + (tv0.w * plane.w)) > 0.0)
					{
						if (((tv1.x * plane.x) + (tv1.y * plane.y) + (tv1.z * plane.z) + (tv1.w * plane.w)) > 0.0)
						{
							if (((tv2.x * plane.x) + (tv2.y * plane.y) + (tv2.z * plane.z) + (tv2.w * plane.w)) > 0.0)
							{
								inside = false;
								break;
							}
						}
						clipcount += (1 << p);
					} 
					else
					{
						if (((tv1.x * plane.x) + (tv1.y * plane.y) + (tv1.z * plane.z) + (tv1.w * plane.w)) < 0.0)
						{
							if (((tv2.x * plane.x) + (tv2.y * plane.y) + (tv2.z * plane.z) + (tv2.w * plane.w)) < 0.0)
							{
								// 在视景体内
							} 
							else
							{
								clipcount += (1 << p);
							}
						} 
						else
						{
							clipcount += (1 << p);
						}
					}
				}
				
				if(!inside)
				{
					_faceCount--;
					continue;
				}
				
				// texture coords
				if (hasTexture)
				{
					tv0.u = v0.u ;
					tv0.v = v0.v ;
					tv1.u = v1.u ;
					tv1.v = v1.v ;
					tv2.u = v2.u ;
					tv2.v = v2.v ;
				}
				if (clipcount == 0) // no clipping required
				{
					//tv0
					var tmp : Number = 1 / tv0.w ;
					tv0.x = (tv0.x * csm00) * tmp + csm30;
					tv0.y = (tv0.y * csm11) * tmp + csm31;
					tv0.z = tmp;
					//tv1
					tmp = 1 / tv1.w ;
					tv1.x = (tv1.x * csm00) * tmp + csm30;
					tv1.y = (tv1.y * csm11) * tmp + csm31;
					tv1.z = tmp;
					//tv2
					tmp = 1 / tv2.w ;
					tv2.x = (tv2.x * csm00) * tmp + csm30;
					tv2.y = (tv2.y * csm11) * tmp + csm31;
					tv2.z = tmp;
					
					vCount+=3;										
					continue;
				}
				
				//clipping
				var a : Vertex4D;
				var b : Vertex4D;
				var out : Vertex4D;
				var inCount : int;
				var outCount : int;
				var dest : Array;
				var plane : Vector4D;
				var source : Array;
				var aPlane : Number;
				var bPlane : Number;
				var t : Number;
				
				//只对近裁剪面进行裁剪
				tCount = 0;
				_unclipped_vertices[0] = _transformedPoints[tCount++];
				_unclipped_vertices[1] = _transformedPoints[tCount++];
				_unclipped_vertices[2] = _transformedPoints[tCount++];
				
				// copy current values
				_unclipped_vertices[0].copy(tv0);
				_unclipped_vertices[1].copy(tv1);
				_unclipped_vertices[2].copy(tv2);
				
				// face not being used now
				_faceCount--;
				
				source = _unclipped_vertices;
				outCount = 3;
				// near----------------------------------------------------------------
				//new Vector4D (0.0, 0.0, - 1.0, - 1.0 )
				if ((clipcount & 2) == 2)
				{
					inCount = outCount;
					outCount = 0;
					dest = _clipped_vertices0;
					plane = _ndc_planes[1];
					b = source[0];
					bPlane = b.z * plane.z + b.w * plane.w;
					for (var i:int = 1; i < inCount + 1; i ++)
					{
						a = source [int(i % inCount)];
						aPlane = (a.z * plane.z) + (a.w * plane.w);
						if (aPlane <= 0.0 )
						{
							if (bPlane > 0.0 )
							{
								out = _transformedPoints [int(tCount ++)];
								dest [int(outCount++)] = out;
								t = bPlane / ((b.z - a.z) * plane.z + (b.w - a.w) * plane.w);
								out.x = b.x + (a.x - b.x) * t ;
								out.y = b.y + (a.y - b.y) * t ;
								out.z = b.z + (a.z - b.z) * t ;
								out.w = b.w + (a.w - b.w) * t ;

								if(hasTexture)
								{
									out.u = b.u + (a.u - b.u) * t ;
									out.v = b.v + (a.v - b.v) * t ;
								}	
							}
							dest [int(outCount ++)] = a;
						} 
						else
						{
							if (bPlane <= 0.0 )
							{
								out = _transformedPoints [int(tCount ++)];
								dest[int(outCount ++)] = out;

								t = bPlane / ((b.z - a.z) * plane.z + (b.w - a.w) * plane.w);

								out.x = b.x + (a.x - b.x) * t ;
								out.y = b.y + (a.y - b.y) * t ;
								out.z = b.z + (a.z - b.z) * t ;
								out.w = b.w + (a.w - b.w) * t ;

								if(hasTexture)
								{
									out.u = b.u + (a.u - b.u) * t ;
									out.v = b.v + (a.v - b.v) * t ;
								}
							}
						}
						b = a;
						bPlane = aPlane;
					}
					// check we have 3 or more vertices
					if (outCount < 3)
					{
						continue;
					}
					source = _clipped_vertices0;
				}

				//计算屏幕坐标
				vCount2 = vCount;
				for (var g : int = 0; g < outCount; g ++)
				{
					tv0 = source [g];
					tmp = 1 / tv0.w ;
					tv0.x = (tv0.x * csm00) * tmp + csm30;
					tv0.y = (tv0.y * csm11) * tmp + csm31;
					tv0.z = tmp;

					_clipped_vertices [int(vCount++)] = tv0;
				}
				
				/* Put into faces ( triangle-fan, 0-1-2,0-2-3.. )
				*/
				for ( g=0; g <= outCount-3; g++ )
				{
					var newTri:Triangle3D = _transformedFaceList[_faceCount++];
					
					// set material
					newTri.material = _material;
					
					// add the three points
					newTri.p0.copy(_clipped_vertices[(vCount2)]);
					newTri.p1.copy(_clipped_vertices[(vCount2+g+1)]);
					newTri.p2.copy(_clipped_vertices[(vCount2+g+2)]);
				}
			}
			_primitiveCount += tCount;
		}
		
		public function drawMeshBuffer(target:Sprite,buffer:MeshBuffer):void
		{
			drawTriangleList(target,buffer.vertices,buffer.vertices.length,buffer.indices,buffer.indices.length);
		}
		
		public function getScreenSize():Dimension2D
		{
			return _screenSize;
		}
		
		public function setScreenSize(size:Dimension2D):void
		{
			_screenSize=size;
			_clip_scale.buildNDCToDCMatrix(_screenSize,1);
		}
		
		public function getPrimitiveCountDrawn():int
		{
			return _primitiveCount;
		}
		public function setCameraPosition (pos : Vector3D) : void
		{
			if(pos)
			{
			   _camera_Position.x=pos.x;
			   _camera_Position.y=pos.y;
			   _camera_Position.z=pos.z;
			}
		}
	}
}
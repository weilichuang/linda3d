package linda.video;

	import flash.Vector;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	import linda.light.Light;
	import linda.material.ITexture;
	import linda.material.Material;
	import linda.math.Vector3;
	import linda.math.Vector4;
	import linda.math.Vertex;
	import linda.math.Vertex4D;
	import linda.math.Color;
	import linda.math.Dimension2D;
	import linda.math.Matrix4;
	import linda.math.MathUtil;
	import linda.mesh.MeshBuffer;
	import linda.video.pixel.TRFlat;
	import linda.video.pixel.TRFlatAlpha;
	import linda.video.pixel.TRGouraud;
	import linda.video.pixel.TRGouraudAlpha;
	import linda.video.pixel.TRTextureFlat;
	import linda.video.pixel.TRTextureFlatAlpha;
	import linda.video.pixel.TRTextureGouraud;
	import linda.video.pixel.TRTextureGouraudAlpha;
	import linda.video.pixel.TRWire;

	class VideoSoftware extends VideoNull,implements IVideoDriver
	{
		private var curRender : ITriangleRenderer;
		private var renderers : Vector<ITriangleRenderer>;
		
		private var target : Bitmap;
		private var rect:Rectangle;

		private var targetVector : Vector<UInt>;
		private var bufferVector : Vector<Float>;
		
		private var _clip_scale : Matrix4;

		private var texture : ITexture;
		private var material : Material;
		
		private var _lightDirs : Vector<Vector3>;
		private var _lightsPos : Vector<Vector3>;
		
		
		//matrix vars
		private var _view : Matrix4;
		private var _world : Matrix4;
		//ClipScale from NDC to DC Space
		private var _projection : Matrix4;
		private var _current : Matrix4 ;
		private var _view_project : Matrix4;
		private var _world_inv : Matrix4;
		
		private var _oppcam_pos : Vector3;
		private var _cam_pos : Vector3;
		
		private var _ndc_planes         : Vector<Vector4>;

		private var _transformedVertexs : Vector<Vertex4D>;
		private var _unclipped_vertices : Vector<Vertex4D>;
		private var _clipped_vertices   : Vector<Vertex4D>;
		private var _clipped_indices    : Vector<Int>;
		private var _clipped_vertices0  : Vector<Vertex4D>;
		private var _clipped_vertices1  : Vector<Vertex4D>;
		private var _clipped_vertices2  : Vector<Vertex4D>;
		private var _clipped_vertices3  : Vector<Vertex4D>;
		private var _clipped_vertices4  : Vector<Vertex4D>;
		
		
		private var l : Vector3 ;
		private var n : Vector3 ;
		private var v : Vector3 ;

		public function new (size : Dimension2D)
		{
			super();
			
			init(size);
			
			l  = new Vector3 ();
		    n  = new Vector3 ();
		    v  = new Vector3 ();
		}
		private function init (size:Dimension2D) : Void
		{
			target = new Bitmap ();
			renderTarget.addChild(target);
			
			_clip_scale = new Matrix4 ();

			//render
			renderers = new Vector<ITriangleRenderer>(TRType.COUNT, true);
			renderers [TRType.WIRE]                  = new TRWire ();
			renderers [TRType.FLAT]                  = new TRFlat ();
			renderers [TRType.GOURAUD]               = new TRGouraud ();
			renderers [TRType.TEXTURE_FLAT]          = new TRTextureFlat ();
			renderers [TRType.TEXTURE_GOURAUD]       = new TRTextureGouraud ();
			renderers [TRType.FLAT_ALPHA]            = new TRFlatAlpha ();
			renderers [TRType.GOURAUD_ALPHA]         = new TRGouraudAlpha ();
			renderers [TRType.TEXTURE_FLAT_ALPHA]    = new TRTextureFlatAlpha ();
			renderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha ();

			//预存一些点
			_transformedVertexs = new Vector<Vertex4D>(2000);
			for ( i in 0...2000)
			{
				_transformedVertexs[i] = new Vertex4D();
			}
			//matrix4
			_current      = new Matrix4();
			_view         = new Matrix4();
			_projection   = new Matrix4();
			_view_project = new Matrix4();
			_world_inv    = new Matrix4();
			
			
			//lighting
			var count:Int=getMaxLightAmount();
			_lightDirs = new Vector<Vector3>(count,true);
			_lightsPos = new Vector<Vector3>(count,true);
			for (i in 0...count)
			{
				_lightDirs[i]=new Vector3();
				_lightsPos[i]=new Vector3();
			}
			
			_oppcam_pos = new Vector3();
			_cam_pos    = new Vector3();
			
			
			/*
			generic plane clipping in homogenous coordinates
			special case ndc frustum <-w,w>,<-w,w>,<-w,w>
			can be rewritten with compares e.q near plane, a.z < -a.w and b.z < -b.w
			*/
			_ndc_planes = new Vector<Vector4>(6,true);
			
			_ndc_planes[0]=new Vector4(0.0 , 0.0 , -1.0, -1.0 ); // near
			_ndc_planes[1]=new Vector4(0.0 , 0.0 , 1.0 , -1.0 ); // far
			_ndc_planes[2]=new Vector4(1.0 , 0.0 , 0.0 , -1.0 ); // left
			_ndc_planes[3]=new Vector4(-1.0, 0.0 , 0.0 , -1.0 ); // right
			_ndc_planes[4]=new Vector4(0.0 , 1.0 , 0.0 , -1.0 ); // bottom
			_ndc_planes[5]=new Vector4(0.0 , -1.0, 0.0 , -1.0 ); //top

			// arrays for storing clipped vertices & indices
			_clipped_indices = new Vector<Int>();
			
			_clipped_vertices   = new Vector<Vertex4D>();
			_unclipped_vertices = new Vector<Vertex4D>();
			_clipped_vertices0  = new Vector<Vertex4D>();
			_clipped_vertices1  = new Vector<Vertex4D>();
			_clipped_vertices2  = new Vector<Vertex4D>();
			_clipped_vertices3  = new Vector<Vertex4D>();
			_clipped_vertices4  = new Vector<Vertex4D>();

			targetVector=new Vector<UInt>();
			bufferVector=new Vector<Float>();
			
			setVector(targetVector,bufferVector);

			setScreenSize(size);
		}
		private function reset():Void
		{
			//Todo 不知道有没有更好的方法了:)
			targetVector.length = 0;
			bufferVector.length = 0;
			var len:Int = screenSize.width * screenSize.height;
			targetVector.length = len;
			bufferVector.length = len;
		}
		private function getTRIndex () : Int
		{
			if(material.wireframe) return TRType.WIRE;

			var gouraudShading : Bool = material.gouraudShading;
			var lighting:Bool = material.lighting;
			
			if (material.transparenting)
			{
					if (texture!=null)
					{
						if(lighting)
						{
							return TRType.TEXTURE_GOURAUD_ALPHA;
						}else
						{
							return TRType.TEXTURE_FLAT_ALPHA;
						}
					} else
					{
						if (gouraudShading)
						{
							return TRType.GOURAUD_ALPHA;
						} else
						{
							return TRType.FLAT_ALPHA;
						}
					}
			} else
			{
					if (texture!=null)
					{
						if(lighting)
						{
							return TRType.TEXTURE_GOURAUD;
						}else
						{
							return TRType.TEXTURE_FLAT;
						}
					} else
					{
						if (gouraudShading)
						{
							return TRType.GOURAUD;
						} else
						{
							return TRType.FLAT;
						}
					}
			}
		}

		public  function beginScene ():Void
		{
			primitivesDrawn = 0;
			reset();
		}
		public  function endScene():Void
		{
			target.bitmapData.lock();
			target.bitmapData.setVector(rect,targetVector);
			target.bitmapData.unlock();
		}
		public function setTransformViewProjection(mat : Matrix4) : Void
		{
			_view_project = mat;
		}
		public function setTransformProjection (mat : Matrix4) : Void
		{
			_projection = mat;
		}
		public function setCameraPosition (pos : Vector3) : Void
		{
			_cam_pos = pos;
		}
		public  function setTransformWorld (mat : Matrix4) : Void
		{
			_world = mat;
			
			_current.copy(_view_project);
			_current.multiplyE(_world);
			//Log.trace(_view_project);
			//Log.trace(_current);
			
			_world_inv.copy(_world);
			_world_inv.inverse();

			_oppcam_pos.copy(_cam_pos);
			_world_inv.transformVector(_oppcam_pos);
		}

		public function setTransformView (mat : Matrix4) : Void
		{
			_view = mat;
			_view_project.copy(_projection);
			_view_project.multiplyE(_view);
		}

		override public function setMaterial (mat : Material) : Void
		{
			material = mat;
			texture = material.texture1;
			
			var index:Int=getTRIndex();
			curRender = renderers[index];
			curRender.setMaterial(material);
		}

		public  function setScreenSize (size : Dimension2D) : Void
		{
			if(size==null)
            {
            	size=new Dimension2D(300,300);
            }
            
			screenSize = size;
			
			rect=screenSize.toRect();
			
			if(target.bitmapData!=null)
			{
				target.bitmapData.fillRect(rect,0x0);
			}else
			{
				target.bitmapData = new BitmapData(screenSize.width, screenSize.height, false, 0);
			}
			
			_clip_scale.buildNDCToDCMatrix(screenSize,1);
			
			var len:Int=screenSize.width*screenSize.height;
			targetVector.length=len;
			bufferVector.length=len;
			
			setHeight(screenSize.height);
		}
		public override function setRenderTarget (target : Sprite) : Void
		{
			if ( target==null) return;
			if (renderTarget!=null) renderTarget.removeChild (target);
			renderTarget = target;
			renderTarget.addChild (target);
		}
		//for light
		public  function drawIndexedTriangleList (vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, triangleCount : Int) : Void
		{
			var v0      : Vertex;
			var v1      : Vertex;
			var v2      : Vertex;
			var tv0     : Vertex4D;
			var tv1     : Vertex4D;
			var tv2     : Vertex4D;
			var tCount  : Int;
			var iCount  : Int; 
			var vCount  : Int;
			var vCount2 : Int;
			
			//clipping
			var a   : Vertex4D;
			var b   : Vertex4D;
			var out : Vertex4D;
			var inCount  : Int;
			var outCount : Int;
			
			var plane  : Vector4;
			var source : Vector<Vertex4D>;
			var dest   : Vector<Vertex4D>;
			var adot   : Float;
			var bdot   : Float;
			var t      : Float;
			
			//lighting
			var light : Light ;
			var pos   : Vector3 ;
			var dir   : Vector3 ;
			var lightLen:Int=getLightCount();

			var len : Int = triangleCount * 2;
			var _transformLen : Int = _transformedVertexs.length;
			if (_transformLen < len)
			{
				for (i in _transformLen...len)
				{
					_transformedVertexs[i] = new Vertex4D ();
				}
			}

			tCount = 0;
			iCount = 0;
			vCount = 0;
			
			//material var
			var lighting        : Bool = material.lighting;
			var backfaceCulling : Bool = material.backfaceCulling;
			var hasTexture      : Bool = (texture!=null);
			var gouraudShading  : Bool = material.gouraudShading;
			if(lighting)
			{
			    // transfrom lights into object's world space
			    for (i in 0...lightLen)
			    {
				    dir   =  _lightDirs[i];
				    pos   =  _lightsPos[i];
				    light =  _lights[i];
					var type:Int = light.type;
				    if ((type == Light.SPOT) || (type == Light.DIRECTIONAL))
				    {
				    	var x:Float = light.direction.x;
				    	var y:Float = light.direction.y;
				    	var z:Float = light.direction.z;
				    	dir.x = x * _world_inv.m00 + y * _world_inv.m10 + z * _world_inv.m20;
				    	dir.y = x * _world_inv.m01 + y * _world_inv.m11 + z * _world_inv.m21;
				    	dir.z = x * _world_inv.m02 + y * _world_inv.m12 + z * _world_inv.m22;
				    	dir.normalize ();
				    }
				    if ((type == Light.SPOT) || (type == Light.POINT))
				    {
					    var x:Float = light.position.x;
					    var y:Float = light.position.y;
					    var z:Float = light.position.z;
					    pos.x = _world_inv.m00 * x + _world_inv.m10 * y + _world_inv.m20 * z + _world_inv.m30;
					    pos.y = _world_inv.m01 * x + _world_inv.m11 * y + _world_inv.m21 * z + _world_inv.m31;
					    pos.z = _world_inv.m02 * x + _world_inv.m12 * y + _world_inv.m22 * z + _world_inv.m32;
				    }
			    }
			}
			
			var m00 : Float = _current.m00;
			var m10 : Float = _current.m10;
			var m20 : Float = _current.m20;
			var m30 : Float = _current.m30;
			var m01 : Float = _current.m01;
			var m11 : Float = _current.m11;
			var m21 : Float = _current.m21;
			var m31 : Float = _current.m31;
			var m02 : Float = _current.m02;
			var m12 : Float = _current.m12;
			var m22 : Float = _current.m22;
			var m32 : Float = _current.m32;
			var m03 : Float = _current.m03;
			var m13 : Float = _current.m13;
			var m23 : Float = _current.m23;
			var m33 : Float = _current.m33;
			var csm00 : Float = _clip_scale.m00;
			var csm30 : Float = _clip_scale.m30;
			var csm11 : Float = _clip_scale.m11;
			var csm31 : Float = _clip_scale.m31;
			var memi : Color = material.emissiveColor;
			var mamb : Color = material.ambientColor;
			var mdif : Color = material.diffuseColor;
			//太阳光与自发光相加，因为在下面计算时这个值不会改变，放在这里统一计算，加快速度.
			var globalR : Int = ambientColor.r + memi.r;
			var globalG : Int = ambientColor.g + memi.g;
			var globalB : Int = ambientColor.b + memi.b;
			
			//Log.trace(_current);
			
			var ii:Int = 0;
			while( ii < triangleCount )
			{
				v0 = vertices [indexList[ii]];
				v1 = vertices [indexList[ii + 1]];
				v2 = vertices [indexList[ii + 2]];
				ii += 3;
				
				if (backfaceCulling)
				{
					if (((v1.y - v0.y) * (v2.z - v0.z) - (v1.z - v0.z) * (v2.y - v0.y)) * (_oppcam_pos.x - v0.x) +
					    ((v1.z - v0.z) * (v2.x - v0.x) - (v1.x - v0.x) * (v2.z - v0.z)) * (_oppcam_pos.y - v0.y) +
					    ((v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x)) * (_oppcam_pos.z - v0.z) <= 0)
					{
						continue;
					}
				}
				
				tv0 = _transformedVertexs [tCount++];
				tv1 = _transformedVertexs [tCount++];
				tv2 = _transformedVertexs [tCount++];
				
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
				

				var inside : Bool = true;
				var clipcount : Int = 0;
				for (p in 0...6)
				{
					plane = _ndc_planes[p];
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
								// triangle is not clipped agianst this plane - check other planes
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
				
				if ( ! inside)
				{
					tCount -= 3;
					continue;
				}
				
								//lighting
				if (lighting)
				{
					//初始化总体环境光照颜色
					var amb_r_sum0 : Float = 0.;
					var amb_r_sum1 : Float = 0.;
					var amb_r_sum2 : Float = 0.;
					var amb_g_sum0 : Float = 0.;
					var amb_g_sum1 : Float = 0.;
					var amb_g_sum2 : Float = 0.;
					var amb_b_sum0 : Float = 0.;
					var amb_b_sum1 : Float = 0.;
					var amb_b_sum2 : Float = 0.;
					//初始化总体反射光照颜色
					var dif_r_sum0 : Float = 0.;
					var dif_g_sum0 : Float = 0.;
					var dif_b_sum0 : Float = 0.;
					var dif_r_sum1 : Float = 0.;
					var dif_g_sum1 : Float = 0.;
					var dif_b_sum1 : Float = 0.;
					var dif_r_sum2 : Float = 0.;
					var dif_g_sum2 : Float = 0.;
					var dif_b_sum2 : Float = 0.;
					//高光部分
					//var spe_r_sum0 : Float = 0;var spe_g_sum0 : Float = 0;var spe_b_sum0 : Float = 0;
					//var spe_r_sum1 : Float = 0;var spe_g_sum1 : Float = 0;var spe_b_sum1 : Float = 0;
					//var spe_r_sum2 : Float = 0;var spe_g_sum2 : Float = 0;var spe_b_sum2 : Float = 0;
					var diffuse : Color;
					var ambient : Color;
					var specular : Color;
					var kc : Float;
					var kl : Float;
					var kq : Float;
					var dist : Float;
					var dist2 : Float;
					var nlen : Float;
					var atten : Float;
					var dpsl : Float;
					var dp : Float;
					var radius : Float;
					var pf : Int;
					var k : Float;

					if (lightLen > 0)
					{
						if ( ! gouraudShading) //flat Light
						{
							for (j in 0...lightLen)
							{
								light = _lights [j];
								var type:Int = light.type;
								pos  = _lightsPos [j];
								dir  = _lightDirs [j];
								diffuse = light.diffuseColor;
								ambient = light.ambientColor;
								//specular = light.specularColor;
								kc = light.kc;
								kl = light.kl;
								kq = light.kq;
								pf = light.powerFactor;
								
								//l=v1.subtractE(v0);
								l.x = v1.x - v0.x;
								l.y = v1.y - v0.y;
								l.z = v1.z - v0.z;
								//v=v2.subtractE(v0);
								v.x = v2.x - v0.x;
								v.y = v2.y - v0.y;
								v.z = v2.z - v0.z;
								//三角形法线
								//n=l.cross(v);
								n.x = l.y * v.z - l.z * v.y;
								n.y = l.z * v.x - l.x * v.z;
								n.z = l.x * v.y - l.y * v.x;
								//法线长度
								nlen = MathUtil.sqrt(n.getLengthSquared());
								
								if (type == 0) //DIRECTIONAL
								{
									dp = (n.x * dir.x + n.y * dir.y + n.z * dir.z) / nlen;
									if (dp > 0)
									{
										amb_r_sum0 += ambient.r / nlen;
										amb_g_sum0 += ambient.g / nlen;
										amb_b_sum0 += ambient.b / nlen;
										dif_r_sum0 += (diffuse.r * dp);
										dif_g_sum0 += (diffuse.g * dp);
										dif_b_sum0 += (diffuse.b * dp);
									}
								} else if (type == 1) //POINT
								{
									l.x = pos.x - v0.x;
									l.y = pos.y - v0.y;
									l.z = pos.z - v0.z;
									dp = (n.x * l.x + n.y * l.y + n.z * l.z);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt(dist2);
										atten = 1 / ((kc + kl * dist + kq * dist2) * nlen);
										k = dp * atten / dist;
										amb_r_sum0 += (ambient.r * atten);
										amb_g_sum0 += (ambient.g * atten);
										amb_b_sum0 += (ambient.b * atten);
										dif_r_sum0 += (diffuse.r * k);
										dif_g_sum0 += (diffuse.g * k);
										dif_b_sum0 += (diffuse.b * k);
									}
								} //SPOT
								{
									l.x = pos.x - v0.x;
									l.y = pos.y - v0.y;
									l.z = pos.z - v0.z;
									dp = n.dotProduct(dir);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt(dist2);
										atten = 1 / ((kc + kl * dist + kq * dist2) * nlen);
										dpsl = l.dotProduct(dir)/ dist;
										if (dpsl > 0 )
										{
											dpsl = Math.pow (dpsl, pf);
											k = dp * dpsl * atten;
											amb_r_sum0 += (ambient.r * atten);
											amb_g_sum0 += (ambient.g * atten);
											amb_b_sum0 += (ambient.b * atten);
											dif_r_sum0 += (diffuse.r * k);
											dif_g_sum0 += (diffuse.g * k);
											dif_b_sum0 += (diffuse.b * k);
										}
									}
								}
							}
							tv0.r = globalR + (Std.int (amb_r_sum0 * mamb.r) >> 8) + (Std.int (dif_r_sum0 * mdif.r) >> 8);
							tv0.g = globalG + (Std.int (amb_g_sum0 * mamb.g) >> 8) + (Std.int (dif_g_sum0 * mdif.g) >> 8);
							tv0.b = globalB + (Std.int (amb_b_sum0 * mamb.b) >> 8) + (Std.int (dif_b_sum0 * mdif.b) >> 8);
							tv1.r = tv0.r;
							tv1.g = tv0.g;
							tv1.b = tv0.b;
							tv2.r = tv0.r;
							tv2.g = tv0.g;
							tv2.b = tv0.b;
						} else
						{
							for (j in 0...lightLen)
							{
								light = _lights [j];
								var type:Int = light.type;
								pos = _lightsPos [j];
								dir = _lightDirs [j];
								diffuse = light.diffuseColor;
								ambient = light.ambientColor;
								//specular = light.specularColor;
								kc = light.kc;
								kl = light.kl;
								kq = light.kq;
								//radius = light.radius;
								pf = light.powerFactor;
								if (type == 0) //DIRECTIONAL
								{
									//tv0
									dp = (v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
									if (dp > 0)
									{
										amb_r_sum0 += ambient.r;
										amb_g_sum0 += ambient.g;
										amb_b_sum0 += ambient.b;
										dif_r_sum0 += (diffuse.r * dp);
										dif_g_sum0 += (diffuse.g * dp);
										dif_b_sum0 += (diffuse.b * dp);
									}
									//tv1
									dp = (v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
									if (dp > 0)
									{
										amb_r_sum1 += ambient.r ;
										amb_g_sum1 += ambient.g ;
										amb_b_sum1 += ambient.b ;
										dif_r_sum1 += (diffuse.r * dp);
										dif_g_sum1 += (diffuse.g * dp);
										dif_b_sum1 += (diffuse.b * dp);
									}
									//tv2
									dp = (v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
									if (dp > 0)
									{
										amb_r_sum2 += ambient.r ;
										amb_g_sum2 += ambient.g ;
										amb_b_sum2 += ambient.b ;
										dif_r_sum2 += (diffuse.r * dp);
										dif_g_sum2 += (diffuse.g * dp);
										dif_b_sum2 += (diffuse.b * dp);
									}
								} else
								if (type == 1) //POINT
								{
									//              I0point * Clpoint
									//  I(d)point = ___________________
									//              kc +  kl*d + kq*d2
									//
									//  Where d = |p - s|
									l.x = - v0.x + pos.x;
									l.y = - v0.y + pos.y;
									l.z = - v0.z + pos.z;
									//tv0
									dp = (v0.nx * l.x + v0.ny * l.y + v0.nz * l.z);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt (dist2);
										atten = 1 / (kc + kl * dist + kq * dist2);
										k = dp * atten / dist;
										amb_r_sum0 += (ambient.r * atten);
										amb_g_sum0 += (ambient.g * atten);
										amb_b_sum0 += (ambient.b * atten);
										dif_r_sum0 += (diffuse.r * k);
										dif_g_sum0 += (diffuse.g * k);
										dif_b_sum0 += (diffuse.b * k);
									}
									//tv1
									l.x = - v1.x + pos.x;
									l.y = - v1.y + pos.y;
									l.z = - v1.z + pos.z;
									dp = (v1.nx * l.x + v1.ny * l.y + v1.nz * l.z);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt (dist2);
										atten = 1 / (kc + kl * dist + kq * dist2);
										k = dp * atten / dist;
										amb_r_sum1 += (ambient.r * atten);
										amb_g_sum1 += (ambient.g * atten);
										amb_b_sum1 += (ambient.b * atten);
										dif_r_sum1 += (diffuse.r * k);
										dif_g_sum1 += (diffuse.g * k);
										dif_b_sum1 += (diffuse.b * k);
									}
									//tv2
									l.x = - v2.x + pos.x;
									l.y = - v2.y + pos.y;
									l.z = - v2.z + pos.z;
									dp = (v2.nx * l.x + v2.ny * l.y + v2.nz * l.z);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt (dist2);
										atten = 1 / (kc + kl * dist + kq * dist2);
										k = dp * atten / dist;
										amb_r_sum2 += (ambient.r * atten);
										amb_g_sum2 += (ambient.g * atten);
										amb_b_sum2 += (ambient.b * atten);
										dif_r_sum2 += (diffuse.r * k);
										dif_g_sum2 += (diffuse.g * k);
										dif_b_sum2 += (diffuse.b * k);
									}
								} //SPOT
								{
									//         	     I0spotlight * Clspotlight * MAX( (l . s), 0)^pf
									// I(d)spotlight = __________________________________________
									//               		 kc + kl*d + kq*d2
									// Where d = |p - s|, and pf = power factor
									//tv0
									l.x = - v0.x + pos.x;
									l.y = - v0.y + pos.y;
									l.z = - v0.z + pos.z;
									dp = (v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt (dist2);
										atten = 1 / (kc + kl * dist + kq * dist2);
										dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
										if (dpsl > 0 )
										{
											dpsl = Math.pow (dpsl, pf);
											k = dp * dpsl * atten;
											amb_r_sum0 += (ambient.r * atten);
											amb_g_sum0 += (ambient.g * atten);
											amb_b_sum0 += (ambient.b * atten);
											dif_r_sum0 += (diffuse.r * k);
											dif_g_sum0 += (diffuse.g * k);
											dif_b_sum0 += (diffuse.b * k);
										}
									}
									//tv1
									l.x = - v1.x + pos.x;
									l.y = - v1.y + pos.y;
									l.z = - v1.z + pos.z;
									dp = (v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt (dist2);
										atten = 1 / (kc + kl * dist + kq * dist2);
										dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
										if (dpsl > 0 )
										{
											dpsl = Math.pow (dpsl, pf);
											k = dp * dpsl * atten;
											amb_r_sum1 += (ambient.r * atten);
											amb_g_sum1 += (ambient.g * atten);
											amb_b_sum1 += (ambient.b * atten);
											dif_r_sum1 += (diffuse.r * k);
											dif_g_sum1 += (diffuse.g * k);
											dif_b_sum1 += (diffuse.b * k);
										}
									}
									//tv2
									l.x = - v2.x + pos.x;
									l.y = - v2.y + pos.y;
									l.z = - v2.z + pos.z;
									dp = (v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
									if (dp > 0)
									{
										dist2 = l.getLengthSquared();
										dist = MathUtil.sqrt (dist2);
										atten = 1 / (kc + kl * dist + kq * dist2);
										dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
										if (dpsl > 0 )
										{
											dpsl = Math.pow (dpsl, pf);
											k = dp * dpsl * atten;
											amb_r_sum2 += (ambient.r * atten);
											amb_g_sum2 += (ambient.g * atten);
											amb_b_sum2 += (ambient.b * atten);
											dif_r_sum2 += (diffuse.r * k);
											dif_g_sum2 += (diffuse.g * k);
											dif_b_sum2 += (diffuse.b * k);
										}
									}
								}
							}
							tv0.r = globalR + (Std.int(amb_r_sum0 * mamb.r) >> 8) + (Std.int(dif_r_sum0 * mdif.r) >> 8);
							tv0.g = globalG + (Std.int(amb_g_sum0 * mamb.g) >> 8) + (Std.int(dif_g_sum0 * mdif.g) >> 8);
							tv0.b = globalB + (Std.int(amb_b_sum0 * mamb.b) >> 8) + (Std.int(dif_b_sum0 * mdif.b) >> 8);
							tv1.r = globalR + (Std.int(amb_r_sum1 * mamb.r) >> 8) + (Std.int(dif_r_sum1 * mdif.r) >> 8);
							tv1.g = globalG + (Std.int(amb_g_sum1 * mamb.g) >> 8) + (Std.int(dif_g_sum1 * mdif.g) >> 8);
							tv1.b = globalB + (Std.int(amb_b_sum1 * mamb.b) >> 8) + (Std.int(dif_b_sum1 * mdif.b) >> 8);
							tv2.r = globalR + (Std.int(amb_r_sum2 * mamb.r) >> 8) + (Std.int(dif_r_sum2 * mdif.r) >> 8);
							tv2.g = globalG + (Std.int(amb_g_sum2 * mamb.g) >> 8) + (Std.int(dif_g_sum2 * mdif.g) >> 8);
							tv2.b = globalB + (Std.int(amb_b_sum2 * mamb.b) >> 8) + (Std.int(dif_b_sum2 * mdif.b) >> 8);
						}
						tv0.r = tv0.r > 0xFF ? 0xFF : tv0.r;
						tv0.g = tv0.g > 0xFF ? 0xFF : tv0.g;
						tv0.b = tv0.b > 0xFF ? 0xFF : tv0.b;
						tv1.r = tv1.r > 0xFF ? 0xFF : tv1.r;
						tv1.g = tv1.g > 0xFF ? 0xFF : tv1.g;
						tv1.b = tv1.b > 0xFF ? 0xFF : tv1.b;
						tv2.r = tv2.r > 0xFF ? 0xFF : tv2.r;
						tv2.g = tv2.g > 0xFF ? 0xFF : tv2.g;
						tv2.b = tv2.b > 0xFF ? 0xFF : tv2.b;
						
					} else //没有灯光，但是接受灯光时，使用自发光
					{
						tv0.r = memi.r ;
						tv0.g = memi.g ;
						tv0.b = memi.b ;
						tv1.r = memi.r ;
						tv1.g = memi.g ;
						tv1.b = memi.b ;
						tv2.r = memi.r ;
						tv2.g = memi.g ;
						tv2.b = memi.b ;
					}
				} else //no lighting
				{
					if (gouraudShading)
					{
						tv0.r = v0.r; tv0.g = v0.g; tv0.b = v0.b;
						tv1.r = v1.r; tv1.g = v1.g; tv1.b = v1.b;
						tv2.r = v2.r; tv2.g = v2.g; tv2.b = v2.b;
					} else //flat
					{
						tv0.r = mdif.r; tv0.g = mdif.g; tv0.b = mdif.b;
						tv1.r = mdif.r; tv1.g = mdif.g; tv1.b = mdif.b;
						tv2.r = mdif.r; tv2.g = mdif.g; tv2.b = mdif.b;
					}
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
					var tmp : Float = 1 / tv0.w ;
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
					// add to _clipped_indices
					_clipped_indices [iCount] = vCount;
					iCount++;
					_clipped_vertices [vCount] = tv0;
					vCount++;
					_clipped_indices [iCount] = vCount;
					iCount++;
					_clipped_vertices [vCount] = tv1;
					vCount++;
					_clipped_indices [iCount] = vCount;
					iCount++;
					_clipped_vertices [vCount] = tv2;
					vCount++;
					continue;
				}
				// put into list for clipping
				_unclipped_vertices[0] = tv0;
				_unclipped_vertices[1] = tv1;
				_unclipped_vertices[2] = tv2;
				
				source = _unclipped_vertices;
				outCount = 3;

				// clip in NDC Space to Frustum
				//new Vector3 (0.0, 0.0, - 1.0, - 1.0 ) near
				if ((clipcount & 2) == 2)
				{
					inCount = outCount;
					outCount = 0;
					dest = _clipped_vertices4;
					plane = _ndc_planes[1];
					b = source[0];
					bdot = (b.z * plane.z) + (b.w * plane.w);
					for (i in 1...(inCount + 1))
					{
						a = source [i % inCount];
						adot = (a.z * plane.z) + (a.w * plane.w);
						// current point inside
						if (adot <= 0.0 )
						{
							// last point outside
							if (bdot > 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
							// add a to out
							dest [outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount ++] = out;
								t = bdot / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					// check we have 3 or more vertices
					if (outCount < 3)
					{
						continue;
					}
					source = _clipped_vertices4;
				}

				//new Vector3 (1.0, 0.0, 0.0, - 1.0 )  left
				if ((clipcount & 4) == 4)
				{
					inCount = outCount;
					outCount = 0;
					dest = _clipped_vertices3;
					plane = _ndc_planes [2];
					b = source [0];
					bdot = (b.x * plane.x) + (b.w * plane.w);
					for (i in 1...(inCount + 1))
					{
						a = source [i % inCount];
						adot = (a.x * plane.x) + (a.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
							// add a to out
							dest [outCount ++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clipped_vertices3;
				}
				//new Vector3 ( - 1.0, 0.0, 0.0, - 1.0 )  right
				if ((clipcount & 8) == 8)
				{
					inCount = outCount;
					outCount = 0;
					dest = _clipped_vertices2;
					plane = _ndc_planes[3];
					b = source[0];
					bdot = (b.x * plane.x) + (b.w * plane.w);
					for (i in 1...(inCount + 1))
					{
						a = source [i % inCount];
						adot = (a.x * plane.x) + (a.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
							dest [outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clipped_vertices2;
				}
				//new Vector3 (0.0, 1.0, 0.0, - 1.0 ) bottom
				if ((clipcount & 16) == 16)
				{
					inCount = outCount;
					outCount = 0;
					dest = _clipped_vertices1;
					plane = _ndc_planes [4];
					b = source [0];
					bdot = (b.y * plane.y) + (b.w * plane.w);
					for (i in 1...(inCount + 1))
					{
						a = source [i % inCount];
						adot = (a.y * plane.y) + (a.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
							dest [outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clipped_vertices1;
				}
				//new Vector3 (0.0, - 1.0, 0.0, - 1.0 ) top
				if ((clipcount & 32) == 32)
				{
					inCount = outCount;
					outCount = 0;
					dest = _clipped_vertices0;
					plane = _ndc_planes[5];
					b = source[0];
					bdot = (b.y * plane.y) + (b.w * plane.w);
					for (i in 1...(inCount + 1))
					{
						a = source [i % inCount];
						adot = (a.y * plane.y) + (a.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
							dest [outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexs [tCount++];
								dest [outCount++] = out;
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								out.interpolate(a, b, t);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clipped_vertices0;
				}
				
				// put back into screen space.
				vCount2 = vCount;
				for (g in 0...outCount)
				{
					tv0 = source [g];
					var tmp:Float = 1 / tv0.w ;
					tv0.x = (tv0.x * csm00) * tmp + csm30;
					tv0.y = (tv0.y * csm11) * tmp + csm31;
					tv0.z = tmp;
					_clipped_vertices [vCount++] = tv0;
				}
				// re-tesselate ( triangle-fan, 0-1-2,0-2-3.. )
				for (g in 0...(outCount - 2))
				{
					_clipped_indices[iCount++] = vCount2;
					_clipped_indices[iCount++] = (vCount2 + g + 1);
					_clipped_indices[iCount++] = (vCount2 + g + 2);
				}
			}
			primitivesDrawn += Std.int(iCount / 3);
			curRender.drawIndexedTriangleList (_clipped_vertices, vCount, _clipped_indices, iCount);
		}
		public  function drawMeshBuffer(mesh:MeshBuffer):Void
		{
			drawIndexedTriangleList(mesh.vertices,mesh.vertices.length,mesh.indices,mesh.indices.length);
		}
		/**
		*用来渲染由线段组成的物体 ,此类物体不需要进行光照，贴图，和贴图坐标计算等
		* @vertices  Array 点的集合
		* @vertexCount int vertices的长度
		* @indexList 点与点之间的顺序(2点组成一条直线)
		* @indexCount int indexList.length
		*/
		//Todo 这个方法有误,删除,以后添加
		override public  function drawIndexedLineList (vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
		{
		}
		public function getDriverType () : String
		{
			return VideoType.PIXEL;
		}
		public function createScreenShot () : BitmapData
		{
			return target.bitmapData.clone ();
		}
		public function setPerspectiveCorrectDistance (?distance : Float = 400.) : Void
		{
			persDistance = (distance < 10) ? 10 : distance;
			for ( i in 0...TRType.COUNT)
			{
				var render : ITriangleRenderer = renderers [i];
				render.setPerspectiveCorrectDistance (distance);
			}
		}
		public function setMipMapDistance (?distance : Float = 500.) : Void
		{
			mipMapDistance = (distance < 10) ? 10 : distance;
			for ( i in 0...TRType.COUNT)
			{
				var render : ITriangleRenderer = renderers [i];
				render.setMipMapDistance (distance);
			}
		}
		public function setHeight(height:Int) : Void
		{
			for ( i in 0...TRType.COUNT)
			{
				var render : ITriangleRenderer = renderers [i];
				render.setHeight(height);
			}
		}
		public function setVector(tv : Vector<UInt>, bv : Vector<Float>) : Void
		{
			for ( i in 0...TRType.COUNT)
			{
				var render : ITriangleRenderer = renderers[i];
				render.setVector(tv,bv);
			}
		}
	}

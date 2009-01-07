package linda.video;

	import flash.Vector;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import haxe.Log;
	import linda.mesh.objects.RegularPolygon;
	import linda.scene.ShadowVolume;
	

	import linda.light.Light;
	import linda.material.Texture;
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
	import linda.video.pixel.TRTextureFlatNoZ;
	import linda.video.pixel.TRTextureFlatAlpha;
	import linda.video.pixel.TRTextureGouraud;
	import linda.video.pixel.TRTextureGouraudAlpha;
	import linda.video.pixel.TRWire;

	class VideoSoftware extends VideoNull,implements IVideoDriver
	{
		private var curRender : ITriangleRenderer;
		private var renderers : Vector<ITriangleRenderer>;
		private var lineRender: ILineRenderer;
		
		private var target : Bitmap;
		private var rect:Rectangle;

		private var targetVector : Vector<UInt>;
		private var bufferVector : Vector<Float>;
		

		private var material : Material;
		private var hasTexture:Bool;
		
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
		private var _scaleMatrix : Matrix4;
		
		private var _oppcam_pos : Vector3;
		private var _cam_pos : Vector3;
		
		private var _clipPlanes          : Vector<Vector4>;

		private var _transformedVertexes : Vector<Vertex4D>;
		private var _unclippedVertices   : Vector<Vertex4D>;
		private var _clippedVertices     : Vector<Vertex4D>;
		private var _clippedIndices      : Vector<Int>;
		private var _clippedVertices0    : Vector<Vertex4D>;
		private var _clippedVertices1    : Vector<Vertex4D>;
		private var _clippedVertices2    : Vector<Vertex4D>;
		private var _clippedVertices3    : Vector<Vertex4D>;
		private var _clippedVertices4    : Vector<Vertex4D>;
		
		
		//线段裁剪时不会多出点,也不会少
		private var _transformedLineVertexes :Vector<Vertex4D>;// 不需要光照等的线段渲染点
		private var _clippedLineVertices     :Vector<Vertex4D>;
		private var _clippedLineIndices      :Vector<Int>;
		private var _tmpVertex      :Vertex4D;
		
		//lighting
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
			
			_tmpVertex = new Vertex4D();
		}
		private function init (size:Dimension2D) : Void
		{
			target = new Bitmap ();
			renderTarget.addChild(target);
			
			_scaleMatrix = new Matrix4 ();

			//render
			renderers = new Vector<ITriangleRenderer>(TRType.COUNT, true);
			renderers [TRType.WIRE]                  = new TRWire ();
			renderers [TRType.FLAT]                  = new TRFlat ();
			renderers [TRType.GOURAUD]               = new TRGouraud ();
			renderers [TRType.TEXTURE_FLAT]          = new TRTextureFlat ();
			renderers [TRType.TEXTURE_GOURAUD]       = new TRTextureGouraud();
			renderers [TRType.FLAT_ALPHA]            = new TRFlatAlpha ();
			renderers [TRType.GOURAUD_ALPHA]         = new TRGouraudAlpha ();
			renderers [TRType.TEXTURE_FLAT_ALPHA]    = new TRTextureFlatAlpha ();
			renderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha ();
			renderers [TRType.TEXTURE_FLAT_NoZ] = new TRTextureFlatNoZ ();
			
			lineRender = new LineRenderer();
			
			targetVector=new Vector<UInt>();
			bufferVector=new Vector<Float>();
			
			setVector(targetVector,bufferVector);
			

			//预存一些点
			_transformedVertexes = new Vector<Vertex4D>(2000);
			for ( i in 0...2000)
			{
				_transformedVertexes[i] = new Vertex4D();
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
			
			/*
			generic plane clipping in homogenous coordinates
			special case ndc frustum <-w,w>,<-w,w>,<-w,w>
			can be rewritten with compares e.q near plane, a.z < -a.w and b.z < -b.w
			*/
			_clipPlanes = new Vector<Vector4>(6,true);
			_clipPlanes[0]=new Vector4(0.0 , 0.0 , 1.0 , -1.0 ); // far
			_clipPlanes[1]=new Vector4(0.0 , 0.0 , -1.0, -1.0 ); // near
			_clipPlanes[2]=new Vector4(1.0 , 0.0 , 0.0 , -1.0 ); // left
			_clipPlanes[3]=new Vector4(-1.0, 0.0 , 0.0 , -1.0 ); // right
			_clipPlanes[4]=new Vector4(0.0 , 1.0 , 0.0 , -1.0 ); // bottom
			_clipPlanes[5]=new Vector4(0.0 , -1.0, 0.0 , -1.0 ); // top

			// arrays for storing clipped vertices & indices
			_clippedIndices    = new Vector<Int>();
			_clippedVertices   = new Vector<Vertex4D>();
			_unclippedVertices = new Vector<Vertex4D>();
			_clippedVertices0  = new Vector<Vertex4D>();
			_clippedVertices1  = new Vector<Vertex4D>();
			_clippedVertices2  = new Vector<Vertex4D>();
			_clippedVertices3  = new Vector<Vertex4D>();
			_clippedVertices4  = new Vector<Vertex4D>();
			
			//arrays for storing clipped line vertices & indices
			_transformedLineVertexes = new Vector<Vertex4D>();
            for ( i in 0...500)
			{
				_transformedLineVertexes[i] = new Vertex4D();
			}
			_clippedLineVertices = new Vector<Vertex4D>();
			_clippedLineIndices      = new Vector<Int>();
			
			setScreenSize(size);
		}
		private inline function reset():Void
		{
			//Todo 不知道有没有更好的方法了:)
			targetVector.length = 0;
			bufferVector.length = 0;
			var len:Int = screenSize.width * screenSize.height;
			targetVector.length = len;
			bufferVector.length = len;
		}
		private inline function getTRIndex () : Int
		{
			if (material.wireframe)
			{
				return TRType.WIRE;
			}else
			{
				var gouraudShading : Bool = material.gouraudShading;
				var lighting:Bool = material.lighting;
			
				if (material.transparenting)
				{
					if (hasTexture)
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
					if (hasTexture)
					{
						if(lighting)
						{
							return TRType.TEXTURE_GOURAUD;
						}else
						{
							if (material.zBuffer)
							{
								return TRType.TEXTURE_FLAT;
							}else
							{
								return TRType.TEXTURE_FLAT_NoZ;
							}
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
		}

		public function beginScene ():Void
		{
			trianglesDrawn = 0;
			reset();
		}
		public function endScene():Void
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
			_current.multiplyBy(_world);

			_world_inv.copy(_world);
			_world_inv.inverse4x3();

			_oppcam_pos.copy(_cam_pos);
			_world_inv.transformVector(_oppcam_pos);
		}

		public function setTransformView (mat : Matrix4) : Void
		{
			_view = mat;
			_view_project.copy(_projection);
			_view_project.multiplyBy(_view);
		}

		override public function setMaterial (mat : Material) : Void
		{
			material = mat;
			hasTexture = (material.texture != null);
			curRender = renderers[getTRIndex()];
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
			
			_scaleMatrix.buildNDCToDCMatrix(screenSize,1);
			
			var len:Int=screenSize.width*screenSize.height;
			targetVector.length=len;
			bufferVector.length=len;
			
			setWidth(screenSize.width);
		}
		public override function setRenderTarget (target : Sprite) : Void
		{
			if ( target==null) return;
			if (renderTarget!=null) renderTarget.removeChild (target);
			renderTarget = target;
			renderTarget.addChild (target);
		}
		public function drawIndexedTriangleList (vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, triangleCount : Int) : Void
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
			var adot   : Float;
			var bdot   : Float;
			var t      : Float;
			
			//lighting
			var light : Light ;
			var pos   : Vector3 ;
			var dir   : Vector3 ;
			var lightLen:Int=getLightCount();

			var len : Int = triangleCount * 2;
			var _transformLen : Int = _transformedVertexes.length;
			if (_transformLen < len)
			{
				for (i in _transformLen...len)
				{
					_transformedVertexes[i] = new Vertex4D ();
				}
			}

			tCount = 0;
			iCount = 0;
			vCount = 0;
			
			//material var
			var lighting        : Bool = material.lighting;
			var backfaceCulling : Bool = material.backfaceCulling;
			var frontfaceCulling:Bool = material.frontfaceCulling;
			var gouraudShading  : Bool = material.gouraudShading;
			if(lighting)
			{
			    // transfrom lights into object's world space
			    for (i in 0...lightLen)
			    {
				    dir   =  _lightDirs[i];
				    pos   =  _lightsPos[i];
				    light =  lights[i];
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
			var csm00 : Float = _scaleMatrix.m00;
			var csm30 : Float = _scaleMatrix.m30;
			var csm11 : Float = _scaleMatrix.m11;
			var csm31 : Float = _scaleMatrix.m31;
			
			var memi : Color = material.emissiveColor;
			var mamb : Color = material.ambientColor;
			var mdif : Color = material.diffuseColor;
			var globalR : Int = (ambientColor.r * mamb.r >> 8) + memi.r;
			var globalG : Int = (ambientColor.g * mamb.g >> 8) + memi.g;
			var globalB : Int = (ambientColor.b * mamb.b >> 8) + memi.b;

			var ii:Int = 0;
			while( ii < triangleCount )
			{
				v0 = vertices [indexList[ii]];
				v1 = vertices [indexList[ii + 1]];
				v2 = vertices [indexList[ii + 2]];
				ii += 3;
				
				if (backfaceCulling || frontfaceCulling)
				{
					var t:Float=((v1.y - v0.y) * (v2.z - v0.z) - (v1.z - v0.z) * (v2.y - v0.y)) * (_oppcam_pos.x - v0.x) +
					            ((v1.z - v0.z) * (v2.x - v0.x) - (v1.x - v0.x) * (v2.z - v0.z)) * (_oppcam_pos.y - v0.y) +
					            ((v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x)) * (_oppcam_pos.z - v0.z);
					if ((backfaceCulling && t<=0) || (frontfaceCulling && t > 0))
					{
						continue;
					}
				}
				
				tv0 = _transformedVertexes [tCount++];
				tv1 = _transformedVertexes [tCount++];
				tv2 = _transformedVertexes [tCount++];
				
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
					plane = _clipPlanes[p];
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
							if (((tv2.x * plane.x) + (tv2.y * plane.y) + (tv2.z * plane.z) + (tv2.w * plane.w)) >= 0.0)
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
				
				//lighting 在物体自身坐标计算
				if (lighting)
				{
					//初始化总体反射光照颜色
					var dif_r_sum0 : Float = 0.;
					var dif_g_sum0 : Float = 0.;
					var dif_b_sum0 : Float = 0.;
					
					var diffuse : Color;
					var dist : Float;
					var dist2 : Float;
					var dpsl : Float;
					var dp : Float;
					var radius : Float;
					var k : Float;
                    
					if ( ! gouraudShading) //flat Light
					{
						for (j in 0...lightLen)
						{
							light = lights [j];
							diffuse = light.diffuseColor;
								
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
							var nlenSquared:Float = n.getLengthSquared();
							if (light.type == 0) //DIRECTIONAL
							{
								dir  = _lightDirs [j];
								dp = (n.x * dir.x + n.y * dir.y + n.z * dir.z) * MathUtil.invSqrt(nlenSquared);
								if (dp > 0)
								{
									dif_r_sum0 += diffuse.r * dp;
									dif_g_sum0 += diffuse.g * dp;
									dif_b_sum0 += diffuse.b * dp;
								}
							} else if (light.type == 1) //POINT
							{
								pos  = _lightsPos[j];
								l.x = pos.x - v0.x;
								l.y = pos.y - v0.y;
								l.z = pos.z - v0.z;
								dp = (n.x * l.x + n.y * l.y + n.z * l.z);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<light.radius)
								{
									k = dp * MathUtil.invSqrt(nlenSquared)/((light.kc + light.kl * dist + light.kq * dist2) * dist);
									dif_r_sum0 += diffuse.r * k;
									dif_g_sum0 += diffuse.g * k;
									dif_b_sum0 += diffuse.b * k;
								}
							} //SPOT
							{
								pos  = _lightsPos [j];
								dir  = _lightDirs [j];
								l.x = pos.x - v0.x;
								l.y = pos.y - v0.y;
								l.z = pos.z - v0.z;
								dp = n.dotProduct(dir);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<light.radius)
								{
									dpsl = l.dotProduct(dir)/ dist;
									if (dpsl > 0 )
									{
										k = dp * MathUtil.powInt(dpsl, light.powerFactor) * MathUtil.invSqrt(nlenSquared)/(light.kc + light.kl * dist + light.kq * dist2);
										dif_r_sum0 += diffuse.r * k;
										dif_g_sum0 += diffuse.g * k;
										dif_b_sum0 += diffuse.b * k;
									}
								}
							}
						}
						tv0.r = globalR + (Std.int(dif_r_sum0 * mdif.r) >> 8);
						tv0.g = globalG + (Std.int(dif_g_sum0 * mdif.g) >> 8);
						tv0.b = globalB + (Std.int(dif_b_sum0 * mdif.b) >> 8);
						tv1.r = tv0.r;
						tv1.g = tv0.g;
						tv1.b = tv0.b;
						tv2.r = tv0.r;
						tv2.g = tv0.g;
						tv2.b = tv0.b;
					} else
					{
						var dif_r_sum1 : Float = 0.;
						var dif_g_sum1 : Float = 0.;
						var dif_b_sum1 : Float = 0.;
						var dif_r_sum2 : Float = 0.;
						var dif_g_sum2 : Float = 0.;
						var dif_b_sum2 : Float = 0.;
							
						for (j in 0...lightLen)
						{
							light = lights [j];
							diffuse = light.diffuseColor;
							
							radius = light.radius;
							if (light.type == 0) //DIRECTIONAL
							{
								dir = _lightDirs [j];
								//tv0
								dp = (v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
								if (dp > 0)
								{
										dif_r_sum0 += diffuse.r * dp;
										dif_g_sum0 += diffuse.g * dp;
										dif_b_sum0 += diffuse.b * dp;
								}
								//tv1
								dp = (v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
								if (dp > 0)
								{
									dif_r_sum1 += diffuse.r * dp;
									dif_g_sum1 += diffuse.g * dp;
									dif_b_sum1 += diffuse.b * dp;
								}
								//tv2
								dp = (v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
								if (dp > 0)
								{
									dif_r_sum2 += diffuse.r * dp;
									dif_g_sum2 += diffuse.g * dp;
									dif_b_sum2 += diffuse.b * dp;
								}
							} 
							else if (light.type == 1) //POINT
							{
								var kc : Float = light.kc;
								var kl : Float = light.kl;
								var kq : Float = light.kq;
								pos = _lightsPos [j];
									
									
								//              I0point * Clpoint
								//  I(d)point = ___________________
								//              kc +  kl*d + kq*d2
								//
								//  Where d = |p - s|
									
									
									
								l.x = pos.x - v0.x;
								l.y = pos.y - v0.y;
								l.z = pos.z - v0.z;
								//tv0
								dp = (v0.nx * l.x + v0.ny * l.y + v0.nz * l.z);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<radius)
								{
									k = dp / (dist*(kc + kl * dist + kq * dist2));
									dif_r_sum0 += diffuse.r * k;
									dif_g_sum0 += diffuse.g * k;
									dif_b_sum0 += diffuse.b * k;
								}
								//tv1
								l.x = pos.x - v1.x;
								l.y = pos.y - v1.y;
								l.z = pos.z - v1.z;
								dp = (v1.nx * l.x + v1.ny * l.y + v1.nz * l.z);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<radius)
								{
									k = dp / (dist*(kc + kl * dist + kq * dist2));
									dif_r_sum1 += diffuse.r * k;
									dif_g_sum1 += diffuse.g * k;
									dif_b_sum1 += diffuse.b * k;
								}
								//tv2
								l.x = pos.x - v2.x;
								l.y = pos.y - v2.y;
								l.z = pos.z - v2.z;
								dp = (v2.nx * l.x + v2.ny * l.y + v2.nz * l.z);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<radius)
								{
									k = dp /(dist*(kc + kl * dist + kq * dist2));
									dif_r_sum2 += diffuse.r * k;
									dif_g_sum2 += diffuse.g * k;
									dif_b_sum2 += diffuse.b * k;
								}
							} //SPOT
							{
								var kc : Float = light.kc;
								var kl : Float = light.kl;
								var kq : Float = light.kq;
								var pf : Int = light.powerFactor;
								dir = _lightDirs [j];
								pos = _lightsPos [j];
									
									
									
								//         	     I0spotlight * Clspotlight * MAX( (l . s), 0)^pf
								// I(d)spotlight = __________________________________________
								//               		 kc + kl*d + kq*d2
								// Where d = |p - s|, and pf = power factor
									
									
								//tv0
								l.x = pos.x - v0.x;
								l.y = pos.y - v0.y;
								l.z = pos.z - v0.z;
								dp = (v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<radius)
								{
									dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
									if (dpsl > 0 )
									{
										k = dp * MathUtil.powInt(dpsl, pf) / (kc + kl * dist + kq * dist2);
										dif_r_sum0 += diffuse.r * k;
										dif_g_sum0 += diffuse.g * k;
										dif_b_sum0 += diffuse.b * k;
									}
								}
								//tv1
								l.x = pos.x - v1.x;
								l.y = pos.y - v1.y;
								l.z = pos.z - v1.z;
								dp = (v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<radius)
								{
									dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
									if (dpsl > 0 )
									{
										k = dp * MathUtil.powInt(dpsl, pf) / (kc + kl * dist + kq * dist2);
										dif_r_sum1 += diffuse.r * k;
										dif_g_sum1 += diffuse.g * k;
										dif_b_sum1 += diffuse.b * k;
									}
								}
								//tv2
								l.x = pos.x - v2.x;
								l.y = pos.y - v2.y;
								l.z = pos.z - v2.z;
								dp = (v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
								dist2 = l.getLengthSquared();
								dist = MathUtil.sqrt(dist2);
								if (dp > 0 && dist<radius)
								{
									dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
									if (dpsl > 0 )
									{
										k = dp * MathUtil.powInt(dpsl, pf) / (kc + kl * dist + kq * dist2);
										dif_r_sum2 += diffuse.r * k;
										dif_g_sum2 += diffuse.g * k;
										dif_b_sum2 += diffuse.b * k;
									}
								}
							}
						}
						tv0.r = globalR + (Std.int(dif_r_sum0 * mdif.r) >> 8);
						tv0.g = globalG + (Std.int(dif_g_sum0 * mdif.g) >> 8);
						tv0.b = globalB + (Std.int(dif_b_sum0 * mdif.b) >> 8);
						tv1.r = globalR + (Std.int(dif_r_sum1 * mdif.r) >> 8);
						tv1.g = globalG + (Std.int(dif_g_sum1 * mdif.g) >> 8);
						tv1.b = globalB + (Std.int(dif_b_sum1 * mdif.b) >> 8);
						tv2.r = globalR + (Std.int(dif_r_sum2 * mdif.r) >> 8);
						tv2.g = globalG + (Std.int(dif_g_sum2 * mdif.g) >> 8);
						tv2.b = globalB + (Std.int(dif_b_sum2 * mdif.b) >> 8);
					}
				} else //no lighting
				{
					tv0.r = v0.r+memi.r; tv0.g = v0.g+memi.g; tv0.b = v0.b+memi.b;
					tv1.r = v1.r+memi.r; tv1.g = v1.g+memi.g; tv1.b = v1.b+memi.b;
					tv2.r = v2.r+memi.r; tv2.g = v2.g+memi.g; tv2.b = v2.b+memi.b;
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
					tv0.x = tv0.x * csm00 * tmp + csm30;
					tv0.y = tv0.y * csm11 * tmp + csm31;
					tv0.z = tmp;
					//tv1
					tmp = 1 / tv1.w ;
					tv1.x = tv1.x * csm00 * tmp + csm30;
					tv1.y = tv1.y * csm11 * tmp + csm31;
					tv1.z = tmp;
					//tv2
					tmp = 1 / tv2.w ;
					tv2.x = tv2.x * csm00 * tmp + csm30;
					tv2.y = tv2.y * csm11 * tmp + csm31;
					tv2.z = tmp;
					
					// add to _clippedIndices
					_clippedIndices  [iCount++] = vCount;
					_clippedVertices [vCount++] = tv0;
					
					_clippedIndices  [iCount++] = vCount;
					_clippedVertices [vCount++] = tv1;
					
					_clippedIndices  [iCount++] = vCount;
					_clippedVertices [vCount++] = tv2;
					
					continue;
				}

				// put into list for clipping
				_unclippedVertices[0] = tv0;
				_unclippedVertices[1] = tv1;
				_unclippedVertices[2] = tv2;
				
				source = _unclippedVertices;
				outCount = 3;

				/********** clip in NDC Space to Frustum **********/
				//new Vector4 (0.0, 0.0, -1.0, - 1.0 ) near
				if ((clipcount & 2) == 2)
				{
					inCount = outCount;
					outCount = 0;
					plane = _clipPlanes[1];
					b = source[0];
					bdot = b.z * plane.z + b.w * plane.w;
					var i:Int = 1;
					while (i <= inCount)
					{
						a = source [i % inCount];
						i++;
						
						adot = a.z * plane.z + a.w * plane.w;
						// current point inside
						if (adot <= 0.0 )
						{
							// last point outside
							if (bdot > 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices4 [outCount++] = out;
								t = bdot / ((b.z - a.z) * plane.z + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
							// add a to out
							_clippedVertices4[outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices4 [outCount ++] = out;
								t = bdot / ((b.z - a.z) * plane.z + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
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
					source = _clippedVertices4;
				}

				//new Vector4 (1.0, 0.0, 0.0, - 1.0 )  left
				if ((clipcount & 4) == 4)
				{
					inCount = outCount;
					outCount = 0;
					plane = _clipPlanes [2];
					b = source [0];
					bdot = b.x * plane.x + b.w * plane.w;
					var i:Int = 1;
					while (i <= inCount)
					{
						a = source [i % inCount];
						i++;
						adot = a.x * plane.x + a.w * plane.w;
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices3 [outCount++] = out;
								t = bdot / ((b.x - a.x) * plane.x + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
							// add a to out
							_clippedVertices3 [outCount ++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices3 [outCount++] = out;
								t = bdot / ((b.x - a.x) * plane.x + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clippedVertices3;
				}
				
				//new Vector4 ( - 1.0, 0.0, 0.0, - 1.0 )  right
				if ((clipcount & 8) == 8)
				{
					inCount = outCount;
					outCount = 0;
					plane = _clipPlanes[3];
					b = source[0];
					bdot = b.x * plane.x + b.w * plane.w;
					var i:Int = 1;
					while (i <= inCount)
					{
						a = source [i % inCount];
						i++;
						adot = a.x * plane.x + a.w * plane.w;
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices2 [outCount++] = out;
								t = bdot / ((b.x - a.x) * plane.x + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
							_clippedVertices2 [outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices2 [outCount++] = out;
								t = bdot / ((b.x - a.x) * plane.x + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clippedVertices2;
				}
				//new Vector4 (0.0, 1.0, 0.0, - 1.0 ) bottom
				if ((clipcount & 16) == 16)
				{
					inCount = outCount;
					outCount = 0;
					plane = _clipPlanes [4];
					b = source [0];
					bdot = b.y * plane.y + b.w * plane.w;
					var i:Int = 1;
					while (i <= inCount)
					{
						a = source [i % inCount];
						i++;
						adot = a.y * plane.y + a.w * plane.w;
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices1 [outCount++] = out;
								t = bdot / ((b.y - a.y) * plane.y + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
							_clippedVertices1 [outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices1 [outCount++] = out;
								t = bdot / ((b.y - a.y) * plane.y + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clippedVertices1;
				}
				//new Vector4 (0.0, - 1.0, 0.0, - 1.0 ) top
				if ((clipcount & 32) == 32)
				{
					inCount = outCount;
					outCount = 0;
					plane = _clipPlanes[5];
					b = source[0];
					bdot = b.y * plane.y + b.w * plane.w;
					var i:Int = 1;
					while (i <= inCount)
					{
						a = source [i % inCount];
						i++;
						adot = a.y * plane.y + a.w * plane.w;
						if (adot <= 0.0 )
						{
							if (bdot > 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices0 [outCount++] = out;
								t = bdot / ((b.y - a.y) * plane.y + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
							_clippedVertices0 [outCount++] = a;
						} 
						else
						{
							if (bdot <= 0.0 )
							{
								out = _transformedVertexes [tCount++];
								_clippedVertices0 [outCount++] = out;
								t = bdot / ((b.y - a.y) * plane.y + (b.w - a.w) * plane.w);
								out.interpolate(a, b, t,hasTexture);
							}
						}
						b = a;
						bdot = adot;
					}
					if (outCount < 3)
					{
						continue;
					}
					source = _clippedVertices0;
				}
				
				// put back into screen space.
				vCount2 = vCount;
				for (g in 0...outCount)
				{
					tv0 = source [g];
					var tmp:Float = 1 / tv0.w ;
					tv0.x = tv0.x * csm00 * tmp + csm30;
					tv0.y = tv0.y * csm11 * tmp + csm31;
					tv0.z = tmp;
					_clippedVertices [vCount++] = tv0;
				}
				// re-tesselate ( triangle-fan, 0-1-2,0-2-3.. )
				for (g in 0...(outCount - 2))
				{
					_clippedIndices[iCount++] = vCount2;
					_clippedIndices[iCount++] = vCount2 + g + 1;
					_clippedIndices[iCount++] = vCount2 + g + 2;
				}
			}
			trianglesDrawn += Std.int(iCount / 3);
			curRender.drawIndexedTriangleList (_clippedVertices, vCount, _clippedIndices, iCount);
		}
		public function drawMeshBuffer(mesh:MeshBuffer):Void
		{
			drawIndexedTriangleList(mesh.vertices,mesh.vertices.length,mesh.indices,mesh.indices.length);
		}
		/**
		* 用来渲染由线段组成的物体 ,此类物体不需要进行光照和贴图计算等
		* @vertices  Array 点的集合
		* @vertexCount int vertices的长度
		* @indexList 点与点之间的顺序(2点组成一条直线)
		* @indexCount int indexList.length
		*/
		override public function drawIndexedLineList (vertices : Vector<Vertex>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
		{
			var v0      : Vertex;
			var v1      : Vertex;
			var tv0     : Vertex4D;
			var tv1     : Vertex4D;
			var tCount  : Int;
			var iCount  : Int; 
			var vCount  : Int;

			//clipping
			var a      : Vertex4D;
			var b      : Vertex4D;
			var plane  : Vector4;
			var adot   : Float;
			var bdot   : Float;
			var t      : Float;

			var _transformLen : Int = _transformedLineVertexes.length;
			if (_transformLen < indexCount)
			{
				for (i in _transformLen...indexCount)
				{
					_transformedLineVertexes[i] = new Vertex4D();
				}
			}

			tCount = 0;
			iCount = 0;
			vCount = 0;
			
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
			var csm00 : Float = _scaleMatrix.m00;
			var csm30 : Float = _scaleMatrix.m30;
			var csm11 : Float = _scaleMatrix.m11;
			var csm31 : Float = _scaleMatrix.m31;

			var ii:Int = 0;
			while( ii < indexCount )
			{
				v0 = vertices[indexList[ii]];
				v1 = vertices[indexList[ii + 1]];
				
				ii += 2;

				tv0 = _transformedLineVertexes [tCount++];
				tv1 = _transformedLineVertexes [tCount++];

				tv0.x = m00 * v0.x + m10 * v0.y + m20 * v0.z + m30;
				tv0.y = m01 * v0.x + m11 * v0.y + m21 * v0.z + m31;
				tv0.z = m02 * v0.x + m12 * v0.y + m22 * v0.z + m32;
				tv0.w = m03 * v0.x + m13 * v0.y + m23 * v0.z + m33;

				tv1.x = m00 * v1.x + m10 * v1.y + m20 * v1.z + m30;
				tv1.y = m01 * v1.x + m11 * v1.y + m21 * v1.z + m31;
				tv1.z = m02 * v1.x + m12 * v1.y + m22 * v1.z + m32;
				tv1.w = m03 * v1.x + m13 * v1.y + m23 * v1.z + m33;

                
				var inside : Bool = true;
				var clipcount : Int = 0;
				for (p in 0...6)
				{
					plane = _clipPlanes[p];
					if (((tv0.x * plane.x) + (tv0.y * plane.y) + (tv0.z * plane.z) + (tv0.w * plane.w)) > 0.0)
					{
						if (((tv1.x * plane.x) + (tv1.y * plane.y) + (tv1.z * plane.z) + (tv1.w * plane.w)) > 0.0)
						{
							inside = false;
							break;
						}
						clipcount += (1 << p);
					} 
					else
					{
						if (((tv1.x * plane.x) + (tv1.y * plane.y) + (tv1.z * plane.z) + (tv1.w * plane.w)) >= 0.0)
						{
							clipcount += (1 << p);
						}
					}
				}
				
				if ( ! inside)
				{
					tCount -= 2;
					continue;
				}
				
				tv0.r = v0.r;
				tv0.g = v0.g;
				tv0.b = v0.b;
				
				tv1.r = v1.r;
				tv1.g = v1.g;
				tv1.b = v1.b;
                
				
				if (clipcount != 0) //clipping required
				{
					// put into list for clipping
					a = tv0;
					b = tv1;
					
					// clip in NDC Space to Frustum
					//near
					if ((clipcount & 2) == 2)
					{
						plane = _clipPlanes[1];
						adot = (a.z * plane.z) + (a.w * plane.w);
						bdot = (b.z * plane.z) + (b.w * plane.w);
						// current point inside
						if (adot <= 0.0 )
						{
							if (bdot > 0)
							{
								t = bdot / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								b.copy(_tmpVertex);
							}
						} 
						else
						{
							if (bdot <= 0)
							{
								t = bdot / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								a.copy(_tmpVertex);
							}
						}
					}

					//new Vector4 (1.0, 0.0, 0.0, - 1.0 )  left
					if ((clipcount & 4) == 4)
					{
						plane = _clipPlanes[2];
						adot = (a.x * plane.x) + (a.w * plane.w);
						bdot = (b.x * plane.x) + (b.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0)
							{
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								b.copy(_tmpVertex);
							}
						} 
						else
						{
							if (bdot <= 0)
							{
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								a.copy(_tmpVertex);
							}
						}
					}
					//new Vector4 ( - 1.0, 0.0, 0.0, - 1.0 )  right
					if ((clipcount & 8) == 8)
					{
						plane = _clipPlanes[3];
						bdot = (b.x * plane.x) + (b.w * plane.w);
						adot = (a.x * plane.x) + (a.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0)
							{
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								b.copy(_tmpVertex);
							}
						} 
						else
						{
							if (bdot <= 0)
							{
								t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								a.copy(_tmpVertex);
							}
						}
					}
					//new Vector4 (0.0, 1.0, 0.0, - 1.0 ) bottom
					if ((clipcount & 16) == 16)
					{
						plane = _clipPlanes[4];
						bdot = (b.y * plane.y) + (b.w * plane.w);
						adot = (a.y * plane.y) + (a.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0)
							{
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								b.copy(_tmpVertex);
							}
						} 
						else
						{
							if (bdot <= 0)
							{
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								a.copy(_tmpVertex);
							}
						}
					}
					//new Vector4 (0.0, - 1.0, 0.0, - 1.0 ) top
					if ((clipcount & 32) == 32)
					{
						plane = _clipPlanes[5];
						bdot = (b.y * plane.y) + (b.w * plane.w);
						adot = (a.y * plane.y) + (a.w * plane.w);
						if (adot <= 0.0 )
						{
							if (bdot > 0)
							{
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								b.copy(_tmpVertex);
							}
						} 
						else
						{
							if (bdot <= 0)
							{
								t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
								_tmpVertex.interpolate(a, b, t,false);
								a.copy(_tmpVertex);
							}
						}
					}
				}
                
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

				// add to _clippedLineIndices
				_clippedLineIndices [iCount++]  = vCount;
				_clippedLineVertices[vCount++]  = tv0;
				_clippedLineIndices [iCount++]  = vCount;
				_clippedLineVertices[vCount++]  = tv1;
			}
			lineRender.drawIndexedLineList (_clippedLineVertices, vCount, _clippedLineIndices, iCount);
		}
		/**
		 *  Draws a shadow volume into the stencil buffer. To draw a stencil shadow, do
		 *  this: First, draw all geometry. Then use this method, to draw the shadow
		 *  volume. Then, use drawStencilShadow() to visualize the shadow.
		 */		
        public function drawStencilShadowVolume(shadowVolume:ShadowVolume,zfail:Bool):Void
		{
			
		}
		public function drawStencilShadow(clearStencilBuffer:Bool=true):Void 
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
		public function setPerspectiveCorrectDistance (distance : Float = 400.) : Void
		{
			persDistance = (distance < 10) ? 10 : distance;
			var count:Int = TRType.COUNT;
			for ( i in 0...count)
			{
				renderers[i].setPerspectiveCorrectDistance (distance);
			}
		}
		public function setMipMapDistance (distance : Float = 500.) : Void
		{
			mipMapDistance = (distance < 10) ? 10 : distance;
			var count:Int = TRType.COUNT;
			for ( i in 0...count)
			{
				renderers[i].setMipMapDistance (distance);
			}
		}
		public function setWidth(width:Int) : Void
		{
			var count:Int = TRType.COUNT;
			for ( i in 0...count)
			{
				renderers[i].setWidth(width);
			}
			lineRender.setWidth(width);
		}
		public function setVector(tv : Vector<UInt>, bv : Vector<Float>) : Void
		{
			var count:Int = TRType.COUNT;
			for ( i in 0...count)
			{
				renderers[i].setVector(tv,bv);
			}
			lineRender.setVector(tv,bv);
		}
		public function setDistance(distance:Float):Void 
		{
			if (curRender != null) curRender.setDistance(distance);
		}
	}

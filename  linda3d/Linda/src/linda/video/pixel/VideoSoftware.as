package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.*;
	
	import linda.light.Light;
	import linda.material.ITexture;
	import linda.material.Material;
	import linda.math.*;
	import linda.mesh.IMeshBuffer;
	import linda.video.ITriangleRenderer;
	import linda.video.IVideoDriver;
	import linda.video.TRType;
	import linda.video.VideoNull;
	import linda.video.VideoType;

	public class VideoSoftware extends VideoNull implements IVideoDriver
	{
		//render vars
		protected var currentTriangleRenderer : ITriangleRenderer;
		protected var triangleRenderers : Vector.<ITriangleRenderer>;
		protected var targetBitmap : Bitmap;
		protected var buffer : BitmapData;
		protected var texture : ITexture;
		protected var material : Material;
		//matrix vars
		protected var _view : Matrix4;
		protected var _world : Matrix4;
		protected var _clip_scale : Matrix4;
		//ClipScale from NDC to DC Space
		protected var _projection : Matrix4;
		protected var _current : Matrix4 ;
		protected var _view_project : Matrix4;
		protected var _world_inv : Matrix4;
		protected var _invCamPos : Vector3D;
		protected var _camPos : Vector3D;
		protected var _ndc_planes : Vector.<Vector3D>;

		protected var _transformedPoints : Vector.<Vertex4D>;
		protected var _unclipped_vertices : Vector.<Vertex4D>;
		protected var _clipped_vertices : Vector.<Vertex4D>;
		protected var _clipped_indices : Vector.<int>;
		protected var _clipped_vertices0 : Vector.<Vertex4D>;
		protected var _lightsDir : Vector.<Vector3D>;
		protected var _lightsPos : Vector.<Vector3D>;
		//line points
		protected var _transformedLinePoints :Vector.<Vertex4D>;
		protected var _clipped_line_vertices : Vector.<Vertex4D>;
		protected var _clipped_line_indices : Vector.<int>;
		public function VideoSoftware (size : Dimension2D)
		{
			super ();
			
			init (size);
		}
		private function init (size:Dimension2D) : void
		{
			if (size == null)
			{
				size = new Dimension2D (400, 400);
			}
			screenSize = size;
			//render target
			targetBitmap = new Bitmap ();
			targetBitmap.smoothing = false;
			targetBitmap.cacheAsBitmap = false;
			targetBitmap.bitmapData = new BitmapData (screenSize.width, screenSize.height, false, 0x0);
			renderTarget.addChild (targetBitmap);
			buffer =new BitmapData (screenSize.width, screenSize.height, false, 0xffffff);
			_clip_scale = new Matrix4 ();
			_clip_scale.buildNDCToDCMatrix(screenSize,1);
			//render
			triangleRenderers = new Vector.<ITriangleRenderer> (TRType.COUNT);
			triangleRenderers [TRType.WIRE] = new TRWire ();
			triangleRenderers [TRType.FLAT] = new TRFlat ();
			triangleRenderers [TRType.GOURAUD] = new TRGouraud ();
			triangleRenderers [TRType.TEXTURE_FLAT] = new TRTextureFlat ();
			triangleRenderers [TRType.TEXTURE_GOURAUD] = new TRTextureGouraud ();
			triangleRenderers [TRType.FLAT_ALPHA] = new TRFlatAlpha ();
			triangleRenderers [TRType.GOURAUD_ALPHA] = new TRGouraudAlpha ();
			triangleRenderers [TRType.TEXTURE_FLAT_ALPHA] = new TRTextureFlatAlpha ();
			triangleRenderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha ();
			//预存一些点
			_transformedPoints = new Vector.<Vertex4D>();
			for (var i : int = 0; i < 2000; i ++)
			{
				_transformedPoints [i] = new Vertex4D ();
			}
			//matrix4
			_current = new Matrix4 ();
			_view = new Matrix4 ();
			_projection = new Matrix4 ();
			_view_project = new Matrix4 ();
			_world_inv = new Matrix4 ();
			_lightsDir = new Vector.<Vector3D> ();
			_lightsPos = new Vector.<Vector3D> ();
			for (i = 0; i < getMaximalDynamicLightAmount (); i ++)
			{
				_lightsDir.push (new Vector3D ());
				_lightsPos.push (new Vector3D ());
			}
			_invCamPos = new Vector3D ();
			_camPos = new Vector3D ();
			/*
			generic plane clipping in homogenous coordinates
			special case ndc frustum <-w,w>,<-w,w>,<-w,w>
			can be rewritten with compares e.q near plane, a.z < -a.w and b.z < -b.w
			*/
			_ndc_planes = new Vector.<Vector3D>();
			
			_ndc_planes.push(new Vector3D (0.0, 0.0, - 1.0, - 1.0 ) , // near
			               new Vector3D (0.0, 0.0, 1.0, - 1.0 ) , // far
			               new Vector3D (1.0, 0.0, 0.0, - 1.0 ) , // left
			               new Vector3D ( - 1.0, 0.0, 0.0, - 1.0 ) , // right
			               new Vector3D (0.0, 1.0, 0.0, - 1.0 ) , // bottom
			               new Vector3D (0.0, - 1.0, 0.0, - 1.0 ) //top
			               );
			// arrays for storing clipped vertices & indices
			_clipped_indices = new Vector.<int> ();
			_clipped_vertices = new Vector.<Vertex4D> ();
			_clipped_vertices0 = new Vector.<Vertex4D> ();
			_unclipped_vertices = new Vector.<Vertex4D> ();
			//for drawIndexedLineList
			_transformedLinePoints = new Vector.<Vertex4D> ();
			for (i = 0; i < 100; i ++)
			{
				_transformedLinePoints [i] = new Vertex4D ();
			}
			_clipped_line_vertices = new Vector.<Vertex4D> ();
			_clipped_line_indices = new Vector.<int> ();
			material = new Material ();
		}
		private function getTRIndex () : int
		{
			if(material.wireframe) return TRType.WIRE;

			var gouraudShading : Boolean = material.gouraudShading;
			var lighting:Boolean = material.lighting;
			if (material.transparenting)
			{
					if (texture)
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
					if (texture)
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
		private function switchToTriangleRenderer (renderer : int) : void
		{
			currentTriangleRenderer = triangleRenderers [renderer];
			currentTriangleRenderer.setMaterial (material);
			currentTriangleRenderer.setRenderTarget (targetBitmap.bitmapData, buffer);
		}
		override public function beginScene (backBuffer : Boolean = true, zbuffer : Boolean = true , color : uint = 0x0) : Boolean
		{
			primitivesDrawn = 0;
			if (backBuffer) targetBitmap.bitmapData.fillRect (screenSize.toRect(), color);
			if (zbuffer) buffer.fillRect (screenSize.toRect(), 0xFFFFFF);
			targetBitmap.bitmapData.lock();
			buffer.lock();
			return true;
		}
		override public function endScene():Boolean
		{
			targetBitmap.bitmapData.unlock();
			buffer.unlock();
			return true;
		}
		override public function setTransformViewProjection (mat : Matrix4) : void
		{
			_view_project = mat;
		}
		public override function setTransformProjection (mat : Matrix4) : void
		{
			_projection = mat;
		}
		override public function setCameraPosition (ps : Vector3D) : void
		{
			if (!ps) return;
			_camPos.x=ps.x;
			_camPos.y=ps.y;
			_camPos.z=ps.z;
		}
		public override function setTransformWorld (mat : Matrix4) : void
		{
			_world = mat;
			/*
			_current.copy (_view_project);
			_current.multiplyE (_world);
			// transfrom camera into object's world space
			_world.getInverse (_world_inv);
			_world_inv.transformVector2(_camPos,_invCamPos);
			*/
			//_current.copy (_view_project);
			_current.m00 = _view_project.m00;
			_current.m01 = _view_project.m01;
			_current.m02 = _view_project.m02;
			_current.m03 = _view_project.m03;
			_current.m10 = _view_project.m10;
			_current.m11 = _view_project.m11;
			_current.m12 = _view_project.m12;
			_current.m13 = _view_project.m13;
			_current.m20 = _view_project.m20;
			_current.m21 = _view_project.m21;
			_current.m22 = _view_project.m22;
			_current.m23 = _view_project.m23;
			_current.m30 = _view_project.m30;
			_current.m31 = _view_project.m31;
			_current.m32 = _view_project.m32;
			_current.m33 = _view_project.m33;
			//_current.multiplyE (_world);
			var m00 : Number = _current.m00;
			var m01 : Number = _current.m01;
			var m02 : Number = _current.m02;
			var m03 : Number = _current.m03;
			var m10 : Number = _current.m10;
			var m11 : Number = _current.m11;
			var m12 : Number = _current.m12;
			var m13 : Number = _current.m13;
			var m20 : Number = _current.m20;
			var m21 : Number = _current.m21;
			var m22 : Number = _current.m22;
			var m23 : Number = _current.m23;
			var m30 : Number = _current.m30;
			var m31 : Number = _current.m31;
			var m32 : Number = _current.m32;
			var m33 : Number = _current.m33;
			_current.m00 = m00 * _world.m00 + m10 * _world.m01 + m20 * _world.m02 ;
			_current.m01 = m01 * _world.m00 + m11 * _world.m01 + m21 * _world.m02 ;
			_current.m02 = m02 * _world.m00 + m12 * _world.m01 + m22 * _world.m02 ;
			_current.m03 = m03 * _world.m00 + m13 * _world.m01 + m23 * _world.m02 ;
			_current.m10 = m00 * _world.m10 + m10 * _world.m11 + m20 * _world.m12 ;
			_current.m11 = m01 * _world.m10 + m11 * _world.m11 + m21 * _world.m12 ;
			_current.m12 = m02 * _world.m10 + m12 * _world.m11 + m22 * _world.m12 ;
			_current.m13 = m03 * _world.m10 + m13 * _world.m11 + m23 * _world.m12 ;
			_current.m20 = m00 * _world.m20 + m10 * _world.m21 + m20 * _world.m22 ;
			_current.m21 = m01 * _world.m20 + m11 * _world.m21 + m21 * _world.m22 ;
			_current.m22 = m02 * _world.m20 + m12 * _world.m21 + m22 * _world.m22 ;
			_current.m23 = m03 * _world.m20 + m13 * _world.m21 + m23 * _world.m22 ;
			_current.m30 = m00 * _world.m30 + m10 * _world.m31 + m20 * _world.m32 + m30 ;
			_current.m31 = m01 * _world.m30 + m11 * _world.m31 + m21 * _world.m32 + m31 ;
			_current.m32 = m02 * _world.m30 + m12 * _world.m31 + m22 * _world.m32 + m32 ;
			_current.m33 = m03 * _world.m30 + m13 * _world.m31 + m23 * _world.m32 + m33 ;
			//_world.getInverse (_world_inv);
			m00 = _world.m00;
			m01 = _world.m01;
			m02 = _world.m02;

			m10 = _world.m10;
			m11 = _world.m11;
			m12 = _world.m12;

			m20 = _world.m20;
			m21 = _world.m21;
			m22 = _world.m22;

			m30 = _world.m30;
			m31 = _world.m31;
			m32 = _world.m32;
			var d : Number = (m00 * m11 - m01 * m10) * m22 - (m00 * m12 - m02 * m10) * m21 + (m01 * m12 - m02 * m11) * m20;
			if (d == 0.0) return ;
			d = 1.0 / d;
			_world_inv.m00 = d * (m11 * m22 - m12 * m21);
			_world_inv.m01 = d * (m21 * m02 - m22 * m01);
			_world_inv.m02 = d * (m01 * m12 - m02 * m11);
			_world_inv.m03 = 0;
			_world_inv.m10 = d * (m12 * m20 - m10 * m22 );
			_world_inv.m11 = d * (m22 * m00 - m20 * m02 );
			_world_inv.m12 = d * (m02 * m10 - m00 * m12 );
			_world_inv.m13 = 0;
			_world_inv.m20 = d * (m10 * m21  - m11 * m20);
			_world_inv.m21 = d * (m20 * m01  - m21 * m00);
			_world_inv.m22 = d * (m00 * m11  - m01 * m10);
			_world_inv.m23 = 0;
			_world_inv.m30 = d * (m10 * (m22 * m31 - m21 * m32) + m11 * (m20 * m32 - m22 * m30) + m12 * (m21 * m30 - m20 * m31));
			_world_inv.m31 = d * (m20 * (m02 * m31 - m01 * m32) + m21 * (m00 * m32 - m02 * m30) + m22 * (m01 * m30 - m00 * m31));
			_world_inv.m32 = d * (m30 * (m02 * m11 - m01 * m12) + m31 * (m00 * m12 - m02 * m10) + m32 * (m01 * m10 - m00 * m11));
			_world_inv.m33 = 1;
			//_world_inv.transformVector2(_camPos,_invCamPos);
			var x : Number = _camPos.x;
			var y : Number = _camPos.y;
			var z : Number = _camPos.z;
			_invCamPos.x = (_world_inv.m00 * x + _world_inv.m10 * y + _world_inv.m20 * z + _world_inv.m30);
			_invCamPos.y = (_world_inv.m01 * x + _world_inv.m11 * y + _world_inv.m21 * z + _world_inv.m31);
			_invCamPos.z = (_world_inv.m02 * x + _world_inv.m12 * y + _world_inv.m22 * z + _world_inv.m32);
			var light : Light;
			var dir : Vector3D;
			var pos : Vector3D;
			// transfrom lights into object's world space
			var len : int = _lights.length;
			for (var i : int = 0; i < len; i ++)
			{
				dir = _lightsDir [i];
				pos = _lightsPos [i];
				light = _lights [i];
				if ((light.type == Light.SPOT) || (light.type == Light.DIRECTIONAL))
				{
					//_world_inv.rotateVector2(light.direction,dir);
					x = light.direction.x;
					y = light.direction.y;
					z = light.direction.z;
					dir.x = x * _world_inv.m00 + y * _world_inv.m10 + z * _world_inv.m20;
					dir.y = x * _world_inv.m01 + y * _world_inv.m11 + z * _world_inv.m21;
					dir.z = x * _world_inv.m02 + y * _world_inv.m12 + z * _world_inv.m22;
					dir.normalize ();
				}
				if ((light.type == Light.SPOT) || (light.type == Light.POINT))
				{
					//_world_inv.transformVector2(light.position,pos);
					x = light.position.x;
					y = light.position.y;
					z = light.position.z;
					pos.x = (_world_inv.m00 * x + _world_inv.m10 * y + _world_inv.m20 * z + _world_inv.m30);
					pos.y = (_world_inv.m01 * x + _world_inv.m11 * y + _world_inv.m21 * z + _world_inv.m31);
					pos.z = (_world_inv.m02 * x + _world_inv.m12 * y + _world_inv.m22 * z + _world_inv.m32);
				}
			}
		}

		public override function setTransformView (mat : Matrix4) : void
		{
			_view = mat;
			_view_project.copy (_projection);
			_view_project.multiplyE (_view);
		}

		public override function setMaterial (mat : Material) : void
		{
			material = mat;
			texture = material.texture1;
			switchToTriangleRenderer(getTRIndex());
		}
		override public function getScreenSize () : Dimension2D
		{
			return screenSize;
		}
		//使用该方法将删除之前图像上的数据
		override public function setScreenSize (size : Dimension2D) : void
		{
			if(!size) return;
			if (size.width >= 1 && size.height >= 1)
			{
				screenSize = size;
				targetBitmap.bitmapData = new BitmapData (screenSize.width, screenSize.height, false, 0);
				buffer=new BitmapData (screenSize.width, screenSize.height, false, 0xffffff);
				_clip_scale.buildNDCToDCMatrix(screenSize,1);
			}
		}
		public override function setRenderTarget (target : Sprite) : void
		{
			if ( ! target) return;
			if (renderTarget) renderTarget.removeChild (targetBitmap);
			renderTarget = target;
			renderTarget.addChild (targetBitmap);
		}
		public function clearZBuffer () : void
		{
			buffer.fillRect (screenSize.toRect(), 0x0);
		}
		//for light
		private var l : Vector3D = new Vector3D ();
		private var n : Vector3D = new Vector3D ();
		private var v : Vector3D = new Vector3D ();
		override public function drawIndexedTriangleList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, triangleCount : int) : void
		{
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

			var len : int = triangleCount * 2;
			var _transformLen : int = _transformedPoints.length;
			var i : int;
			if (_transformLen < len)
			{
				for (i = _transformLen; i < len; i ++)
				{
					_transformedPoints [i] = new Vertex4D ();
				}
			}
			
			//trace("_transformedPoints.length========="+_transformedPoints.length);
			tCount = 0;
			iCount = 0;
			vCount = 0;
			
			//material tmp var
			var lighting : Boolean = material.lighting;
			var backfaceCulling : Boolean = material.backfaceCulling;
			var hasTexture : Boolean = (texture!=null);
			var gouraudShading : Boolean = material.gouraudShading;
			var m00 : Number = _current.m00;
			var m10 : Number = _current.m10;
			var m20 : Number = _current.m20;
			var m30 : Number = _current.m30;
			var m01 : Number = _current.m01;
			var m11 : Number = _current.m11;
			var m21 : Number = _current.m21;
			var m31 : Number = _current.m31;
			var m02 : Number = _current.m02;
			var m12 : Number = _current.m12;
			var m22 : Number = _current.m22;
			var m32 : Number = _current.m32;
			var m03 : Number = _current.m03;
			var m13 : Number = _current.m13;
			var m23 : Number = _current.m23;
			var m33 : Number = _current.m33;
			var csm00 : Number = _clip_scale.m00;
			var csm30 : Number = _clip_scale.m30;
			var csm11 : Number = _clip_scale.m11;
			var csm31 : Number = _clip_scale.m31;
			var memi : Color = material.emissiveColor;
			var mamb : Color = material.ambientColor;
			var mdif : Color = material.diffuseColor;
			//太阳光与自发光相加，因为在下面计算时这个值不会改变，放在这里统一计算，加快速度.
			var globalR : int = ambientColor.r + memi.r;
			var globalG : int = ambientColor.g + memi.g;
			var globalB : int = ambientColor.b + memi.b;
			
			for (i = 0; i < triangleCount; i += 3)
			{
				v0 = vertices [int (indexList [int (i + 0)])];
				v1 = vertices [int (indexList [int (i + 1)])];
				v2 = vertices [int (indexList [int (i + 2)])];
				if (backfaceCulling)
				{
					if (((v1.y - v0.y) * (v2.z - v0.z) - (v1.z - v0.z) * (v2.y - v0.y)) * (_invCamPos.x - v0.x) +
					((v1.z - v0.z) * (v2.x - v0.x) - (v1.x - v0.x) * (v2.z - v0.z)) * (_invCamPos.y - v0.y) +
					((v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x)) * (_invCamPos.z - v0.z) <= 0)
					{
						continue;
					}
				}
				tv0 = _transformedPoints [int (tCount ++)];
				tv1 = _transformedPoints [int (tCount ++)];
				tv2 = _transformedPoints [int (tCount ++)];
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
				//先检测除了近裁剪面外与三角形的关系,只判断关系，并不进行裁剪
				// far(  0.,  0.,  1., -1. ),
				plane = _ndc_planes [1];
				if (tv0.z * plane.z + tv0.w * plane.w > 0.)
				{
					if (tv1.z * plane.z + tv1.w * plane.w > 0.)
					{
						if (tv2.z * plane.z + tv2.w * plane.w > 0.)
						{
							tCount -= 3;
							continue;
						}
					}
				}
				// left(  1.,  0.,  0., -1. ),
				plane = _ndc_planes [2];
				if (tv0.x * plane.x + tv0.w * plane.w > 0.)
				{
					if (tv1.x * plane.x + tv1.w * plane.w > 0.)
					{
						if (tv2.x * plane.x + tv2.w * plane.w > 0.)
						{
							tCount -= 3;
							continue;
						}
					}
				}
				// right( -1.,  0.,  0., -1. )
				plane = _ndc_planes [3];
				if (tv0.x * plane.x + tv0.w * plane.w > 0.)
				{
					if (tv1.x * plane.x + tv1.w * plane.w > 0.)
					{
						if (tv2.x * plane.x + tv2.w * plane.w > 0.)
						{
							tCount -= 3;
							continue;
						}
					}
				}
				// bottom(  0.,  1.,  0., -1. )
				plane = _ndc_planes [4];
				if (tv0.y * plane.y + tv0.w * plane.w > 0.)
				{
					if (tv1.y * plane.y + tv1.w * plane.w > 0.)
					{
						if (tv2.y * plane.y + tv2.w * plane.w > 0.)
						{
							tCount -= 3;
							continue;
						}
					}
				}
				// top(  0.,  -1.,  0., -1. )
				plane = _ndc_planes [5];
				if (tv0.y * plane.y + tv0.w * plane.w > 0.)
				{
					if (tv1.y * plane.y + tv1.w * plane.w > 0.)
					{
						if (tv2.y * plane.y + tv2.w * plane.w > 0.)
						{
							tCount -= 3;
							continue;
						}
					}
				}
				var requiredClipping : Boolean = false;
				//检测与近裁剪面是否相交,需要进行裁剪
				// near(  0.,  0., -1., -1. )
				plane = _ndc_planes [0];
				if (tv0.z * plane.z + tv0.w * plane.w > 0.0)
				{
					if (tv1.z * plane.z + tv1.w * plane.w > 0.0)
					{
						if (tv2.z * plane.z + tv2.w * plane.w > 0.0)
						{
							// triangle is  on the back of this plane
							tCount -= 3;
							continue;
						}
						requiredClipping = true;
					} else
					{
						requiredClipping = true;
					}
				} 
				else
				{
					if (tv1.z * plane.z + tv1.w * plane.w < 0.0)
					{
						if (tv2.z * plane.z + tv2.w * plane.w >= 0.0)
						{
							requiredClipping = true;
						}
					} 
					else
					{
						// requires clipping
						requiredClipping = true;
					}
				}
				//lighting
				if (lighting)
				{
					//初始化总体环境光照颜色
					var amb_r_sum0 : Number = 0;
					var amb_r_sum1 : Number = 0;
					var amb_r_sum2 : Number = 0;
					var amb_g_sum0 : Number = 0;
					var amb_g_sum1 : Number = 0;
					var amb_g_sum2 : Number = 0;
					var amb_b_sum0 : Number = 0;
					var amb_b_sum1 : Number = 0;
					var amb_b_sum2 : Number = 0;
					//初始化总体反射光照颜色
					var dif_r_sum0 : Number = 0;
					var dif_g_sum0 : Number = 0;
					var dif_b_sum0 : Number = 0;
					var dif_r_sum1 : Number = 0;
					var dif_g_sum1 : Number = 0;
					var dif_b_sum1 : Number = 0;
					var dif_r_sum2 : Number = 0;
					var dif_g_sum2 : Number = 0;
					var dif_b_sum2 : Number = 0;
					//高光部分
					//var spe_r_sum0 : Number = 0;var spe_g_sum0 : Number = 0;var spe_b_sum0 : Number = 0;
					//var spe_r_sum1 : Number = 0;var spe_g_sum1 : Number = 0;var spe_b_sum1 : Number = 0;
					//var spe_r_sum2 : Number = 0;var spe_g_sum2 : Number = 0;var spe_b_sum2 : Number = 0;
					var light : Light;
					var pos : Vector3D;
					var dir : Vector3D;
					var diffuse : Color;
					var ambient : Color;
					var specular : Color;
					var kc : Number;
					var kl : Number;
					var kq : Number;
					var dist : Number;
					var dist2 : Number;
					var nlen : Number;
					var atten : Number;
					var dpsl : Number;
					var dp : Number;
					var radius : Number;
					var pf : int;
					var k : Number;
					var lightLen : int = _lights.length;
					if (lightLen > 0)
					{
						if ( ! gouraudShading) //flat Light
						{
							
							for (var j : int = 0; j < lightLen; j ++)
							{
								light = _lights [j];
								pos = _lightsPos [j];
								dir = _lightsDir [j];
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
								nlen = Math.sqrt (n.x * n.x + n.y * n.y + n.z * n.z);
								
								if (light.type == 0) //DIRECTIONAL
								
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
								} else if (light.type == 1) //POINT
								
								{
									l.x = pos.x - v0.x;
									l.y = pos.y - v0.y;
									l.z = pos.z - v0.z;
									dp = (n.x * l.x + n.y * l.y + n.z * l.z);
									if (dp > 0)
									{
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
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
									dp = (n.x * dir.x + n.y * dir.y + n.z * dir.z);
									if (dp > 0)
									{
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
										atten = 1 / ((kc + kl * dist + kq * dist2) * nlen);
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
								}
							}
							tv0.r = globalR + (int (amb_r_sum0 * mamb.r) >> 8) + (int (dif_r_sum0 * mdif.r) >> 8);
							tv0.g = globalG + (int (amb_g_sum0 * mamb.g) >> 8) + (int (dif_g_sum0 * mdif.g) >> 8);
							tv0.b = globalB + (int (amb_b_sum0 * mamb.b) >> 8) + (int (dif_b_sum0 * mdif.b) >> 8);
							tv1.r = tv0.r;
							tv1.g = tv0.g;
							tv1.b = tv0.b;
							tv2.r = tv0.r;
							tv2.g = tv0.g;
							tv2.b = tv0.b;
						} else
						{
							for (j = 0; j < lightLen; j ++)
							{
								light = _lights [j];
								pos = _lightsPos [j];
								dir = _lightsDir [j];
								diffuse = light.diffuseColor;
								ambient = light.ambientColor;
								//specular = light.specularColor;
								kc = light.kc;
								kl = light.kl;
								kq = light.kq;
								//radius = light.radius;
								pf = light.powerFactor;
								if (light.type == 0) //DIRECTIONAL
								
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
								if (light.type == 1) //POINT
								
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
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
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
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
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
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
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
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
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
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
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
										dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
										dist = Math.sqrt (dist2);
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
							tv0.r = globalR + (int (amb_r_sum0 * mamb.r) >> 8) + (int (dif_r_sum0 * mdif.r) >> 8);
							tv0.g = globalG + (int (amb_g_sum0 * mamb.g) >> 8) + (int (dif_g_sum0 * mdif.g) >> 8);
							tv0.b = globalB + (int (amb_b_sum0 * mamb.b) >> 8) + (int (dif_b_sum0 * mdif.b) >> 8);
							tv1.r = globalR + (int (amb_r_sum1 * mamb.r) >> 8) + (int (dif_r_sum1 * mdif.r) >> 8);
							tv1.g = globalG + (int (amb_g_sum1 * mamb.g) >> 8) + (int (dif_g_sum1 * mdif.g) >> 8);
							tv1.b = globalB + (int (amb_b_sum1 * mamb.b) >> 8) + (int (dif_b_sum1 * mdif.b) >> 8);
							tv2.r = globalR + (int (amb_r_sum2 * mamb.r) >> 8) + (int (dif_r_sum2 * mdif.r) >> 8);
							tv2.g = globalG + (int (amb_g_sum2 * mamb.g) >> 8) + (int (dif_g_sum2 * mdif.g) >> 8);
							tv2.b = globalB + (int (amb_b_sum2 * mamb.b) >> 8) + (int (dif_b_sum2 * mdif.b) >> 8);
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
						tv0.r = v0.r, tv0.g = v0.g, tv0.b = v0.b;
						tv1.r = v1.r, tv1.g = v1.g, tv1.b = v1.b;
						tv2.r = v2.r, tv2.g = v2.g, tv2.b = v2.b;
					} else //flat
					{
						tv0.r = mdif.r, tv0.g = mdif.g, tv0.b = mdif.b;
						tv1.r = mdif.r, tv1.g = mdif.g, tv1.b = mdif.b;
						tv2.r = mdif.r, tv2.g = mdif.g, tv2.b = mdif.b;
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
				if ( ! requiredClipping) // no clipping required
				{
					//tv0
					var tmp : Number = 1 / tv0.w ;
					tv0.x = (tv0.x * csm00) * tmp + csm30;
					tv0.y = (tv0.y * csm11) * tmp + csm31;
					tv0.iy=int(tv0.y)+1;
					//tv1
					tmp = 1 / tv1.w ;
					tv1.x = (tv1.x * csm00) * tmp + csm30;
					tv1.y = (tv1.y * csm11) * tmp + csm31;
					tv1.iy=int(tv1.y)+1;
					//tv2
					tmp = 1 / tv2.w ;
					tv2.x = (tv2.x * csm00) * tmp + csm30;
					tv2.y = (tv2.y * csm11) * tmp + csm31;
					tv2.iy=int(tv2.y)+1;
					// add to _clipped_indices
					_clipped_indices [iCount] = vCount;
					iCount ++;
					_clipped_vertices [vCount] = tv0;
					vCount ++;
					_clipped_indices [iCount] = vCount;
					iCount ++;
					_clipped_vertices [vCount] = tv1;
					vCount ++;
					_clipped_indices [iCount] = vCount;
					iCount ++;
					_clipped_vertices [vCount] = tv2;
					vCount ++;
					continue;
				}
				_unclipped_vertices [0] = tv0;
				_unclipped_vertices [1] = tv1;
				_unclipped_vertices [2] = tv2;
				//裁剪
				// used for clipping
				var plane : Vector3D;
				var inCount : int;
				var outCount : int;
				var out : Vertex4D
				var a : Vertex4D;
				var b : Vertex4D;
				var aDotPlane : Number;
				var bDotPlane : Number;
				var t : Number;
				// clip to near plane
				inCount = 3;
				outCount = 0;
				plane = _ndc_planes [0];
				b = _unclipped_vertices [0];
				bDotPlane = (b.z * plane.z) + (b.w * plane.w);
				for (var ii : int = 1; ii < inCount + 1; ii ++)
				{
					a = _unclipped_vertices [int (ii % inCount)];
					aDotPlane = (a.z * plane.z) + (a.w * plane.w);
					// current point inside
					if (aDotPlane <= 0.0 )
					{
						// last point outside
						if (bDotPlane > 0.0 )
						{
							// intersect line segment with plane
							//out = dest[outCount++];
							out = _transformedPoints [int (tCount ++)];
							_clipped_vertices0 [int (outCount ++)] = out;
							// get t intersection
							t = bDotPlane / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w));
							// interpolate position
							out.x = b.x + (a.x - b.x ) * t ;
							out.y = b.y + (a.y - b.y ) * t ;
							out.z = b.z + (a.z - b.z ) * t ;
							out.w = b.w + (a.w - b.w ) * t ;
							// interpolate color
							out.r = b.r + (a.r - b.r ) * t ;
							out.g = b.g + (a.g - b.g ) * t ;
							out.b = b.b + (a.b - b.b ) * t ;
							if (hasTexture)
							{
								// interpolate texture
								out.u = b.u + (a.u - b.u ) * t ;
								out.v = b.v + (a.v - b.v ) * t ;
							}
						}
						_clipped_vertices0 [int (outCount ++)] = a;
					} 
					else
					{
						// current point outside
						if (bDotPlane <= 0.0 )
						{
							// previous was inside
							// intersect line segment with plane
							out = _transformedPoints [int (tCount ++)];
							_clipped_vertices0 [int (outCount ++)] = out;
							// get t intersection
							t = bDotPlane / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w))
							// interpolate position
							out.x = b.x + ((a.x - b.x ) * t );
							out.y = b.y + ((a.y - b.y ) * t );
							out.z = b.z + ((a.z - b.z ) * t );
							out.w = b.w + ((a.w - b.w ) * t );
							// interpolate color
							//out.a = b.a + ( ( a.a - b.a ) * t );
							out.r = b.r + ((a.r - b.r ) * t );
							out.g = b.g + ((a.g - b.g ) * t );
							out.b = b.b + ((a.b - b.b ) * t );
							if (hasTexture)
							{
								// interpolate texture
								out.u = b.u + ((a.u - b.u ) * t );
								out.v = b.v + ((a.v - b.v ) * t );
							}
						}
					}
					b = a;
					bDotPlane = aDotPlane;
				}
				// check we have 3 or more vertices
				if (outCount < 3) continue;
				// put back into screen space.
				vCount2 = vCount;
				for (var g : int = 0; g < outCount; g ++)
				{
					tv0 = _clipped_vertices0 [g];
					tmp = 1 / (tv0.w );
					tv0.x = (tv0.x * csm00) * tmp + csm30;
					tv0.y = (tv0.y * csm11) * tmp + csm31;
					tv0.iy=int(tv0.y)+1;
					_clipped_vertices [int (vCount ++)] = tv0;
				}
				//( triangle-fan, 0-1-2,0-2-3.. )
				for (g = 0; g <= outCount - 3; g ++)
				{
					_clipped_indices [int (iCount ++)] = (vCount2);
					_clipped_indices [int (iCount ++)] = (vCount2 + g + 1);
					_clipped_indices [int (iCount ++)] = (vCount2 + g + 2);
				}
			}
			trace("tCount="+tCount);
			primitivesDrawn += int (iCount / 3);
			currentTriangleRenderer.drawIndexedTriangleList (_clipped_vertices, vCount, _clipped_indices, iCount);
		}
		override public function drawMeshBuffer(mesh:IMeshBuffer):void
		{
			drawIndexedTriangleList(mesh.getVertices(),mesh.getVertexCount(),mesh.getIndices(),mesh.getIndexCount());
		}
		/**
		*用来渲染由线段组成的物体 ,此类物体不需要进行光照，贴图，和贴图坐标计算等
		* @vertices  Array 点的集合
		* @vertexCount int vertices的长度
		* @indexList 点与点之间的顺序(2点组成一条直线)
		* @indexCount int indexList.length
		*/
		override public function drawIndexedLineList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var v0 : Vertex, v1 : Vertex;
			var tv0 : Vertex4D, tv1 : Vertex4D;
			var iCount : int, vCount : int;
			var len : int = _transformedLinePoints.length;
			if (len < indexCount)
			{
				for (var i : int = len; i < indexCount; i ++)
				{
					_transformedLinePoints [i] = new Vertex4D ();
				}
			}
			var m00 : Number = _current.m00;
			var m10 : Number = _current.m10;
			var m20 : Number = _current.m20;
			var m30 : Number = _current.m30;
			var m01 : Number = _current.m01;
			var m11 : Number = _current.m11;
			var m21 : Number = _current.m21;
			var m31 : Number = _current.m31;
			var m02 : Number = _current.m02;
			var m12 : Number = _current.m12;
			var m22 : Number = _current.m22;
			var m32 : Number = _current.m32;
			var m03 : Number = _current.m03;
			var m13 : Number = _current.m13;
			var m23 : Number = _current.m23;
			var m33 : Number = _current.m33;
			var csm00 : Number = _clip_scale.m00;
			var csm30 : Number = _clip_scale.m30;
			var csm11 : Number = _clip_scale.m11;
			var csm31 : Number = _clip_scale.m31;
			iCount = 0;
			vCount = 0;
			// used for clipping
			var plane : Vector3D;
			for (i = 0; i < indexCount; i += 2)
			{
				v0 = vertices [int (indexList [int (i + 0)])];
				v1 = vertices [int (indexList [int (i + 1)])];
				tv0 = _transformedLinePoints [int (vCount ++)];
				tv1 = _transformedLinePoints [int (vCount ++)];
				tv0.x = m00 * v0.x + m10 * v0.y + m20 * v0.z + m30;
				tv0.y = m01 * v0.x + m11 * v0.y + m21 * v0.z + m31;
				tv0.z = m02 * v0.x + m12 * v0.y + m22 * v0.z + m32;
				tv0.w = m03 * v0.x + m13 * v0.y + m23 * v0.z + m33;
				tv0.r = v0.r;
				tv0.g = v0.g;
				tv0.b = v0.b;
				tv1.x = m00 * v1.x + m10 * v1.y + m20 * v1.z + m30;
				tv1.y = m01 * v1.x + m11 * v1.y + m21 * v1.z + m31;
				tv1.z = m02 * v1.x + m12 * v1.y + m22 * v1.z + m32;
				tv1.w = m03 * v1.x + m13 * v1.y + m23 * v1.z + m33;
				tv1.r = v1.r;
				tv1.g = v1.g;
				tv1.b = v1.b;
				// far(  0.,  0.,  1., -1. ),
				plane = _ndc_planes [1];
				if (tv0.z * plane.z + tv0.w * plane.w > 0.)
				{
					if (tv1.z * plane.z + tv1.w * plane.w > 0.)
					{
						vCount -= 2;
						continue;
					}
				}
				// left(  1.,  0.,  0., -1. ),
				plane = _ndc_planes [2];
				if (tv0.x * plane.x + tv0.w * plane.w > 0.)
				{
					if (tv1.x * plane.x + tv1.w * plane.w > 0.)
					{
						vCount -= 2;
						continue;
					}
				}
				// right( -1.,  0.,  0., -1. )
				plane = _ndc_planes [3];
				if (tv0.x * plane.x + tv0.w * plane.w > 0.)
				{
					if (tv1.x * plane.x + tv1.w * plane.w > 0.)
					{
						vCount -= 2;
						continue;
					}
				}
				// bottom(  0.,  1.,  0., -1. )
				plane = _ndc_planes [4];
				if (tv0.y * plane.y + tv0.w * plane.w > 0.)
				{
					if (tv1.y * plane.y + tv1.w * plane.w > 0.)
					{
						vCount -= 2;
						continue;
					}
				}
				// top(  0.,  -1.,  0., -1. )
				plane = _ndc_planes [5];
				if (tv0.y * plane.y + tv0.w * plane.w > 0.)
				{
					if (tv1.y * plane.y + tv1.w * plane.w > 0.)
					{
						vCount -= 2;
						continue;
					}
				}
				var requiredClipping : Boolean = false;
				// near(  0.,  0., -1., -1. )
				plane = _ndc_planes [0];
				if (tv0.z * plane.z + tv0.w * plane.w > 0.0)
				{
					if (tv1.z * plane.z + tv1.w * plane.w > 0.0)
					{
						vCount -= 2;
						continue;
					} else
					{
						requiredClipping = true;
					}
				} 
				else
				{
					if (tv1.z * plane.z + tv1.w * plane.w >= 0.0)
					{
						requiredClipping = true;
					}
				}
				// clipping required
				if (requiredClipping)
				{
					var aDotPlane : Number = (tv0.z * plane.z) + (tv0.w * plane.w);
					var bDotPlane : Number = (tv1.z * plane.z) + (tv1.w * plane.w);
					if (aDotPlane <= 0.0 )
					{
						// last point outside
						var t : Number = bDotPlane / (((tv1.z - tv0.z) * plane.z) + ((tv1.w - tv0.w) * plane.w));
						tv1.x = tv1.x + (tv0.x - tv1.x ) * t ;
						tv1.y = tv1.y + (tv0.y - tv1.y ) * t ;
						tv1.z = tv1.z + (tv0.z - tv1.z ) * t ;
						tv1.w = tv1.w + (tv0.w - tv1.w ) * t ;
					} else
					{
						t = aDotPlane / (((tv0.z - tv1.z) * plane.z) + ((tv0.w - tv1.w) * plane.w));
						tv0.x = tv0.x + (tv1.x - tv0.x ) * t ;
						tv0.y = tv0.y + (tv1.y - tv0.y ) * t ;
						tv0.z = tv0.z + (tv1.z - tv0.z ) * t ;
						tv0.w = tv0.w + (tv1.w - tv0.w ) * t ;
					}
				}
				var tmp : Number = 1 / tv0.w ;
				tv0.x = (tv0.x * csm00) * tmp + csm30;
				tv0.y = (tv0.y * csm11) * tmp + csm31;
				tv0.iy=int(tv0.y)+1;
				tmp = 1 / tv1.w ;
				tv1.x = (tv1.x * csm00) * tmp + csm30;
				tv1.y = (tv1.y * csm11) * tmp + csm31;
				tv1.iy=int(tv1.y)+1;
				_clipped_line_indices [iCount] = vCount;
				iCount ++;
				_clipped_line_vertices [vCount] = tv0;
				vCount ++;
				_clipped_line_indices [iCount] = vCount;
				iCount ++;
				_clipped_line_vertices [vCount] = tv1;
				vCount ++;
			}
			currentTriangleRenderer.drawIndexedLineList (_clipped_line_vertices, vCount, _clipped_line_indices, iCount);
		}
		override public function drawStencilShadowVolume (vertices : Vector.<Vertex>, vertexCount : int, useZFailMethod : Boolean) : void
		{
		}
		override public function getName () : String
		{
			return VideoType.PIXEL;
		}
		override public function getDriverType () : String
		{
			return VideoType.PIXEL;
		}
		override public function createScreenShot () : BitmapData
		{
			return targetBitmap.bitmapData.clone ();
		}
		override public function setPerspectiveCorrectDistance (distance : Number = 400) : void
		{
			if (distance <= 0) distance = 1;
			perspectiveDistance = distance;
			var len : int = triangleRenderers.length;
			for (var i : int = 0; i < len; i ++)
			{
				var render : ITriangleRenderer = triangleRenderers [i];
				render.setPerspectiveCorrectDistance (distance);
			}
		}
		override public function setMipMapDistance (distance : Number = 800) : void
		{
			if (distance < 1) distance = 1;
			mipMapDistance = distance;
			var len : int = triangleRenderers.length;
			for (var i : int = 0; i < len; i ++)
			{
				var render : ITriangleRenderer = triangleRenderers [i];
				render.setMipMapDistance (distance);
			}
		}
		public function getZBuffer():BitmapData
		{
			return this.buffer;
		}
	}
}

﻿package linda.video.pixel32
{
	import linda.material.Material;
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	public class TriangleRenderer
	{
		protected var target : BitmapData;
		protected var buffer : BitmapData;
		protected var material : Material;
		//alpha
		protected var alpha:Number;
		protected var invAlpha:Number;
		protected var intAlpha:int;

		protected var perspectiveCorrect:Boolean=false;
		protected var perspectiveDistance:Number=400;
		protected var mipMapDistance:Number=500;
		
		public function setRenderTarget (target : BitmapData, buffer : BitmapData) : void
		{
			this.target = target;
			this.buffer = buffer;
		}
		public function setPerspectiveCorrectDistance(distance:Number=400):void
		{
			perspectiveDistance=distance;
		}
		public function setMipMapDistance(distance:Number=800):void
		{
			mipMapDistance=distance;
		}
		public function setMaterial (mat : Material) : void
		{
			material = mat;

			if(material.transparenting)
			{
				alpha = material.alpha;
				invAlpha = 1 - alpha;
				intAlpha = int (alpha * 0xFF);
			}	
		}
		/**
		*用来渲染由线段组成的物体,此类物体不需要进行光照，贴图，和贴图坐标计算等
		* @vertices  Array 点的集合
		* @vertexCount int vertices的长度
		* @indexList 点与点之间的顺序(每两个组成一条直线)
		* @indexCount int indexList.length
		*/
		public function drawIndexedLineList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var x0 : int,x1 : int,x2 : int; 
			var y0 : int,y1 : int,y2 : int;
			var z0 : Number,z1 : Number,z2 : Number;
			var error: int;
			var vt0:Vertex4D,vt1:Vertex4D,vt2:Vertex4D;
			for (var i : int = 0; i < indexCount; i +=2)
			{
				vt0 = vertices [int(indexList [i])];
				vt1 = vertices [int(indexList [int(i + 1)])];
				
				x0 = int (vt0.x + 0.5) , y0 = int (vt0.y + 0.5) , z0 = vt0.w;
				x1 = int (vt1.x + 0.5) , y1 = int (vt1.y + 0.5) , z1 = vt1.w;
				
				var color:uint = ( 0xFF000000 | vt1.r << 16 | vt1.g << 8 | vt1.b );

				var dx: int = x1 - x0;
				var dy: int = y1 - y0;
				var dz: int = z1 - z0;
				var yi: int = 1;
				var dzdy:Number;

				if( dx < dy )
				{
					//-- swap end points
					x0 ^= x1; x1 ^= x0; x0 ^= x1;
					y0 ^= y1; y1 ^= y0; y0 ^= y1;
					var temp:Number = z0; z0 = z1; z1 = temp;
				}

				if( dx < 0 )
				{
					dx = -dx; yi = -yi;dz = -dz;
				}
			
				if( dy < 0 )
				{
					dy = -dy; yi = -yi;dz = -dz;
				}
				
				if( dy > dx )
				{
					error = -( dy >> 1 );
					dzdy = dz/(y0-y1);
					for( ; y1 < y0 ; y1++ )
					{
						var oldZ:int=buffer.getPixel (x1, y1);
						if (z1 < oldZ)
						{
					    	target.setPixel32( x1, y1, color );
					   	 	buffer.setPixel(x1,y1,z1);
						}
						error += dx;
						if( error > 0 )
						{
							x1 += yi;
							z1 += dzdy;
							error -= dy;
						}
					}
				}
				else
				{
					error = -( dx >> 1 );
					dzdy = dz/(x1-x0);
					for( ; x0 < x1 ; x0++ )
					{
						oldZ=buffer.getPixel (x1, y1);
						if (z1 < oldZ)
						{
					   	 	target.setPixel32( x0, y0, color );
					    	buffer.setPixel(x0,y0,z1);
						}
						error += dy;
						if( error > 0 )
						{
							y0 += yi;
							z1 += dzdy;
							error -= dx;
						}
					}
				}
				
			}
		}
	}
}


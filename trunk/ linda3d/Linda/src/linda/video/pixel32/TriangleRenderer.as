package linda.video.pixel32
{
	import linda.material.Material;
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	public class TriangleRenderer implements ITriangleRenderer
	{
		protected var target : BitmapData;
		protected var buffer : BitmapData;
		protected var material : Material;

		//x y z
		protected var xstart : int; 
		protected var xend : int;
		protected var ystart : int; 
		protected var yend : int;

		protected var dyr : Number; 
		protected var dyl : Number;

		protected var minX:int;
		protected var minY:int;
		protected var maxX:int;
		protected var maxY:int;

		//x,z
		protected var dxdyl : Number; 
		protected var dxdyr : Number;
		protected var dzdyl : Number; 
		protected var dzdyr : Number;
		//r,g,b
		protected var drdyl : Number;
		protected var drdyr : Number;
		protected var dgdyl : Number;
		protected var dgdyr : Number;
		protected var dbdyl : Number;
		protected var dbdyr : Number;
		//u,v
		protected var dudyl : Number;
		protected var dudyr : Number;
		protected var dvdyl : Number;
		protected var dvdyr : Number;

		//gouraud
		protected var x0 : int; 
		protected var x1 : int; 
		protected var x2 : int;
		protected var y0 : int; 
		protected var y1 : int; 
		protected var y2 : int;
		protected var z0 : Number; 
		protected var z1 : Number; 
		protected var z2 : Number;
		protected var r0 : int;
		protected var g0 : int;
		protected var b0 : int;
		protected var r1 : int;
		protected var g1 : int;
		protected var b1 : int;
		protected var r2 : int;
		protected var g2 : int;
		protected var b2 : int;
		protected var u0 : Number;
		protected var v0 : Number;
		protected var u1 : Number;
		protected var v1 : Number; 
		protected var u2 : Number; 
		protected var v2 : Number;
		
		
		protected var xi : int; 
		protected var yi : int; 
		protected var zi : Number;
		protected var ri : Number;
		protected var bi : Number;
		protected var gi : Number;
		protected var ui : Number;
		protected var vi : Number;
		
		protected var xl : Number; 
		protected var xr : Number;
		protected var zl : Number; 
		protected var zr : Number;
		protected var rl : Number;
		protected var gl : Number;
		protected var bl : Number;
		protected var rr : Number;
		protected var gr : Number;
		protected var br : Number;
		protected var ul : Number;
		protected var vl : Number;
		protected var ur : Number;
		protected var vr : Number;
		
		protected var dx : Number; 
		protected var dy : Number; 
		protected var dz : Number;
		protected var dr : Number;
		protected var dg : Number;
		protected var db : Number;
		protected var du : Number;
		protected var dv : Number;

		//alpha
		protected var alpha:Number;
		protected var invAlpha:Number;
		protected var intAlpha:int;
		
		//背景颜色
		protected var bga : int;
		protected var bgColor : uint;
		
		//texture
		protected var textel : uint;
		protected var color : uint;
		
		protected var tw:Number;
		protected var th:Number;
		
		protected var perspectiveCorrect:Boolean=false;
		protected var perspectiveDistance:Number=400;
		protected var mipMapDistance:Number=500;

		protected var bitmapData:BitmapData;
		
		protected var vt0:Vertex4D;
		protected var vt1:Vertex4D;
		protected var vt2:Vertex4D;
		public function setRenderTarget (target : BitmapData, buffer : BitmapData) : void
		{
			this.target = target;
			this.buffer = buffer;
			
			var rect:Rectangle=target.rect;
			minX=int(rect.x);
			minY=int(rect.y);
			maxX=int(rect.width);
			maxY=int(rect.height);
			
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
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
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
			var error: int;
			var oldZ:int;
			var dx: int ;
			var dy: int ;
			var dz: int ;
			var yi: int ;
			var dzdy:Number;
			var temp:Number;
			for (var i : int = 0; i < indexCount; i +=2)
			{
				vt0 = vertices [int(indexList [i])];
				vt1 = vertices [int(indexList [int(i + 1)])];
				
				x0 = int (vt0.x + 0.5) , y0 = int (vt0.y + 0.5) , z0 = vt0.w;
				x1 = int (vt1.x + 0.5) , y1 = int (vt1.y + 0.5) , z1 = vt1.w;
				
				color = ( 0xFF000000 | vt1.r << 16 | vt1.g << 8 | vt1.b );

				dx  = x1 - x0;
				dy  = y1 - y0;
				dz  = z1 - z0;
				yi  = 1;

				if( dx < dy )
				{
					//-- swap end points
					x0 ^= x1; x1 ^= x0; x0 ^= x1;
					y0 ^= y1; y1 ^= y0; y0 ^= y1;
					temp = z0; z0 = z1; z1 = temp;
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
						oldZ=buffer.getPixel (x1, y1);
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


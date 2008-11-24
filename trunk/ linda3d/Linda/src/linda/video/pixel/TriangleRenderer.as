package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.material.Material;
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	
	import flash.display.*;
	public class TriangleRenderer implements ITriangleRenderer
	{
		public static const Fixed:Number=1000.0;
		
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

		//x,z
		protected var dxdyl : Number; 
		protected var dxdyr : Number;
		protected var dzdyl : Number; 
		protected var dzdyr : Number;

		protected var x0 : int; 
		protected var x1 : int; 
		protected var x2 : int;
		protected var y0 : int; 
		protected var y1 : int; 
		protected var y2 : int;
		protected var z0 : Number; 
		protected var z1 : Number; 
		protected var z2 : Number;

		protected var xi : int; 
		protected var yi : int; 
		protected var zi : Number;
		
		protected var xl : Number; 
		protected var xr : Number;
		protected var zl : Number; 
		protected var zr : Number;
		
		protected var dx : Number; 
		protected var dy : Number; 
		protected var dz : Number;

		protected var perspectiveCorrect:Boolean=false;
		protected var perspectiveDistance:Number=400;
		protected var mipMapDistance:Number=800;

		//alpha
		protected var alpha:Number;
		protected var invAlpha:Number;
		protected var intAlpha:int;

		protected var color : uint;
		
		protected var vt0:Vertex4D;
		protected var vt1:Vertex4D;
		protected var vt2:Vertex4D;
		
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
		public function drawIndexedLineList (vertices :Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int): void
		{
			var error: int;
			for (var i : int = 0; i < indexCount; i +=2)
			{
				vt0 = vertices [int(indexList [i + 0])];
				vt1 = vertices [int(indexList [i + 1])];

				x0 = int (vt0.x + 0.5) , y0 = int (vt0.y + 0.5) , z0 = (Fixed * vt0.w);
				x1 = int (vt1.x + 0.5) , y1 = int (vt1.y + 0.5) , z1 = (Fixed * vt1.w);
				
				color = ( 0xFF000000 | vt1.r << 16 | vt1.g << 8 | vt1.b );

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
						if (z1 < buffer.getPixel (x1, y1))
						{
					    	target.setPixel( x1, y1, color );
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
						if (z1 < buffer.getPixel (x0, y0))
						{
					   	 	target.setPixel( x0, y0, color );
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


﻿package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.video.ITriangleRenderer;
	import linda.math.Vertex4D;
	public class TRWire extends TriangleRenderer implements ITriangleRenderer
	{
		protected var z0 : Number; 
		protected var z1 : Number;
		protected var z2 : Number; 
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var color:uint;
			var x0 : int; 
			var x1 : int; 
			var x2 : int; 
			var y0 : int; 
			var y1 : int; 
			var y2 : int;
			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			if ( ! material.transparenting)
			{
				 var ii:int;
			     for (var i : int = 0; i < indexCount; i += 3)
				 {
					ii  = indexList [i];
					vt0 = vertices [ii];
					ii  = indexList [int(i+ 1)];
				    vt1 = vertices [ii];
					ii  = indexList [int(i+ 2)];
					vt2 = vertices [ii];
					
					z0 = vt0.z;
					z1 = vt1.z;
					z2 = vt2.z;

					color = (0xFF000000 | vt0.r << 16 | vt0.g << 8 | vt0.b );
					bresenham (vt0.x, vt0.y, vt1.x, vt1.y, color);
					color = (0xFF000000 | vt1.r << 16 | vt1.g << 8 | vt1.b );
					bresenham (vt1.x, vt1.y, vt2.x, vt2.y, color);
					color = (0xFF000000 | vt2.r << 16 | vt2.g << 8 | vt2.b );
					bresenham (vt2.x, vt2.y, vt0.x, vt0.y, color);
				}
			} else
			{
				 for (i = 0; i < indexCount; i += 3)
				 {
					ii  = indexList[i];
					vt0 = vertices[ii];
					ii  = indexList[int(i+ 1)];
					vt1 = vertices[ii];
					ii  = indexList[int(i+ 2)];
					vt2 = vertices[ii];

					z0 = vt0.z;
					z1 = vt1.z;
					z2 = vt2.z;

					bresenhamAlpha (vt0.x, vt0.y, vt1.x, vt1.y, vt0.r, vt0.g, vt0.b);
					bresenhamAlpha (vt1.x, vt1.y, vt2.x, vt2.y, vt1.r, vt1.g, vt1.b);
					bresenhamAlpha (vt2.x, vt2.y, vt0.x, vt0.y, vt2.r, vt2.g, vt2.b);
				}
			}
		}
		protected function bresenham (x0 : int, y0 : int, x1 : int, y1 : int, value : uint ) : void
		{
			var oldZ:Number;
            var pos:int;
			var error : int;
			var dx : int = x1 - x0;
			var dy : int = y1 - y0;
			var dz : int = z1 - z0;
			var yi : int = 1;
			var dzdy : Number;
			if (dx < dy )
			{
				//-- swap end points
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
				var temp : Number = z1;
				z1 = z2;
				z2 = temp;
			}
			if (dx < 0 )
			{
				dx = - dx;
				yi = - yi;
				dz = - dz;
			}
			if (dy < 0 )
			{
				dy = - dy;
				yi = - yi;
				dz = - dz;
			}
			if (dy > dx )
			{
				error = - (dy >> 1 );
				dzdy = dz / (y0 - y1);
				for (; y1 < y0 ; y1 +=1)
				{
					pos=x1+y1*height;
					oldZ=buffer[pos];
					if (z1 > oldZ)
					{
						target[pos] = value;
						buffer[pos] = z1;
					}
					error += dx;
					if (error > 0 )
					{
						x1 += yi;
						z1 += dzdy;
						error -= dy;
					}
				}
			} 
			else
			{
				error = - (dx >> 1 );
				dzdy = dz / (x1 - x0);
				for (; x0 < x1 ; x0 +=1)
				{
					pos=x0+y0*height;
					oldZ=buffer[pos];
					if (z1 > oldZ)
					{
						target[pos] = value;
						buffer[pos] = z1;
					}
					error += dy;
					if (error > 0 )
					{
						y0 += yi;
						z1 += dzdy;
						error -= dx;
					}
				}
			}
		}
		protected function bresenhamAlpha (x0 : int, y0 : int, x1 : int, y1 : int, r : int, g : int, b : int ) : void
		{
			var color:uint;
			var bga : int;
		    var bgColor : uint;
			var oldZ:Number;
            var pos:int;
			var error : int;
			var dx : int = x1 - x0;
			var dy : int = y1 - y0;
			var dz : int = z1 - z0;
			var yi : int = 1;
			var dzdy : Number;
			if (dx < dy )
			{
				//-- swap end points
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
				var temp : Number = z1;
				z1 = z2;
				z2 = temp;
			}
			if (dx < 0 )
			{
				dx = - dx;
				yi = - yi;
				dz = - dz;
			}
			if (dy < 0 )
			{
				dy = - dy;
				yi = - yi;
				dz = - dz;
			}
			if (dy > dx )
			{
				error = - (dy >> 1 );
				dzdy = dz / (y0 - y1);
				for (; y1 < y0 ; y1 +=1)
				{
					pos=x1+y1*height;
					oldZ=buffer[pos];
					if (z1 > oldZ)
					{
						bgColor = target[pos];
						color=((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
						       (alpha * g + invAlpha * (bgColor >> 8 & 0xFF))  << 8  |  
						       (alpha * b + invAlpha * (bgColor & 0xFF)));
						target[pos] = color;
					}
					error += dx;
					if (error > 0 )
					{
						x1 += yi;
						z1 += dzdy;
						error -= dy;
					}
				}
			} 
			else
			{
				error = - (dx >> 1 );
				dzdy = dz / (x1 - x0);
				for (; x0 < x1 ; x0 +=1)
				{
					pos=x0+y0*height;
					oldZ=buffer[pos];
					if (z1 > oldZ)
					{
						bgColor = target[pos];
						color=((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
						       (alpha * g + invAlpha * (bgColor >> 8 & 0xFF))  << 8  |  
						       (alpha * b + invAlpha * (bgColor & 0xFF)));
						target[pos] = color;
					}
					error += dy;
					if (error > 0 )
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

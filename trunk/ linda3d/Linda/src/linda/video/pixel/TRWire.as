package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.video.ITriangleRenderer;
	import linda.math.Vertex4D;
	public class TRWire extends TriangleRenderer implements ITriangleRenderer
	{
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var color:uint;
			var x0 : int; 
			var x1 : int; 
			var x2 : int; 
			var y0 : int; 
			var y1 : int; 
			var y2 : int;
			var z0 : Number; 
			var z1 : Number; 
			var z2 : Number;
			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			if ( ! material.transparenting)
			{
				 var ii:int;
			     for (var i : int = 0; i < indexCount; i += 3)
				 {
					ii=indexList [i];
					vt0 = vertices [ii];
					ii=indexList [int(i+ 1)];
				    vt1 = vertices [ii];
					ii=indexList [int(i+ 2)];
					vt2 = vertices [ii];

					x0 = vt0.x;
					y0 = vt0.y;
					z0 = vt0.w;
					x1 = vt1.x;
					y1 = vt1.y;
					z1 = vt1.w;
					x2 = vt2.x;
					y2 = vt2.y;
					z2 = vt2.w;
					color = (vt0.r << 16 | vt0.g << 8 | vt0.b );
					bresenham (x0, y0, x1, y1, color);
					color = (vt1.r << 16 | vt1.g << 8 | vt1.b );
					bresenham (x1, y1, x2, y2, color);
					color = (vt2.r << 16 | vt2.g << 8 | vt2.b );
					bresenham (x2, y2, x0, y0, color);
				}
			} else
			{
				 for (i = 0; i < indexCount; i += 3)
				 {
					ii=indexList [int(i+ 0)];
					vt0 = vertices [ii];
					ii=indexList [int(i+ 1)];
					vt1 = vertices [ii];
					ii=indexList [int(i+ 2)];
					vt2 = vertices [ii];

					x0 = vt0.x;
					y0 = vt0.y;
					z0 = vt0.w;
					x1 = vt1.x;
					y1 = vt1.y;
					z1 = vt1.w;
					x2 = vt2.x;
					y2 = vt2.y;
					z2 = vt2.w;
					bresenhamAlpha (x0, y0, x1, y1, vt0.r, vt0.g, vt0.b);
					bresenhamAlpha (x1, y1, x2, y2, vt1.r, vt1.g, vt1.b);
					bresenhamAlpha (x2, y2, x0, y0, vt2.r, vt2.g, vt2.b);
				}
			}
		}
		private function bresenham (x0 : int, y0 : int, x1 : int, y1 : int, value : uint ) : void
		{
			var z0 : Number; 
			var z1 : Number;
			var z2 : Number; 
			var oldZ:int;
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
					oldZ=buffer.getPixel (x1, y1);
					if (z1 < oldZ)
					{
						target.setPixel (x1, y1, value );
						buffer.setPixel (x1, y1, z1);
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
					oldZ=buffer.getPixel (x0, y0);
					if (z1 < oldZ)
					{
						target.setPixel (x0, y0, value );
						buffer.setPixel (x0, y0, z1);
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
		private function bresenhamAlpha (x0 : int, y0 : int, x1 : int, y1 : int, r : int, g : int, b : int ) : void
		{
			var color:uint;
			var z0 : Number; 
			var z1 : Number;
			var z2 : Number; 
			var bga : int;
		    var bgColor : uint;
			var oldZ:int;
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
					oldZ=buffer.getPixel (x1, y1);
					if (z1 < oldZ)
					{
						bgColor = target.getPixel (x1, y1);
						color=((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
						       (alpha * g + invAlpha * (bgColor >> 8 & 0xFF))  << 8  |  
						       (alpha * b + invAlpha * (bgColor & 0xFF)));
						target.setPixel (x1, y1,color);
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
					oldZ=buffer.getPixel (x0, y0);
					if (z1 < oldZ)
					{
						bgColor = target.getPixel (x0, y0);
						color=((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
						       (alpha * g + invAlpha * (bgColor >> 8 & 0xFF))  << 8  |  
						       (alpha * b + invAlpha * (bgColor & 0xFF)));
						target.setPixel (x0, y0,color);
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

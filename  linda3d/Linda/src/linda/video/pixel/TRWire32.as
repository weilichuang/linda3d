package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.video.ITriangleRenderer;
	import linda.math.Vertex4D;
	public class TRWire32 extends TRWire
	{
		override protected function bresenhamAlpha (x0 : int, y0 : int, x1 : int, y1 : int, r : int, g : int, b : int ) : void
		{
			var color:uint;
			var bga : int;
		    var bgColor : uint;
			var error : int;
			var dx : int = x1 - x0;
			var dy : int = y1 - y0;
			var dz : int = z1 - z0;
			var yi : int = 1;
			var oldZ:Number;
            var pos:int;
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
					bgColor = target[pos];
					bga = bgColor >> 24 & 0xFF ;
					if (bga < 0xFF || z1 > oldZ)
					{
						color=((alpha * intAlpha + invAlpha * bga)             << 24 |  
						       (alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |  
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
					bgColor = target[pos];
					bga = bgColor >> 24 & 0xFF ;
					if (bga < 0xFF || z1 > oldZ)
					{
						color=((alpha * intAlpha + invAlpha * bga)             << 24 |  
						       (alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |  
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

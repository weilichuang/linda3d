package linda.video.pixel;

	import flash.Vector;
	
	import linda.video.ITriangleRenderer;
	import linda.math.Vertex4D;
	class TRWire32 extends TRWire
	{
		override private function bresenhamAlpha(x0 : Int, y0 : Int, z0:Float, x1 : Int, y1 : Int, z1:Float, r : Int, g : Int, b : Int ) : Void
		{
			var bgColor : UInt;
			var bga : Int;
			var error : Int;
			var dx : Int = x1 - x0;
			var dy : Int = y1 - y0;
			var yi : Int = 1;
			
            var pos:Int;
			var dz : Float = z1 - z0;
			var dzdy : Float;
			if (dx < dy )
			{
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
				var t : Float = z1;z1 = z2;z2 = t;
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
				for (y in y1...y0)
				{
					pos=x1+y*height;
					bgColor = target[pos];
					bga = bgColor >> 24 & 0xFF ;
					if (bga < 0xFF || z1 > buffer[pos])
					{ 
						target[pos] = (((alpha * bga) >> 8)                                   << 24 |
						               ((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  			   ((alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  			   ((alpha * b + invAlpha * (bgColor & 0xFF)) >> 8)
						              );			 
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
				for (x in x0...x1)
				{
					pos=x+y0*height;
					bgColor = target[pos];
					bga = bgColor >> 24 & 0xFF ;
					if (bga < 0xFF || z0 > buffer[pos])
					{
						target[pos] = (((alpha * bga) >> 8)                                   << 24 |
						               ((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  			   ((alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  			   ((alpha * b + invAlpha * (bgColor & 0xFF)) >> 8)
						              );
					}
					error += dy;
					if (error > 0 )
					{
						y0 += yi;
						z0 += dzdy;
						error -= dx;
					}
				}
			}
		}
	}

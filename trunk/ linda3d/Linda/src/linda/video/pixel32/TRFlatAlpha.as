package linda.video.pixel32
{
	import __AS3__.vec.Vector;
	
	import linda.math.Vertex4D;
	public class TRFlatAlpha extends TriangleRenderer
	{
		//todo 修改开始处交换方式
		override public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var r:int,b:int,g:int;
			var temp1 : Vertex4D;
			var temp : Number;
			var side : int;
		 	var ys : int;
		 	var type : int;
            var oldZ:int;
			var ii:int;
			for (var i : int = 0; i < indexCount; i += 3)
			{
				ii=indexList [int(i+ 0)];
				vt0 = vertices [ii];
				ii=indexList [int(i+ 1)];
				vt1 = vertices [ii];
				ii=indexList [int(i+ 2)];
				vt2 = vertices [ii];
				
				if (vt1.iy < vt0.iy)
				{
					temp1 = vt0; vt0 = vt1; vt1 = temp1;
				}
				if (vt2.iy < vt0.iy)
				{
					temp1 = vt0; vt0 = vt2; vt2 = temp1;
				}
				if (vt2.iy < vt1.iy)
				{
					temp1 = vt1; vt1 = vt2; vt2 = temp1;
				}
				
				type = 0;
				if (vt0.iy == vt1.iy)
				{
					type = 1;
					if (vt1.x < vt0.x)
					{
						temp1 = vt0; vt0 = vt1; vt1 = temp1;
					}
				} else if (vt1.iy == vt2.iy)
				{
					type = 2;
					if (vt2.x < vt1.x)
					{
						temp1 = vt1; vt1 = vt2; vt2 = temp1;
					}
				}
				
				x0 = vt0.x ; y0 = vt0.y ; z0 = vt0.w;
				x1 = vt1.x ; y1 = vt1.y ; z1 = vt1.w;
				x2 = vt2.x ; y2 = vt2.y ; z2 = vt2.w;
				if (((x0 == x1) && (x1 == x2)) || ((y0 == y1) && (y1 == y2))) continue;
				r = vt0.r;g = vt0.g;b = vt0.b;
				
				side = 0;
				ys = y1;
				
				if(type==0)
				{
					yend = y2;
						dyl = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dyl;
						dzdyl = (z1 - z0) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						dzdyr = (z2 - z0) * dyr;
						xl = x0;
						zl = z0;
						xr = x0;
						zr = z0;
						ystart = y0;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = dzdyl; dzdyl = dzdyr; dzdyr = temp;
							
							temp = xl; xl = xr; xr = temp;
							temp = zl; zl = zr; zr = temp;
							
							temp = z1; z1 = z2; z2 = temp;
							
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;
							
							side = 1;
						}
						for (yi = ystart; yi <= yend; yi +=1)
						{
							xstart = xl; xend = xr;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dz = (zr - zl) / dx;
							} else
							{
								dz = (zr - zl);
							}
							for (xi = xstart; xi < xend; xi +=1)
							{
								bgColor = target.getPixel32 (xi, yi);
								bga = bgColor >> 24 & 0xFF ;
								oldZ=buffer.getPixel (xi, yi);
								if (bga < 0xFF || zi < oldZ)
								{
									//color = ((alpha*intAlpha+ invAlpha*bga) << 24 | (alpha*r + invAlpha*(bgColor >> 16 & 0xFF)) << 16 | (alpha*g + invAlpha*(bgColor >> 8 & 0xFF)) << 8  | (alpha*b + invAlpha*(bgColor & 0xFF)) );
									target.setPixel32 (xi, yi, (int(alpha * intAlpha + invAlpha * bga) << 24 | int(alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 | int(alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) << 8 | int(alpha * b + invAlpha * (bgColor & 0xFF))));
								}
								zi += dz;
							}
							xl += dxdyl; zl += dzdyl;
							xr += dxdyr; zr += dzdyr;
							if (yi == ys)
							{
								if (side == 0)
								{
									dyl = 1 / (y2 - y1);
									dxdyl = (x2 - x1) * dyl; dzdyl = (z2 - z1) * dyl;
									xl = x1+dxdyl; zl = z1+dzdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr; dzdyr = (z1 - z2) * dyr;
									xr = x2+dxdyr; zr = z2+dzdyr;
								}
							}
						}
				}
				else
				{
					if (type == 1)
					{
						dy = 1 / (y2 - y0);
						dxdyl = (x2 - x0) * dy; dxdyr = (x2 - x1) * dy;
						dzdyl = (z2 - z0) * dy; dzdyr = (z2 - z1) * dy;

						xl = x0; zl = z0;
						xr = x1; zr = z1;
						ystart = y0;
					} 
					else
					{
						dy = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dy; dxdyr = (x2 - x0) * dy;
						dzdyl = (z1 - z0) * dy; dzdyr = (z2 - z0) * dy;

						xl = x0; zl = z0;
						xr = x0; zr = z0;
						ystart = y0;
						
					}
					for (yi = ystart; yi <= yend; yi +=1)
					{
							xstart = xl; xend = xr;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dz = (zr - zl) / dx;
							} else
							{
								dz = (zr - zl);
							}
							for (xi = xstart; xi < xend; xi +=1)
							{
								bgColor = target.getPixel32 (xi, yi);
								bga = bgColor >> 24 & 0xFF ;
								oldZ=buffer.getPixel (xi, yi);
								if (bga < 0xFF || zi < oldZ)
								{
									target.setPixel32 (xi, yi, (int(alpha * intAlpha + invAlpha * bga) << 24 | int(alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) << 16 | int(alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) << 8 | int(alpha * b + invAlpha * (bgColor & 0xFF))));
								}
								zi += dz;
							}
							xl += dxdyl; zl += dzdyl;
							xr += dxdyr; zr += dzdyr;
					}
				}
			}
		}
	}
}

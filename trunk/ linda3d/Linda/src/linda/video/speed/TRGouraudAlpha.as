package linda.video.speed
{
	import __AS3__.vec.Vector;
	
	import linda.math.Vertex4D;
	
	internal final class TRGouraudAlpha extends TriangleRenderer
	{
		//背景颜色
		private var bga : int;
		private var bgColor : uint;
		
		//r,g,b
		private var drdyl : Number;
		private var drdyr : Number;
		private var dgdyl : Number;
		private var dgdyr : Number;
		private var dbdyl : Number;
		private var dbdyr : Number;

		private var r0 : int;
		private var g0 : int;
		private var b0 : int;
		private var r1 : int;
		private var g1 : int;
		private var b1 : int;
		private var r2 : int;
		private var g2 : int;
		private var b2 : int;
		
		private var ri : Number;
		private var bi : Number;
		private var gi : Number;

		private var rl : Number;
		private var gl : Number;
		private var bl : Number;
		private var rr : Number;
		private var gr : Number;
		private var br : Number;

		private var dr : Number;
		private var dg : Number;
		private var db : Number;
		
		override public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var temp1 : Vertex4D;
			var temp : Number;
			var side : int;
		 	var ys : int;
		 	var tri_type : int;
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
				
				tri_type = 0;
				if (vt0.iy == vt1.iy)
				{
					tri_type = 1;
					if (vt1.x < vt0.x)
					{
						temp1 = vt0; vt0 = vt1; vt1 = temp1;
					}
				} else if (vt1.iy == vt2.iy)
				{
					tri_type = 2;
					if (vt2.x < vt1.x)
					{
						temp1 = vt1; vt1 = vt2; vt2 = temp1;
					}
				}
				side = 0;
				
				
				x0 = vt0.x ; y0 = vt0.y ; z0 = vt0.w;
				x1 = vt1.x ; y1 = vt1.y ; z1 = vt1.w;
				x2 = vt2.x ; y2 = vt2.y ; z2 = vt2.w;
				if (((x0 == x1) && (x1 == x2)) || ((y0 == y1) && (y1 == y2))) continue;
				
				r0 = vt0.r; g0 = vt0.g; b0 = vt0.b;
				r1 = vt1.r; g1 = vt1.g; b1 = vt1.b;
				r2 = vt2.r; g2 = vt2.g; b2 = vt2.b;

				ys = y1;
				yend = y2;
				ystart = y0;
				if(tri_type==0)
				{
					
						dyl = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dyl;
						dzdyl = (z1 - z0) * dyl;
						drdyl = (r1 - r0) * dyl;
						dgdyl = (g1 - g0) * dyl;
						dbdyl = (b1 - b0) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						dzdyr = (z2 - z0) * dyr;
						drdyr = (r2 - r0) * dyr;
						dgdyr = (g2 - g0) * dyr;
						dbdyr = (b2 - b0) * dyr;
						xl = x0 ; xr = x0 ;
						zl = z0;
						rl = r0; gl = g0; bl = b0;
						rr = r0; gr = g0; br = b0;
						zr = z0;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = drdyl; drdyl = drdyr; drdyr = temp;
							temp = dgdyl; dgdyl = dgdyr; dgdyr = temp;
							temp = dbdyl; dbdyl = dbdyr; dbdyr = temp;
							temp = dzdyl; dzdyl = dzdyr; dzdyr = temp;
							temp = xl; xl = xr; xr = temp;
							temp = zl; zl = zr; zr = temp;
							
							temp = z1; z1 = z2; z2 = temp;
							
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;
							r1 ^= r2; r2 ^= r1; r1 ^= r2;
							g1 ^= g2; g2 ^= g1; g1 ^= g2;
							b1 ^= b2; b2 ^= b1; b1 ^= b2;
							
							side = 1;
						}
					
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl;
							xend = xr;
							ri = rl; gi = gl; bi = bl;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dx = 1 / dx;
								dr = (rr - rl) * dx;
								dg = (gr - gl) * dx;
								db = (br - bl) * dx;
								dz = (zr - zl) * dx;
							} else
							{
								dr = (rr - rl);
								dg = (gr - gl);
								db = (br - bl);
								dz = (zr - zl);
							}
							for (xi = xstart; xi < xend; xi ++)
							{
								oldZ=buffer.getPixel (xi, yi);
								if (zi < oldZ)
								{
									bgColor = target.getPixel (xi, yi);
									target.setPixel (xi, yi,(int(alpha * ri + invAlpha * (bgColor >> 16 & 0xFF)) << 16 | int(alpha * gi + invAlpha * (bgColor >> 8 & 0xFF)) << 8 | int(alpha * bi + invAlpha * (bgColor & 0xFF))));
								}
								zi += dz;
								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
							zl += dzdyl;
							xr += dxdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
							zr += dzdyr;
							if (yi == ys)
							{
								if (side == 0)
								{
									dyl = 1 / (y2 - y1);
									dxdyl = (x2 - x1) * dyl;
									dzdyl = (z2 - z1) * dyl;
									drdyl = (r2 - r1) * dyl;
									dgdyl = (g2 - g1) * dyl;
									dbdyl = (b2 - b1) * dyl;
									xl = x1+dxdyl;
									zl = z1+dzdyl;
									rl = r1+drdyl;
									gl = g1+dgdyl;
									bl = b1+dbdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr;
									dzdyr = (z1 - z2) * dyr;
									drdyr = (r1 - r2) * dyr;
									dgdyr = (g1 - g2) * dyr;
									dbdyr = (b1 - b2) * dyr;
									xr = x2+dxdyr;
									zr = z2+dzdyr;
									rr = r2+drdyr;
									gr = g2+dgdyr;
									br = b2+dbdyr;
								}
							}
					}
				}
				else
				{
					if (tri_type == 1)
					{
						dy = 1 / (y2 - y0);
						dxdyl = (x2 - x0) * dy;
						dzdyl = (z2 - z0) * dy;
						drdyl = (r2 - r0) * dy;
						dgdyl = (g2 - g0) * dy;
						dbdyl = (b2 - b0) * dy;
						dxdyr = (x2 - x1) * dy;
						dzdyr = (z2 - z1) * dy;
						drdyr = (r2 - r1) * dy;
						dgdyr = (g2 - g1) * dy;
						dbdyr = (b2 - b1) * dy;

						xl = x0; xr = x1; zl = z0; zr = z1;
						rl = r0; gl = g0; bl = b0;
						rr = r1; gr = g1; br = b1;
					} 
					else
					{
						dy = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dy;
						dzdyl = (z1 - z0) * dy;
						drdyl = (r1 - r0) * dy;
						dgdyl = (g1 - g0) * dy;
						dbdyl = (b1 - b0) * dy;
						dxdyr = (x2 - x0) * dy;
						dzdyr = (z2 - z0) * dy;
						drdyr = (r2 - r0) * dy;
						dgdyr = (g2 - g0) * dy;
						dbdyr = (b2 - b0) * dy;

						xl = x0; xr = x0; zl = z0; zr = z0;
						rl = r0; gl = g0; bl = b0;
						rr = r0; gr = g0; br = b0;
					}
					
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl;
							xend = xr;
							zi = zl;
							ri = rl; gi = gl; bi = bl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dx = 1 / dx;
								dz = (zr - zl) * dx;
								dr = (rr - rl) * dx;
								dg = (gr - gl) * dx;
								db = (br - bl) * dx;
							} else
							{
								dz = (zr - zl);
								dr = (rr - rl);
								dg = (gr - gl);
								db = (br - bl);
							}
							for (xi = xstart; xi < xend; xi ++)
							{
								oldZ=buffer.getPixel (xi, yi);
								if (zi < oldZ)
								{
									bgColor = target.getPixel (xi, yi);
									target.setPixel (xi, yi,(int(alpha * ri + invAlpha * (bgColor >> 16 & 0xFF)) << 16 | int(alpha * gi + invAlpha * (bgColor >> 8 & 0xFF)) << 8 | int(alpha * bi + invAlpha * (bgColor & 0xFF))));
								}
								zi += dz;
								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
							zl += dzdyl;
							xr += dxdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
							zr += dzdyr;
						}
				} 
			}
		}
	}
}

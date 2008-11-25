package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	
	public class TRGouraudAlpha extends TriangleRenderer implements ITriangleRenderer
	{
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var color:uint;
			var bga : int;
			var bgColor : uint;

			var xstart : int,xend : int;
			var ystart : int,yend : int;
			var dyr : Number,dyl : Number;
			var dxdyl : Number,dxdyr : Number;
			var dzdyl : Number,dzdyr : Number;
			var x0 : int,x1 : int,x2 : int; 
			var y0 : int,y1 : int,y2 : int;
			var z0 : Number,z1 : Number,z2 : Number;
			var xi : int,yi : int; 
			var zi : Number;
			var xl : Number,xr : Number;
			var zl : Number,zr : Number;
			var dx : Number,dy : Number,dz : Number;
			
			var drdyl : Number,drdyr : Number;
			var dgdyl : Number,dgdyr : Number;
			var dbdyl : Number,dbdyr : Number;

			var r0 : int,g0 : int,b0 : int;
			var r1 : int,g1 : int,b1 : int;
			var r2 : int,g2 : int,b2 : int;
		
			var ri : Number,bi : Number,gi : Number;

			var rl : Number,gl : Number,bl : Number;
			var rr : Number,gr : Number,br : Number;

			var dr : Number,dg : Number,db : Number;
			
			var temp1 : Vertex4D;
			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			var temp : Number;
			var side : int;
		 	var ys : int;
		 	var type : int;
            var oldZ:int;
			var ii:int;

			for (var i : int = 0; i < indexCount; i += 3)
			{
				ii=indexList [i];
				vt0 = vertices [ii];
				ii=indexList [int(i+ 1)];
				vt1 = vertices [ii];
				ii=indexList [int(i+ 2)];
				vt2 = vertices [ii];

				if (vt1.y < vt0.y)
				{
					temp1 = vt0; vt0 = vt1; vt1 = temp1;
				}
				if (vt2.y < vt0.y)
				{
					temp1 = vt0; vt0 = vt2; vt2 = temp1;
				}
				if (vt2.y < vt1.y)
				{
					temp1 = vt1; vt1 = vt2; vt2 = temp1;
				}
				
				type = 0;
				if (vt0.y == vt1.y)
				{
					type = 1;
					if (vt1.x < vt0.x)
					{
						temp1 = vt0; vt0 = vt1; vt1 = temp1;
					}
				} else if (vt1.y == vt2.y)
				{
					type = 2;
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
				if(type==0)
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
					
						for (yi = ystart; yi <= yend; yi +=1)
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
							for (xi = xstart; xi < xend; xi +=1)
							{
								oldZ=buffer.getPixel (xi, yi);
								if (zi < oldZ)
								{
									bgColor = target.getPixel (xi, yi);
									color=((alpha * ri + invAlpha * (bgColor >> 16 & 0xFF)) << 16 | 
									       (alpha * gi + invAlpha * (bgColor >> 8 & 0xFF))  << 8  |
									       (alpha * bi + invAlpha * (bgColor & 0xFF)));
									target.setPixel (xi, yi,color);
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
					if (type == 1)
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
					
						for (yi = ystart; yi <= yend; yi +=1)
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
							for (xi = xstart; xi < xend; xi +=1)
							{
								oldZ=buffer.getPixel (xi, yi);
								if (zi < oldZ)
								{
									bgColor = target.getPixel (xi, yi);
									color=((alpha * ri + invAlpha * (bgColor >> 16 & 0xFF)) << 16 | 
									       (alpha * gi + invAlpha * (bgColor >> 8 & 0xFF))  << 8  |
									       (alpha * bi + invAlpha * (bgColor & 0xFF)));
									target.setPixel (xi, yi,color);
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

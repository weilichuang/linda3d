﻿package linda.video.pixel;

	import flash.Vector;
	
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	import linda.video.TriangleRenderer;
	class TRGouraudAlpha extends TriangleRenderer,implements ITriangleRenderer
	{
		public function new()
		{
			super();
		}
		public function drawIndexedTriangleList (vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
		{
			var bga : Int;
			var bgColor : UInt;
            var xstart : Int,xend : Int;
			var ystart : Int,yend : Int;
			var dyr : Float,dyl : Float;
			var dxdyl : Float,dxdyr : Float;
			var dzdyl : Float,dzdyr : Float;
			var x0 : Int,x1 : Int,x2 : Int; 
			var y0 : Int,y1 : Int,y2 : Int;
			var z0 : Float,z1 : Float,z2 : Float;

			var zi : Float;
			var xl : Float,xr : Float;
			var zl : Float,zr : Float;
			var dx : Float,dy : Float,dz : Float;
			
			var drdyl : Float,drdyr : Float;
			var dgdyl : Float,dgdyr : Float;
			var dbdyl : Float,dbdyr : Float;

			var r0 : Int,g0 : Int,b0 : Int;
			var r1 : Int,g1 : Int,b1 : Int;
			var r2 : Int,g2 : Int,b2 : Int;
		
			var ri : Float,bi : Float,gi : Float;

			var rl : Float,gl : Float,bl : Float;
			var rr : Float,gr : Float,br : Float;

			var dr : Float,dg : Float,db : Float;

			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			var temp : Float;
			var side : Int;
		 	var ys : Int;
		 	var type : Int;
            var pos:Int;
			var tmp:Vertex4D;
			var i:Int = 0;
			while( i < indexCount)
			{
				vt0 = vertices[indexList[i]];
				vt1 = vertices[indexList[i+1]];
				vt2 = vertices[indexList[i + 2]];
				
				i += 3;
				
				if (vt1.iy < vt0.iy)
				{
					tmp = vt1; vt1 = vt0; vt0 = tmp;
				}
				if (vt2.iy < vt0.iy)
				{
					tmp = vt2; vt2 = vt0; vt0 = tmp;
				}
				if (vt2.iy < vt1.iy)
				{
					tmp = vt2; vt2 = vt1; vt1 = tmp;
				}
				if(vt0.iy == vt1.iy)
				{
					type = 1;
					if(vt1.x < vt0.x)
					{
						tmp = vt1; vt1 = vt0; vt0 = tmp;
					}
				}else if( vt1.iy == vt2.iy)
				{
					type = 2;
					if(vt2.x < vt1.x)
					{
						tmp = vt1; vt1 = vt2; vt2 = tmp;
					}
				}else
				{
					type = 0;
				}
				
				x0 = Std.int(vt0.x + 0.5);
				x1 = Std.int(vt1.x + 0.5);
				x2 = Std.int(vt2.x + 0.5);
				
				y0 = vt0.iy ;
				y1 = vt1.iy ;
				y2 = vt2.iy ;
				
				if ((y0 == y1 && y1 == y2) || (x0 == x1 && x1 == x2)) continue;
				
				z0 = vt0.z;
				z1 = vt1.z;
				z2 = vt2.z;

				side = 0;

				r0 = vt0.r; g0 = vt0.g; b0 = vt0.b;
				r1 = vt1.r; g1 = vt1.g; b1 = vt1.b;
				r2 = vt2.r; g2 = vt2.g; b2 = vt2.b;

				ystart = y0;
				ys     = y1;
                yend   = y2;
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
					
						for (yi in ystart...yend)
						{
							ri = rl; gi = gl; bi = bl;
							zi = zl;
							xstart = Std.int(xl);
							xend = Std.int(xr);
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
							for (xi in xstart...xend)
							{
								pos=xi+yi*width;
								if (zi > buffer[pos])
								{
									bgColor = target[pos];
									target[pos] = (
		                  					       ((alpha * Std.int(ri) + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  					       ((alpha * Std.int(gi) + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  					       ((alpha * Std.int(bi) + invAlpha * (bgColor & 0xFF)) >> 8)
						                          );
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
					
						for (yi in ystart...yend)
						{
							zi = zl;
							ri = rl; gi = gl; bi = bl;
							xstart = Std.int(xl);
							xend = Std.int(xr);
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
							for (xi in xstart...xend)
							{
								pos=xi+yi*width;
								if (zi > buffer[pos])
								{
									bgColor = target[pos];
									
									target[pos] = (
		                  					       ((alpha * Std.int(ri) + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  					       ((alpha * Std.int(gi) + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  					       ((alpha * Std.int(bi) + invAlpha * (bgColor & 0xFF)) >> 8)
						                          );
						            			  
									
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


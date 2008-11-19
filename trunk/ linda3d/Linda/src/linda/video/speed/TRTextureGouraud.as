package linda.video.speed
{
	import __AS3__.vec.Vector;
	
	import linda.material.ITexture;
	import linda.math.Vertex4D;
	
	import flash.display.BitmapData;
	internal final class TRTextureGouraud extends TriangleRenderer
	{
		//texture
		private var textel : uint;
		
		private var tw:Number;
		private var th:Number;

		private var bitmapData:BitmapData;
		//r,g,b
		private var drdyl : Number;
		private var drdyr : Number;
		private var dgdyl : Number;
		private var dgdyr : Number;
		private var dbdyl : Number;
		private var dbdyr : Number;
		//u,v
		private var dudyl : Number;
		private var dudyr : Number;
		private var dvdyl : Number;
		private var dvdyr : Number;

		private var r0 : int;
		private var g0 : int;
		private var b0 : int;
		private var r1 : int;
		private var g1 : int;
		private var b1 : int;
		private var r2 : int;
		private var g2 : int;
		private var b2 : int;
		private var u0 : Number;
		private var v0 : Number;
		private var u1 : Number;
		private var v1 : Number; 
		private var u2 : Number; 
		private var v2 : Number;

		private var ri : Number;
		private var bi : Number;
		private var gi : Number;
		private var ui : Number;
		private var vi : Number;

		private var rl : Number;
		private var gl : Number;
		private var bl : Number;
		private var rr : Number;
		private var gr : Number;
		private var br : Number;
		private var ul : Number;
		private var vl : Number;
		private var ur : Number;
		private var vr : Number;
		
		private var dr : Number;
		private var dg : Number;
		private var db : Number;
		private var du : Number;
		private var dv : Number;
		override public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int): void
		{
			var temp1 : Vertex4D;
			var temp : Number;
			var side : int;
		 	var ys : int;
		 	var type : int;
            var oldZ:int;
            var texture:ITexture=material.getTexture();
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
				side = 0;
				
				x0 = vt0.x ; y0 = vt0.y ; z0 = vt0.w;
				x1 = vt1.x ; y1 = vt1.y ; z1 = vt1.w;
				x2 = vt2.x ; y2 = vt2.y ; z2 = vt2.w;
				if (((x0 == x1) && (x1 == x2)) || ((y0 == y1) && (y1 == y2))) continue;
				r0 = vt0.r; g0 = vt0.g; b0 = vt0.b;
				r1 = vt1.r; g1 = vt1.g; b1 = vt1.b;
                r2 = vt2.r; g2 = vt2.g; b2 = vt2.b;
                
                //mipmap
                var level:int = int((vt0.w+vt1.w+vt2.w)*0.333/mipMapDistance);
                bitmapData=texture.getBitmapData(level);
	            tw=bitmapData.width;
	            th=bitmapData.height; 
	            
	            perspectiveCorrect = (vt0.w < perspectiveDistance && vt1.w < perspectiveDistance && vt2.w < perspectiveDistance);

				if(perspectiveCorrect)
	            {
				     u0 = vt0.u * tw / z0; v0 = vt0.v * th / z0;			
				     u1 = vt1.u * tw / z1; v1 = vt1.v * th / z1;
				     u2 = vt2.u * tw / z2; v2 = vt2.v * th / z2;
	            }else
	            {
	            	 u0 = vt0.u * tw; v0 = vt0.v * th;			
				     u1 = vt1.u * tw; v1 = vt1.v * th;
				     u2 = vt2.u * tw; v2 = vt2.v * th;
	            }
				
				ys = y1;
				yend = y2;
				ystart = y0;
				if(type==0)
				{
					
					
						dyl = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dyl;
						dzdyl = (z1 - z0) * dyl;
						dudyl = (u1 - u0) * dyl;
						dvdyl = (v1 - v0) * dyl;
						drdyl = (r1 - r0) * dyl;
						dgdyl = (g1 - g0) * dyl;
						dbdyl = (b1 - b0) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						dzdyr = (z2 - z0) * dyr;
						dudyr = (u2 - u0) * dyr;
						dvdyr = (v2 - v0) * dyr;
						drdyr = (r2 - r0) * dyr;
						dgdyr = (g2 - g0) * dyr;
						dbdyr = (b2 - b0) * dyr;
						xl = x0 ; xr = x0 ;
						zl = z0;
						ul = u0 ; vl = v0 ;
						rl = r0; gl = g0; bl = b0;
						ur = u0 ; vr = v0 ;
						rr = r0; gr = g0; br = b0;
						zr = z0;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = dudyl; dudyl = dudyr; dudyr = temp;
							temp = dvdyl; dvdyl = dvdyr; dvdyr = temp;
							temp = drdyl; drdyl = drdyr; drdyr = temp;
							temp = dgdyl; dgdyl = dgdyr; dgdyr = temp;
							temp = dbdyl; dbdyl = dbdyr; dbdyr = temp;
							temp = dzdyl; dzdyl = dzdyr; dzdyr = temp;
							
							temp = xl; xl = xr; xr = temp;
							temp = ul; ul = ur; ur = temp;
							temp = vl; vl = vr; vr = temp;
							temp = zl; zl = zr; zr = temp;

							temp = u1; u1 = u2; u2 = temp;
							temp = v1; v1 = v2; v2 = temp;

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
							ui = ul; vi = vl;
							ri = rl; gi = gl; bi = bl;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dx = 1 / dx;
								du = (ur - ul) * dx;
								dv = (vr - vl) * dx;
								dr = (rr - rl) * dx;
								dg = (gr - gl) * dx;
								db = (br - bl) * dx;
								dz = (zr - zl) * dx;
							} else
							{
								du = (ur - ul);
								dv = (vr - vl);
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
									if(perspectiveCorrect)
									{
										
										textel = bitmapData.getPixel (int(ui * zi), int(vi * zi));
									}else
									{
										textel = bitmapData.getPixel (int(ui), int(vi));
									}
									target.setPixel (xi, yi,(
									(((textel >> 16 & 0xFF) * ri) >> 8) << 16 |
									(((textel >> 8 & 0xFF) * gi) >> 8) << 8 |
									(((textel & 0xFF) * bi) >> 8)));
									buffer.setPixel (xi, yi, int(zi));
								}
								ui += du; vi += dv; zi += dz;
								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl; ul += dudyl; vl += dvdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
							zl += dzdyl;
							xr += dxdyr; ur += dudyr; vr += dvdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
							zr += dzdyr;
							if (yi == ys)
							{
								if (side == 0)
								{
									dyl = 1 / (y2 - y1);
									dxdyl = (x2 - x1) * dyl;
									dzdyl = (z2 - z1) * dyl;
									dudyl = (u2 - u1) * dyl;
									dvdyl = (v2 - v1) * dyl;
									drdyl = (r2 - r1) * dyl;
									dgdyl = (g2 - g1) * dyl;
									dbdyl = (b2 - b1) * dyl;
									xl = x1+dxdyl;
									zl = z1+dzdyl;
									ul = u1+dudyl; 
									vl = v1+dvdyl;
									rl = r1+drdyl; 
									gl = g1+dgdyl; 
									bl = b1+dbdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr;
									dzdyr = (z1 - z2) * dyr;
									dudyr = (u1 - u2) * dyr;
									dvdyr = (v1 - v2) * dyr;
									drdyr = (r1 - r2) * dyr;
									dgdyr = (g1 - g2) * dyr;
									dbdyr = (b1 - b2) * dyr;
									xr = x2+dxdyr;
									zr = z2+dzdyr;
									ur = u2+dudyr;
								    vr = v2+dvdyr;
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
						dudyl = (u2 - u0) * dy;
						dvdyl = (v2 - v0) * dy;
						drdyl = (r2 - r0) * dy;
						dgdyl = (g2 - g0) * dy;
						dbdyl = (b2 - b0) * dy;
						dxdyr = (x2 - x1) * dy;
						dzdyr = (z2 - z1) * dy;
						dudyr = (u2 - u1) * dy;
						dvdyr = (v2 - v1) * dy;
						drdyr = (r2 - r1) * dy;
						dgdyr = (g2 - g1) * dy;
						dbdyr = (b2 - b1) * dy;
						
							xl = x0; xr = x1; zl = z0; zr = z1;
							ul = u0; vl = v0;
							ur = u1; vr = v1;
							rl = r0; gl = g0; bl = b0;
							rr = r1; gr = g1; br = b1;
					} 
					else
					{
						dy = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dy;
						dzdyl = (z1 - z0) * dy;
						dxdyr = (x2 - x0) * dy;
						dzdyr = (z2 - z0) * dy;
						dudyl = (u1 - u0) * dy;
						dvdyl = (v1 - v0) * dy;
						drdyl = (r1 - r0) * dy;
						dgdyl = (g1 - g0) * dy;
						dbdyl = (b1 - b0) * dy;
						drdyr = (r2 - r0) * dy;
						dgdyr = (g2 - g0) * dy;
						dbdyr = (b2 - b0) * dy;
						dudyr = (u2 - u0) * dy;
						dvdyr = (v2 - v0) * dy;
						
						xl = x0; xr = x0; zl = z0; zr = z0;
						ul = u0; vl = v0;
						rl = r0; gl = g0; bl = b0;
						ur = u0; vr = v0;
						rr = r0; gr = g0; br = b0;
					}
					
						for (yi = ystart; yi <= yend; yi +=1)
						{
							xstart = xl;
							xend = xr;
							ui = ul; vi = vl;
							zi = zl;
							ri = rl; gi = gl; bi = bl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dx = 1 / dx;
								dz = (zr - zl) * dx;
								du = (ur - ul) * dx;
								dv = (vr - vl) * dx;
								dr = (rr - rl) * dx;
								dg = (gr - gl) * dx;
								db = (br - bl) * dx;
							} else
							{
								dz = (zr - zl);
								du = (ur - ul);
								dv = (vr - vl);
								dr = (rr - rl);
								dg = (gr - gl);
								db = (br - bl);
							}
							for (xi = xstart; xi < xend; xi +=1)
							{
								oldZ=buffer.getPixel (xi, yi);
								if (zi < oldZ)
								{
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (int(ui * zi), int(vi * zi));
									}else
									{
										textel = bitmapData.getPixel (int(ui), int(vi));
									}
									target.setPixel (xi, yi,(
									(((textel >> 16 & 0xFF) * ri) >> 8) << 16 |
									(((textel >> 8 & 0xFF) * gi) >> 8) << 8 |
									(((textel & 0xFF) * bi) >> 8)));
									buffer.setPixel (xi, yi, int(zi));
								}
								ui += du; vi += dv; zi += dz;
								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl; ul += dudyl; vl += dvdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
							zl += dzdyl;
							xr += dxdyr; ur += dudyr; vr += dvdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
							zr += dzdyr;
						}
				}
			}
		}
	}
}

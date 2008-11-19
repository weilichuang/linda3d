package linda.video.pixel32
{
	import __AS3__.vec.Vector;
	
	import linda.material.ITexture;
	import linda.math.Vertex4D;
	
	import flash.display.*;
	internal final class TRTextureFlatAlpha extends TriangleRenderer
	{
		override public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
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
				if (((vt0.y < minY) && (vt1.y < minY) && (vt2.y < minY)) ||
				((vt0.y > maxY) && (vt1.y > maxY) && (vt2.y > maxY)) ||
				((vt0.x < minX) && (vt1.x < minX) && (vt2.x < minX)) ||
				((vt0.x > maxX) && (vt1.x > maxX) && (vt2.x > maxX)))
				continue ;

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
				
				side = 0;
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
				if(type==0)
				{
					yend = y2;
					if (yend > maxY) yend = maxY;
					if (y1 < minY)
					{
						dyl = 1 / (y2 - y1);
						dxdyl = (x2 - x1 ) * dyl;
						dzdyl = (z2 - z1) * dyl;
						dudyl = (u2 - u1) * dyl;
						dvdyl = (v2 - v1) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0 ) * dyr;
						dzdyr = (z2 - z0) * dyr;
						dudyr = (u2 - u0) * dyr;
						dvdyr = (v2 - v0) * dyr;
						dyr = (minY - y0);
						dyl = (minY - y1);
						xl = dxdyl * dyl + x1;
						zl = dzdyl * dyl + z1;
						ul = dudyl * dyl + u1;
						vl = dvdyl * dyl + v1;
						xr = dxdyr * dyr + x0;
						zr = dzdyr * dyr + z0;
						ur = dudyr * dyr + u0;
						vr = dvdyr * dyr + v0;
						ystart = minY;
						if (dxdyr > dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = dudyl; dudyl = dudyr; dudyr = temp;
							temp = dvdyl; dvdyl = dvdyr; dvdyr = temp;
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
							
							side = 1 ;
						}
					} 
					else if (y0 < minY)
					{
						dyl = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dyl;
						dzdyl = (z1 - z0) * dyl;
						dudyl = (u1 - u0) * dyl;
						dvdyl = (v1 - v0) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						dzdyr = (z2 - z0) * dyr;
						dudyr = (u2 - u0) * dyr;
						dvdyr = (v2 - v0) * dyr;
						dy = (minY - y0);
						xl = dxdyl * dy + x0 ;
						zl = dzdyl * dy + z0;
						ul = dudyl * dy + u0 ;
						vl = dvdyl * dy + v0 ;
						xr = dxdyr * dy + x0 ;
						zr = dzdyr * dy + z0;
						ur = dudyr * dy + u0 ;
						vr = dvdyr * dy + v0 ;
						ystart = minY;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = dudyl; dudyl = dudyr; dudyr = temp;
							temp = dvdyl; dvdyl = dvdyr; dvdyr = temp;
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
							
							side = 1 ;
						}
					} else
					{
						dyl = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dyl;
						dzdyl = (z1 - z0) * dyl;
						dudyl = (u1 - u0) * dyl;
						dvdyl = (v1 - v0) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						dzdyr = (z2 - z0) * dyr;
						dudyr = (u2 - u0) * dyr;
						dvdyr = (v2 - v0) * dyr;
						xl = x0; zl = z0;
						xr = x0; zr = z0;
						ul = u0 ; vl = v0 ;
						ur = u0 ; vr = v0 ;
						ystart = y0;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = dudyl; dudyl = dudyr; dudyr = temp;
							temp = dvdyl; dvdyl = dvdyr; dvdyr = temp;
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
							
							side = 1 ;
						}
					}
					if ((x0 < minX) || (x0 > maxX) ||
					(x1 < minX) || (x1 > maxX) ||
					(x2 < minX) || (x2 > maxX))
					{
						for (yi = ystart; yi <= yend; yi +=1)
						{
							xstart = xl;
							xend = xr;
							ui = ul; vi = vl;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								du = (ur - ul) / dx;
								dv = (vr - vl) / dx;
								dz = (zr - zl) / dx;
							} 
							else
							{
								du = (ur - ul);
								dv = (vr - vl);
								dz = (zr - zl);
							}
							if (xstart < minX)
							{
								dx = minX - xstart;
								ui += dx * du;
								vi += dx * dv;
								zi += dx * dz;
								xstart = minX;
							}
							if (xend > maxX) xend = maxX;
							for (xi = xstart; xi < xend; xi +=1)
							{
								//background Color
								bgColor = target.getPixel32 (xi, yi);
								bga = bgColor >> 24 & 0xFF ;
								oldZ=buffer.getPixel (xi, yi);
								if (bga < 0xFF || zi < oldZ)
								{
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (int(ui * zi), int(vi * zi));
									}else
									{
										textel = bitmapData.getPixel (int(ui), int(vi));
									}
									target.setPixel32 (xi, yi,
									(int(alpha * intAlpha + invAlpha * bga) << 24 |
									((textel >> 16 & 0xFF) * alpha  + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
									((textel >> 8 & 0xFF) * alpha  + invAlpha * (bgColor >> 8 & 0xFF)) << 8 |
									((textel & 0xFF) * alpha  + invAlpha * (bgColor & 0xFF))));
								}
								ui += du;
								vi += dv;
								zi += dz;
							}
							xl += dxdyl;
							ul += dudyl;
							vl += dvdyl;
							zl += dzdyl;
							xr += dxdyr;
							ur += dudyr;
							vr += dvdyr;
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
									xl = x1+dxdyl;
									zl = z1+dzdyl;
									ul = u1+dudyl;
									vl = v1+dvdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr;
									dzdyr = (z1 - z2) * dyr;
									dudyr = (u1 - u2) * dyr;
									dvdyr = (v1 - v2) * dyr;
									xr = x2+dxdyr;
									zr = z2+dzdyr;
									ur = u2+dudyr;
									vr = v2+dvdyr;
								}
							}
						}
					} else
					{
						for (yi = ystart; yi <= yend; yi +=1)
						{
							xstart = xl;
							xend = xr;
							ui = ul;
							vi = vl;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dx = 1 / dx;
								du = (ur - ul) * dx;
								dv = (vr - vl) * dx;
								dz = (zr - zl) * dx;
							} else
							{
								du = (ur - ul);
								dv = (vr - vl);
								dz = (zr - zl);
							}
							for (xi = xstart; xi < xend; xi +=1)
							{
								//background Color
								bgColor = target.getPixel32 (xi, yi);
								bga = bgColor >> 24 & 0xFF ;
								oldZ=buffer.getPixel (xi, yi);
								if (bga < 0xFF || zi < oldZ)
								{
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (int(ui * zi), int(vi * zi));
									}else
									{
										textel = bitmapData.getPixel (int(ui), int(vi));
									}
									target.setPixel32 (xi, yi,
									(int(alpha * intAlpha + invAlpha * bga) << 24 |
									((textel >> 16 & 0xFF) * alpha  + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
									((textel >> 8 & 0xFF) * alpha  + invAlpha * (bgColor >> 8 & 0xFF)) << 8 |
									((textel & 0xFF) * alpha  + invAlpha * (bgColor & 0xFF))));
								}
								ui += du;
								vi += dv;
								zi += dz;
							}
							xl += dxdyl;
							ul += dudyl;
							vl += dvdyl;
							zl += dzdyl;
							xr += dxdyr;
							ur += dudyr;
							vr += dvdyr;
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
									xl = x1+dxdyl;
									zl = z1+dzdyl;
									ul = u1+dudyl;
									vl = v1+dvdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr;
									dzdyr = (z1 - z2) * dyr;
									dudyr = (u1 - u2) * dyr;
									dvdyr = (v1 - v2) * dyr;
									xr = x2+dxdyr;
									zr = z2+dzdyr;
									ur = u2+dudyr;
									vr = v2+dvdyr;
								}
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
						dxdyr = (x2 - x1) * dy;
						dzdyr = (z2 - z1) * dy;
						dudyr = (u2 - u1) * dy;
						dvdyr = (v2 - v1) * dy;
						if (y0 < minY)
						{
							dy = (minY - y0);
							xl = dxdyl * dy + x0;
							zl = dzdyl * dy + z0;
							ul = dudyl * dy + u0;
							vl = dvdyl * dy + v0;
							xr = dxdyr * dy + x1;
							zr = dzdyr * dy + z1;
							ur = dudyr * dy + u1;
							vr = dvdyr * dy + v1;
							ystart = minY;
						} else
						{
							xl = x0; xr = x1;
							zl = z0; zr = z1;
							ul = u0; vl = v0;
							ur = u1; vr = v1;
							ystart = y0;
						}
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
						dudyr = (u2 - u0) * dy;
						dvdyr = (v2 - v0) * dy;
						if (y0 < minY)
						{
							dy = (minY - y0);
							xl = dxdyl * dy + x0;
							ul = dudyl * dy + u0;
							vl = dvdyl * dy + v0;
							zl = dzdyl * dy + z0;
							xr = dxdyr * dy + x0;
							zr = dzdyr * dy + z0;
							ur = dudyr * dy + u0;
							vr = dvdyr * dy + v0;
							ystart = minY;
						} else
						{
							xl = x0; xr = x0;
							zl = z0; zr = z0;
							ul = u0; vl = v0;
							ur = u0; vr = v0;
							ystart = y0;
						}
					}
					if ((yend = y2) > maxY) yend = maxY;
					if ((x0 < minX) || (x0 > maxX) ||
					(x1 < minX) || (x1 > maxX) ||
					(x2 < minX) || (x2 > maxX))
					{
						for (yi = ystart; yi <= yend; yi +=1)
						{
							xstart = xl;
							xend = xr;
							ui = ul; vi = vl;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dx = 1 / dx;
								dz = (zr - zl) * dx;
								du = (ur - ul) * dx;
								dv = (vr - vl) * dx;
							} else
							{
								du = (ur - ul);
								dv = (vr - vl);
								dz = (zr - zl);
							}
							if (xstart < minX)
							{
								dx = minX - xstart;
								ui += dx * du;
								vi += dx * dv;
								zi += dx * dz;
								xstart = minX;
							}
							if (xend > maxX) xend = maxX;
							for (xi = xstart; xi < xend; xi +=1)
							{
								//background Color
								bgColor = target.getPixel32 (xi, yi);
								bga = bgColor >> 24 & 0xFF ;
                                oldZ=buffer.getPixel (xi, yi);
								if (bga < 0xFF || zi < oldZ)
								{
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (int(ui * zi), int(vi * zi));
									}else
									{
										textel = bitmapData.getPixel (int(ui), int(vi));
									}
									target.setPixel32 (xi, yi,
									(int(alpha * intAlpha + invAlpha * bga) << 24 |
									((textel >> 16 & 0xFF) * alpha  + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
									((textel >> 8 & 0xFF) * alpha  + invAlpha * (bgColor >> 8 & 0xFF)) << 8 |
									((textel & 0xFF) * alpha  + invAlpha * (bgColor & 0xFF))));
								}
								ui += du;
								vi += dv;
								zi += dz;
							}
							xl += dxdyl;
							ul += dudyl;
							vl += dvdyl;
							zl += dzdyl;
							xr += dxdyr;
							ur += dudyr;
							vr += dvdyr;
							zr += dzdyr;
						}
					} else
					{
						for (yi = ystart; yi <= yend; yi +=1)
						{
							xstart = xl;
							xend = xr;
							ui = ul;
							vi = vl;
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dx = 1 / dx;
								du = (ur - ul) * dx;
								dv = (vr - vl) * dx;
								dz = (zr - zl) * dx;
							} else
							{
								du = (ur - ul);
								dv = (vr - vl);
								dz = (zr - zl);
							}
							for (xi = xstart; xi < xend; xi +=1)
							{
								//background Color
								bgColor = target.getPixel32 (xi, yi);
								bga = bgColor >> 24 & 0xFF ;
								oldZ=buffer.getPixel (xi, yi);
								if (bga < 0xFF || zi < oldZ)
								{
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (int(ui * zi), int(vi * zi));
									}else
									{
										textel = bitmapData.getPixel (int(ui), int(vi));
									}
									target.setPixel32 (xi, yi,
									(int(alpha * intAlpha + invAlpha * bga) << 24 |
									((textel >> 16 & 0xFF) * alpha  + invAlpha * (bgColor >> 16 & 0xFF)) << 16 |
									((textel >> 8 & 0xFF) * alpha  + invAlpha * (bgColor >> 8 & 0xFF)) << 8 |
									((textel & 0xFF) * alpha  + invAlpha * (bgColor & 0xFF))));
								}
								ui += du;
								vi += dv;
								zi += dz;
							}
							xl += dxdyl;
							ul += dudyl;
							vl += dvdyl;
							zl += dzdyl;
							xr += dxdyr;
							ur += dudyr;
							vr += dvdyr;
							zr += dzdyr;
						}
					}
				}
			}
		}
	}
}

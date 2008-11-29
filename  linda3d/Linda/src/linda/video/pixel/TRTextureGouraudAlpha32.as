package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.material.ITexture;
	import linda.video.ITriangleRenderer;
	import linda.math.Vertex4D;
	import flash.display.BitmapData;
	public class TRTextureGouraudAlpha32 extends TriangleRenderer implements ITriangleRenderer
	{
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var bga : int;
			var bgColor : uint;

			var textel : uint;
		
			var tw:Number;
			var th:Number;

			var bitmapData:BitmapData;

			var drdyl : Number,drdyr : Number,dgdyl : Number;
			var dgdyr : Number,dbdyl : Number,dbdyr : Number;

			var dudyl : Number,dudyr : Number;
			var dvdyl : Number,dvdyr : Number;

			var r0 : int,g0 : int,b0 : int;
			var r1 : int,g1 : int,b1 : int;
			var r2 : int,g2 : int,b2 : int;
			var u0 : Number,v0 : Number;
			var u1 : Number,v1 : Number; 
			var u2 : Number,v2 : Number;

			var ri : Number,bi : Number,gi : Number;
			var ui : Number,vi : Number;

			var rl : Number,gl : Number,bl : Number;
			var rr : Number,gr : Number,br : Number;
			var ul : Number,vl : Number;
			var ur : Number,vr : Number;
		
			var dr : Number,dg : Number,db : Number;
			var du : Number,dv : Number;

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

			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			var temp : Number;
			var side : int;
		 	var ys : int;
		 	var type : int;
            var oldZ:Number;
            var pos:int;
            var texture:ITexture=material.getTexture();
			var n0:int;
		 	var n1:int;
		 	var n2:int;
		 	var tmp:int;
			for (var i : int = 0; i < indexCount; i += 3)
			{
				n0  = indexList[i];
				n1  = indexList[i+1];
				n2  = indexList[i+2];

				y0 = int(vertices[n0].y+0.5) ;
				y1 = int(vertices[n1].y+0.5) ;
				y2 = int(vertices[n2].y+0.5) ;
				
				if (y0 == y1 && y1 == y2) continue;
				if (y1 < y0)
				{
					tmp = y1; y1 = y0; y0 = tmp;
					tmp = n1; n1 = n0; n0 = tmp;
				}
				if (y2 < y0)
				{
					tmp = y2; y2 = y0; y0 = tmp;
					tmp = n2; n2 = n0; n0 = tmp;
				}
				if (y2 < y1)
				{
					tmp = y1; y1 = y2; y2 = tmp;
					tmp = n1; n1 = n2; n2 = tmp;
				}
				if(y0 == y1)
				{
					type = 1;
					if(vertices[n1].x < vertices[n0].x)
					{
						tmp = n1; n1 = n0; n0 = tmp;
					}
				}else if( y1 == y2)
				{
					type = 2;
					if(vertices[n2].x < vertices[n1].x)
					{
						tmp = n1; n1 = n2; n2 = tmp;
					}
				}else
				{
					type = 0;
				}

				vt0 = vertices[n0];
				vt1 = vertices[n1];
				vt2 = vertices[n2];
				
				x0 = int(vt0.x+0.5) ;
				x1 = int(vt1.x+0.5) ;
				x2 = int(vt2.x+0.5) ;
				
				if ((x0 == x1) && (x1 == x2)) continue;
				
				z0 = vt0.z;
				z1 = vt1.z;
				z2 = vt2.z;

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
				     u0 = vt0.u * tw * z0; v0 = vt0.v * th * z0;			
				     u1 = vt1.u * tw * z1; v1 = vt1.v * th * z1;
				     u2 = vt2.u * tw * z2; v2 = vt2.v * th * z2;
	            }else
	            {
	            	 u0 = vt0.u * tw; v0 = vt0.v * th;			
				     u1 = vt1.u * tw; v1 = vt1.v * th;
				     u2 = vt2.u * tw; v2 = vt2.v * th;
	            }
				side = 0;

				ystart = y0;
				ys     = y1;
                yend   = y2;
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
							ui = ul; vi = vl;
							ri = rl; gi = gl; bi = bl;
							zi = zl;
							dx = (xr - xl);
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
							for (xi = xl; xi < xr; xi +=1)
							{
								pos=xi+yi*height;
								bgColor = target[pos];
								bga = bgColor >> 24 & 0xFF ;
								if (bga < 0xFF || zi > buffer[pos])
								{
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (ui / zi, vi / zi);
									}else
									{
										textel = bitmapData.getPixel (ui, vi);
									}
									target[pos] = (((alpha * bga) >> 8)                                                                       << 24 |
		                  					       ((int(alpha * ri) + invAlpha * (bgColor >> 16 & 0xFF)) * (textel >> 16 & 0xFF) >> 16)  << 16 | 
						  					       ((int(alpha * gi) + invAlpha * (bgColor >> 8 & 0xFF))  * (textel >> 8 & 0xFF)  >> 16)  << 8  | 
						  					       ((int(alpha * bi) + invAlpha * (bgColor & 0xFF))       * (textel & 0xFF)       >> 16)
						                          );
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
							ui = ul; vi = vl;
							zi = zl;
							ri = rl; gi = gl; bi = bl;
							dx = (xr - xl);
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
							for (xi = xl; xi < xr; xi +=1)
							{
								pos=xi+yi*height;
								bgColor = target[pos];
								bga = bgColor >> 24 & 0xFF ;
								if (bga < 0xFF || zi > buffer[pos])
								{
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (ui / zi, vi / zi);
									}else
									{
										textel = bitmapData.getPixel (ui, vi);
									}
									target[pos] = (((alpha * bga) >> 8)                                                                       << 24 |
		                  					       ((int(alpha * ri) + invAlpha * (bgColor >> 16 & 0xFF)) * (textel >> 16 & 0xFF) >> 16)  << 16 | 
						  					       ((int(alpha * gi) + invAlpha * (bgColor >> 8 & 0xFF))  * (textel >> 8 & 0xFF)  >> 16)  << 8  | 
						  					       ((int(alpha * bi) + invAlpha * (bgColor & 0xFF))       * (textel & 0xFF)       >> 16)
						                          );
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

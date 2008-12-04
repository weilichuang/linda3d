package linda.video.pixel;

	import flash.Vector;
	import flash.display.BitmapData;
	
	import linda.material.Texture;
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	import linda.video.TriangleRenderer;
	class TRTextureGouraud extends TriangleRenderer,implements ITriangleRenderer
	{
		public function new()
		{
			super();
		}
		public function drawIndexedTriangleList (vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int): Void
		{
			//mipmap
            var level:Int = Std.int(distance / mipMapDistance);
			texVector = texture.getVector(level);
	        texWidth  = texture.getWidth(level);
			texHeight = texture.getHeight(level);
			var tw:Int = texWidth - 1;
			var th:Int = texHeight - 1;
			perspectiveCorrect = (distance < perspectiveDistance);
			
			
			var textel : UInt;

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
			
			var drdyl : Float,drdyr : Float,dgdyl : Float;
			var dgdyr : Float,dbdyl : Float,dbdyr : Float;

			var dudyl : Float,dudyr : Float;
			var dvdyl : Float,dvdyr : Float;

			var r0 : Int,g0 : Int,b0 : Int;
			var r1 : Int,g1 : Int,b1 : Int;
			var r2 : Int,g2 : Int,b2 : Int;
			var u0 : Float,v0 : Float;
			var u1 : Float,v1 : Float; 
			var u2 : Float,v2 : Float;

			var ri : Float,bi : Float,gi : Float;
			var ui : Float,vi : Float;

			var rl : Float,gl : Float,bl : Float;
			var rr : Float,gr : Float,br : Float;
			var ul : Float,vl : Float;
			var ur : Float,vr : Float;
		
			var dr : Float,dg : Float,db : Float;
			var du : Float,dv : Float;

			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			var temp : Float;
			var side : Int;
		 	var ys : Int;
		 	var type : Int;
            var pos:Int;
			var n0:Int;
		 	var n1:Int;
		 	var n2:Int;
		 	var tmp:Int;
			var i:Int = 0;
			while( i < indexCount)
			{
				n0  = indexList[i];
				n1  = indexList[i+1];
				n2  = indexList[i + 2];
				
				i += 3;

				y0 = Std.int(vertices[n0].y+0.5) ;
				y1 = Std.int(vertices[n1].y+0.5) ;
				y2 = Std.int(vertices[n2].y+0.5) ;
				
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
				
				x0 = Std.int(vt0.x+0.5) ;
				x1 = Std.int(vt1.x+0.5) ;
				x2 = Std.int(vt2.x+0.5) ;
				
				if ((x0 == x1) && (x1 == x2)) continue;
				
				z0 = vt0.z;
				z1 = vt1.z;
				z2 = vt2.z;
				
				r0 = vt0.r; g0 = vt0.g; b0 = vt0.b;
				r1 = vt1.r; g1 = vt1.g; b1 = vt1.b;
                r2 = vt2.r; g2 = vt2.g; b2 = vt2.b;
                
                side = 0;
				
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
						for (yi in ystart...yend)
						{
							ui = ul; vi = vl;
							ri = rl; gi = gl; bi = bl;
							zi = zl;
							xstart = Std.int(xl);
							xend = Std.int(xr);
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
							for (xi in xstart...xend)
							{
								pos=xi+yi*width;
								if (zi > buffer[pos])
								{
									if(perspectiveCorrect)
									{
										textel = texVector[Std.int(ui/zi) + Std.int(vi/zi) * texWidth];
									}else
									{
										textel = texVector[Std.int(ui) + Std.int(vi) * texWidth];
									}
									target[pos] = ((((textel >> 16 & 0xFF) * Std.int(ri)) >> 8) << 16 |
									               (((textel >> 8 & 0xFF) * Std.int(gi)) >> 8)  << 8  |
									               ((textel & 0xFF) * Std.int(bi)) >> 8);
									buffer[pos] = zi;
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
					for (yi in ystart...yend)
					{
							ui = ul; vi = vl;
							zi = zl;
							ri = rl; gi = gl; bi = bl;
							xstart = Std.int(xl);
							xend = Std.int(xr);
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
						for (xi in xstart...xend)
						{
							pos=xi+yi*width;
							if (zi > buffer[pos])
							{
								if(perspectiveCorrect)
								{
									textel = texVector[Std.int(ui/zi) + Std.int(vi/zi) * texWidth];
								}else
								{
									textel = texVector[Std.int(ui) + Std.int(vi) * texWidth];
								}
								target[pos] = ((((textel >> 16 & 0xFF) * Std.int(ri)) >> 8) << 16 |
									           (((textel >> 8 & 0xFF) * Std.int(gi)) >> 8)  << 8  |
									           ((textel & 0xFF) * Std.int(bi)) >> 8);
								buffer[pos] = zi;
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


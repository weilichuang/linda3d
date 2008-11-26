package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.material.ITexture;
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	import flash.display.BitmapData;
	public class TRTextureFlatAlpha extends TriangleRenderer implements ITriangleRenderer
	{
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int): void
		{
			var color:uint;
			
			var bga : int;
			var bgColor : uint;

			var textel : uint;
		
			var tw:Number;
			var th:Number;
		
			var bitmapData:BitmapData;

			var dudyl : Number,dudyr : Number;
			var dvdyl : Number,dvdyr : Number;

			var u0 : Number,v0 : Number;
			var u1 : Number,v1 : Number; 
			var u2 : Number,v2 : Number;

			var ul : Number,vl : Number;
			var ur : Number,vr : Number;

			var du : Number,dv : Number;
		
			var ui : Number,vi : Number;
		
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

			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			var temp : Number;
			var side : int;
		 	var ys : int;
		 	var type : int;
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
				
				side=0;
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
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						dzdyr = (z2 - z0) * dyr;
						dudyr = (u2 - u0) * dyr;
						dvdyr = (v2 - v0) * dyr;
						xl = x0; zl = z0;
						xr = x0; zr = z0;
						ul = u0 ; vl = v0 ;
						ur = u0 ; vr = v0 ;
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
								pos=xi+yi*height;
								if (zi > buffer[pos])
								{
									bgColor = target[pos];
									
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (ui / zi, vi / zi);
									}else
									{
										textel = bitmapData.getPixel (ui, vi);
									}
									target[pos] = ( ((textel >> 16 & 0xFF) * alpha + invAlpha * (bgColor >> 16 & 0xFF) ) << 16 |
									                ((textel >> 8 & 0xFF) * alpha + invAlpha * (bgColor >> 8 & 0xFF))    << 8  |
									                ((textel & 0xFF) * alpha + invAlpha * (bgColor & 0xFF)));
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

						xl = x0; xr = x1;
						zl = z0; zr = z1;
						ul = u0; vl = v0;
						ur = u1; vr = v1;
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
						
						xl = x0; xr = x0;
						zl = z0; zr = z0;
						ul = u0; vl = v0;
						ur = u0; vr = v0;
					}
					
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
								pos=xi+yi*height;
								if (zi > buffer[pos])
								{
									bgColor = target[pos];
									
									if(perspectiveCorrect)
									{
										textel = bitmapData.getPixel (ui / zi, vi / zi);
									}else
									{
										textel = bitmapData.getPixel (ui, vi);
									}
									target[pos] = ( ((textel >> 16 & 0xFF) * alpha + invAlpha * (bgColor >> 16 & 0xFF) ) << 16 |
									                ((textel >> 8 & 0xFF) * alpha + invAlpha * (bgColor >> 8 & 0xFF))    << 8  |
									                ((textel & 0xFF) * alpha + invAlpha * (bgColor & 0xFF)));
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

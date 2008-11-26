package linda.video.pixel
{
	import __AS3__.vec.Vector;
	
	import linda.video.ITriangleRenderer;
	import linda.math.Vertex4D;
	public class TRFlatAlpha32 extends TriangleRenderer implements ITriangleRenderer
	{
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var color:uint;
			
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
			
			var bga : int;
		    var bgColor : uint;
			var r:int,b:int,g:int;

			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			var temp : Number;
			var side : int;
		 	var ys : int;
		 	var type : int;
            var oldZ:Number;
            var pos:int;
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
				
				r = vt0.r;g = vt0.g;b = vt0.b;
				
				side = 0;
				yend = y2;
				ys = y1;
				ystart = y0;
				if(type==0)
				{
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
								pos=xi+yi*height;
								oldZ=buffer[pos];
								bgColor = target[pos];
								bga = bgColor >> 24 & 0xFF ;
								if (bga < 0xFF || zi > oldZ)
								{
									color = ((alpha*intAlpha+ invAlpha*bga)              << 24 | 
									         (alpha*r + invAlpha*(bgColor >> 16 & 0xFF)) << 16 | 
									         (alpha*g + invAlpha*(bgColor >> 8 & 0xFF))  << 8  | 
									         (alpha*b + invAlpha*(bgColor & 0xFF)) );
									target[pos] = color;
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
					} 
					else
					{
						dy = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dy; dxdyr = (x2 - x0) * dy;
						dzdyl = (z1 - z0) * dy; dzdyr = (z2 - z0) * dy;

						xl = x0; zl = z0;
						xr = x0; zr = z0;
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
								pos=xi+yi*height;
								oldZ=buffer[pos];
								bgColor = target[pos];
								bga = bgColor >> 24 & 0xFF ;
								if (bga < 0xFF || zi > oldZ)
								{
									color = ((alpha*intAlpha+ invAlpha*bga)              << 24 | 
									         (alpha*r + invAlpha*(bgColor >> 16 & 0xFF)) << 16 | 
									         (alpha*g + invAlpha*(bgColor >> 8 & 0xFF))  << 8  | 
									         (alpha*b + invAlpha*(bgColor & 0xFF)) );
									target[pos] = color;
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

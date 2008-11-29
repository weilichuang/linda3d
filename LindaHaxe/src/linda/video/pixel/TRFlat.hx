package linda.video.pixel;

	import flash.Vector;
	import haxe.Log;
	
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	class TRFlat extends TriangleRenderer,implements ITriangleRenderer
	{
		public function new()
		{
			super();
		}
		public function drawIndexedTriangleList (vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int): Void
		{
			var color:UInt;
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

			var vt0:Vertex4D,vt1:Vertex4D,vt2:Vertex4D;
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
				
				color = 0xFF000000 | vt0.r << 16 | vt0.g << 8 | vt0.b ;
				
				side = 0;

				ystart = y0;
				ys     = y1;
                yend   = y2;

				if(type == 0)
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
						for (yi in ystart...yend)
						{
							xstart = Std.int(xl);
							xend = Std.int(xr);
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dz = (zr - zl) / dx;
							} else
							{
								dz = (zr - zl);
							}
							for (xi in xstart...xend)
							{
								pos=xi+yi*height;
								if (zi > buffer[pos])
								{
									target[pos]=color;
									buffer[pos]=zi;
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
									dxdyl = (x2 - x1) * dyl;
								    dzdyl = (z2 - z1) * dyl;
									xl = x1+dxdyl; 
									zl = z1+dzdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr; 
									dzdyr = (z1 - z2) * dyr;
									xr = x2+dxdyr; 
									zr = z2+dzdyr;
								}
							}
						}
				}
				else //平底或平顶
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
					for (yi in ystart...yend)
					{
							xstart = Std.int(xl);
							xend = Std.int(xr);
							zi = zl;
							dx = (xend - xstart);
							if (dx > 0)
							{
								dz = (zr - zl) / dx;
							} else
							{
								dz = (zr - zl);
							}
							for (xi in xstart...xend)
							{
								pos=xi+yi*height;
								if (zi > buffer[pos])
								{
									target[pos]=color;
									buffer[pos]=zi;
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


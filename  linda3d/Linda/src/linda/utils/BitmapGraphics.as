package linda.utils
{
	import flash.geom.Rectangle;
	
	import linda.math.AABBox2D;
	import linda.math.Vertex;
	
	import flash.display.BitmapData;
	

	public class BitmapGraphics extends BitmapData
	{
		public function BitmapGraphics(width:int, height:int, transparent:Boolean=true, fillColor:uint=0x0)
		{
			super(width, height, transparent, fillColor);
		}
		private var _rect:Rectangle=new Rectangle();
		public function drawPoint(x:Number,y:Number,color:uint=0xff0000ff,width:int=3,height:int=3):void
		{
			if ((y < 0) || (y > this.height)|| (x < 0) || (x > this.width) ) return;
			_rect.x=int(x-width/2+0.5);
			_rect.y=int(y-height/2+0.5);
			_rect.width=width;
			_rect.height=height;
			fillRect(_rect,color);
		}
		
		public function drawFlatTriangle (vt0 : Vertex, vt1 : Vertex, vt2 : Vertex,color:uint) : void
		{
		         var x0 : int, x1 : int, x2 : int;
		         var y0 : int, y1 : int, y2 : int;

		         var xstart : int, xend : int;
		         var ystart : int, yend : int;

		         var xi : int, yi : int;
		
		         var xl : Number, xr : Number;
		         var dxdyl : Number, dxdyr : Number;

		         var dyr : Number, dyl : Number;
		
		         var dx : Number, dy : Number;
		         
		         var ys:int;
		         
		         var temp:Number;
		         
		         var temp1:Vertex;
		         
		         var tri_type:int;
		         
		         var side:int;
		         
		         var minX:int=0;
		         var minY:int=0;
		         var maxX:int=this.width;
		         var maxY:int=this.height;
		
				if (((vt0.y < minY) && (vt1.y < minY) && (vt2.y < minY)) ||
				((vt0.y > maxY) && (vt1.y > maxY) && (vt2.y > maxY)) ||
				((vt0.x < minX) && (vt1.x < minX) && (vt2.x < minX)) ||
				((vt0.x > maxX) && (vt1.x > maxX) && (vt2.x > maxX)))
				return ;

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
				
				tri_type = 0;
				if (vt0.y == vt1.y)
				{
					tri_type = 1;
					if (vt1.x < vt0.x)
					{
						temp1 = vt0; vt0 = vt1; vt1 = temp1;
					}
				} else if (vt1.y == vt2.y)
				{
					tri_type = 2;
					if (vt2.x < vt1.x)
					{
						temp1 = vt1; vt1 = vt2; vt2 = temp1;
					}
				}
				

				color = ( 0xFF000000 | vt0.r << 16 | vt0.g << 8 | vt0.b );
				
				x0 = vt0.x ; y0 = vt0.y ;
				x1 = vt1.x ; y1 = vt1.y ;
				x2 = vt2.x ; y2 = vt2.y ;
				if (((x0 == x1) && (x1 == x2)) || ((y0 == y1) && (y1 == y2))) return;
				
				ys = y1;
				side = 0;
				if(tri_type == 0)
				{
					yend = y2;
					if (yend > maxY) yend = maxY;
					if (y1 < minY)
					{
						dxdyl = (x2 - x1 ) / (y2 - y1);
						dxdyr = (x2 - x0 ) / (y2 - y0);
						xl = dxdyl * (minY - y0) + x1;
						xr = dxdyr * (minY - y1) + x0;
						ystart = minY;
						if (dxdyr > dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							
							temp = xl; xl = xr; xr = temp;
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;
							
							side = 1;
						}
					} 
					else if (y0 < minY)
					{
						dxdyl = (x1 - x0) / (y1 - y0);
						dxdyr = (x2 - x0) / (y2 - y0);
						xl = dxdyl * (minY - y0) + x0;
						xr = dxdyr * (minY - y0) + x0;
						ystart = minY;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;

							temp = xl; xl = xr; xr = temp;
							
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;
							
							side = 1;
						}
					} else
					{
						dxdyl = (x1 - x0) / (y1 - y0);
						dxdyr = (x2 - x0) / (y2 - y0);
						xl = x0;
						xr = x0;
						ystart = y0;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							
							temp = xl; xl = xr; xr = temp;
							
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;
							
							side = 1;
						}
					}
					if ((x0 < minX) || (x0 > maxX) ||
					    (x1 < minX) || (x1 > maxX) ||
					    (x2 < minX) || (x2 > maxX))
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl; xend = xr;
							if (xstart < minX)
							{
								xstart = minX;
							}
							if (xend > maxX) xend = maxX;
							for (xi = xstart; xi < xend; xi ++)
							{
								setPixel32 (xi, yi, color);
							}
							xl += dxdyl;
							xr += dxdyr;
							if (yi == ys)
							{
								if (side == 0)
								{
									dxdyl = (x2 - x1)  / (y2 - y1);
									xl = x1+dxdyl;
								} else
								{
									dxdyr = (x1 - x2) / (y1 - y2);
									xr = x2+dxdyr;
								}
							}
						}
					} else
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl; xend = xr;
							for (xi = xstart; xi < xend; xi ++)
							{
								setPixel32 (xi, yi, color);
							}
							xl += dxdyl;
							xr += dxdyr;
							if (yi == ys)
							{
								if (side == 0)
								{
									dxdyl = (x2 - x1) / (y2 - y1);
									xl = x1+dxdyl;
								} else
								{
									dxdyr = (x1 - x2) / (y1 - y2);
									xr = x2+dxdyr;
								}
							}
						}
					}
				}
				else //平底或平顶
				{
				    if (tri_type == 1)
					{
						dxdyl = (x2 - x0)  / (y2 - y0);
						dxdyr = (x2 - x1)  / (y2 - y0);
						if (y0 < minY)
						{
							dy = (minY - y0);
							xl = dxdyl * dy + x0;
							xr = dxdyr * dy + x1;
							ystart = minY;
						} else
						{
							xl = x0;
							xr = x1;
							ystart = y0;
						}
					} 
					else
					{
						dxdyl = (x1 - x0) / (y1 - y0);
						dxdyr = (x2 - x0) / (y1 - y0);
						if (y0 < minY)
						{
							xl = dxdyl * (minY - y0) + x0;
							xr = dxdyr * (minY - y0) + x0;
							ystart = minY;
						} else
						{
							xl = x0;
							xr = x0;
							ystart = y0;
						}
					}
					yend = y2;
					if (yend > maxY) yend = maxY;
					if ((x0 < minX) || (x0 > maxX) ||
					    (x1 < minX) || (x1 > maxX) ||
					    (x2 < minX) || (x2 > maxX))
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl;
							xend = xr;
							if (xstart < minX)
							{
								xstart = minX;
							}
							if (xend > maxX) xend = maxX;
							for (xi = xstart; xi < xend; xi ++)
							{
								setPixel32 (xi, yi, color);
							}
							xl += dxdyl;
							xr += dxdyr;
						}
					} else
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl; xend = xr;
							for (xi = xstart; xi < xend; xi ++)
							{
								setPixel32 (xi, yi, color);
							}
							xl += dxdyl;
							xr += dxdyr;
						}
					}
			}
		}
		public function drawGouraudTriangle(vt0:Vertex,vt1:Vertex,vt2:Vertex):void
		{
			     var drdyl : Number;
		         var drdyr : Number;
		         var dgdyl : Number;
		         var dgdyr : Number;
		         var dbdyl : Number;
		         var dbdyr : Number;
		         var r0 : int;
		         var g0 : int;
		         var b0 : int;
		         var r1 : int;
		         var g1 : int;
		         var b1 : int;
		         var r2 : int;
		         var g2 : int;
		         var b2 : int;
		         var ri : Number;
		         var bi : Number;
		         var gi : Number;
		         var rl : Number;
		         var gl : Number;
		         var bl : Number;
		         var rr : Number;
		         var gr : Number;
		         var br : Number;
		         var dr : Number;
		         var dg : Number;
		         var db : Number;
		         var x0 : int, x1 : int, x2 : int;
		         var y0 : int, y1 : int, y2 : int;
		         var xstart : int, xend : int;
		         var ystart : int, yend : int;
		         var xi : int, yi : int;
		         var xl : Number, xr : Number;
		         var dxdyl : Number, dxdyr : Number;
		         var dyr : Number, dyl : Number;
		         var dx : Number, dy : Number;	     
		         var ys:int;
		         var temp:Number;	         
		         var temp1:Vertex;		         
		         var side:int;		         
		         var tri_type:int;
		         
			  if (((vt0.y < 0) && (vt1.y < 0) && (vt2.y < 0)) ||
				((vt0.y > height) && (vt1.y > height) && (vt2.y > height)) ||
				((vt0.x < 0) && (vt1.x < 0) && (vt2.x < 0)) ||
				((vt0.x > width) && (vt1.x > width) && (vt2.x > width)))
				return ;
				
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
				if (vt0.y == vt1.y)
				{
					tri_type = 1;
					if (vt1.x < vt0.x)
					{
						temp1 = vt0; vt0 = vt1; vt1 = temp1;
					}
				} else if (vt1.y == vt2.y)
				{
					tri_type = 2;
					if (vt2.x < vt1.x)
					{
						temp1 = vt1; vt1 = vt2; vt2 = temp1;
					}
				} else
				{
					tri_type = 0;
				}
				side = 0;
				r0 = vt0.r; g0 = vt0.g; b0 = vt0.b;
				x0 = int(vt0.x+0.5) ; y0 = int(vt0.y+0.5) ;
				r1 = vt1.r; g1 = vt1.g; b1 = vt1.b;
				x1 = int(vt1.x+0.5) ; y1 = int(vt1.y+0.5) ;
				r2 = vt2.r; g2 = vt2.g; b2 = vt2.b;
				x2 = int(vt2.x+0.5) ; y2 = int(vt2.y+0.5) ;
				if (((x0 == x1) && (x1 == x2)) || ((y0 == y1) && (y1 == y2))) return;
				ys = y1;
				if(tri_type==0)
				{
					if ((yend = y2) > height) yend = height;
					if (y1 < 0)
					{
						dyl = 1 / (y2 - y1);
						dxdyl = (x2 - x1 ) * dyl;
						drdyl = (r2 - r1) * dyl;
						dgdyl = (g2 - g1) * dyl;
						dbdyl = (b2 - b1) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0 ) * dyr;
						drdyr = (r2 - r0) * dyr;
						dgdyr = (g2 - g0) * dyr;
						dbdyr = (b2 - b0) * dyr;
						dyr = (0 - y0);
						dyl = (0 - y1);
						xl = dxdyl * dyl + x1;
						rl = drdyl * dyl + r1;
						gl = dgdyl * dyl + g1;
						bl = dbdyl * dyl + b1;
						xr = dxdyr * dyr + x0;
						rr = drdyr * dyr + r0;
						gr = dgdyr * dyr + g0;
						br = dbdyr * dyr + b0;
						ystart = 0;
						if (dxdyr > dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = drdyl; drdyl = drdyr; drdyr = temp;
							temp = dgdyl; dgdyl = dgdyr; dgdyr = temp;
							temp = dbdyl; dbdyl = dbdyr; dbdyr = temp;
							temp = xl; xl = xr; xr = temp;
							
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;
							r1 ^= r2; r2 ^= r1; r1 ^= r2;
							g1 ^= g2; g2 ^= g1; g1 ^= g2;
							b1 ^= b2; b2 ^= b1; b1 ^= b2;
							
							side = 1;
						}
					} 
					else if (y0 < 0)
					{
						dyl = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dyl;
						drdyl = (r1 - r0) * dyl;
						dgdyl = (g1 - g0) * dyl;
						dbdyl = (b1 - b0) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						drdyr = (r2 - r0) * dyr;
						dgdyr = (g2 - g0) * dyr;
						dbdyr = (b2 - b0) * dyr;
						dy = (0 - y0);
						xl = dxdyl * dy + x0 ;
						rl = drdyl * dy + r0;
						gl = dgdyl * dy + g0;
						bl = dbdyl * dy + b0;
						xr = dxdyr * dy + x0 ;
						rr = drdyr * dy + r0;
						gr = dgdyr * dy + g0;
						br = dbdyr * dy + b0;
						ystart = 0;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = drdyl; drdyl = drdyr; drdyr = temp;
							temp = dgdyl; dgdyl = dgdyr; dgdyr = temp;
							temp = dbdyl; dbdyl = dbdyr; dbdyr = temp;

							temp = xl; xl = xr; xr = temp;

							
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;

							r1 ^= r2; r2 ^= r1; r1 ^= r2;
							g1 ^= g2; g2 ^= g1; g1 ^= g2;
							b1 ^= b2; b2 ^= b1; b1 ^= b2;
							
							side = 1;
						}
					} else
					{
						dyl = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dyl;
						drdyl = (r1 - r0) * dyl;
						dgdyl = (g1 - g0) * dyl;
						dbdyl = (b1 - b0) * dyl;
						dyr = 1 / (y2 - y0);
						dxdyr = (x2 - x0) * dyr;
						drdyr = (r2 - r0) * dyr;
						dgdyr = (g2 - g0) * dyr;
						dbdyr = (b2 - b0) * dyr;
						xl = x0 ; xr = x0 ;
		
						rl = r0; gl = g0; bl = b0;
						rr = r0; gr = g0; br = b0;
						ystart = y0;
						if (dxdyr < dxdyl)
						{
							temp = dxdyl; dxdyl = dxdyr; dxdyr = temp;
							temp = drdyl; drdyl = drdyr; drdyr = temp;
							temp = dgdyl; dgdyl = dgdyr; dgdyr = temp;
							temp = dbdyl; dbdyl = dbdyr; dbdyr = temp;
							temp = xl; xl = xr; xr = temp;
							
							x1 ^= x2; x2 ^= x1; x1 ^= x2;
							y1 ^= y2; y2 ^= y1; y1 ^= y2;
							r1 ^= r2; r2 ^= r1; r1 ^= r2;
							g1 ^= g2; g2 ^= g1; g1 ^= g2;
							b1 ^= b2; b2 ^= b1; b1 ^= b2;
							
							side = 1;
						}
					}
					if ((x0 < 0) || (x0 > width) ||
					(x1 < 0) || (x1 > width) ||
					(x2 < 0) || (x2 > width))
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl;
							xend = xr;
							ri = rl; gi = gl; bi = bl;
							if ((dx = (xend - xstart)) > 0)
							{
								dr = (rr - rl) / dx;
								dg = (gr - gl) / dx;
								db = (br - bl) / dx;
							} 
							else
							{
								dr = (rr - rl);
								dg = (gr - gl);
								db = (br - bl);
							}
							if (xstart < 0)
							{
								dx = 0 - xstart;
								ri += dx * dr; gi += dx * dg; bi += dx * db;
								xstart = 0;
							}
							if (xend > width) xend = width;
							for (xi = xstart; xi < xend; xi ++)
							{

								setPixel32 (xi, yi,( 0xFF000000 | int(ri) << 16 | int(gi) << 8 | int(bi) ));

								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
			
							xr += dxdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
		
							if (yi == ys)
							{
								if (side == 0)
								{
									dyl = 1 / (y2 - y1);
									dxdyl = (x2 - x1) * dyl;
				
									drdyl = (r2 - r1) * dyl;
									dgdyl = (g2 - g1) * dyl;
									dbdyl = (b2 - b1) * dyl;
									xl = x1 ;
				
									rl = r1; gl = g1; bl = b1;
									xl += dxdyl;
				
									rl += drdyl; gl += dgdyl; bl += dbdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr;
									drdyr = (r1 - r2) * dyr;
									dgdyr = (g1 - g2) * dyr;
									dbdyr = (b1 - b2) * dyr;
									xr = x2 ;
			
									rr = r2; gr = g2; br = b2;
									xr += dxdyr;
									rr += drdyr; gr += dgdyr; br += dbdyr;
								}
							}
						}
					} else
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl;
							xend = xr;
							ri = rl; gi = gl; bi = bl;
							if ((dx = (xend - xstart)) > 0)
							{
								dx = 1 / dx;
								dr = (rr - rl) * dx;
								dg = (gr - gl) * dx;
								db = (br - bl) * dx;
							} else
							{
								dr = (rr - rl);
								dg = (gr - gl);
								db = (br - bl);
							}
							for (xi = xstart; xi < xend; xi ++)
							{
								setPixel32 (xi, yi,( 0xFF000000 | int(ri) << 16 | int(gi) << 8 | int(bi) ));	
								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
							
							xr += dxdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
							
							if (yi == ys)
							{
								if (side == 0)
								{
									dyl = 1 / (y2 - y1);
									dxdyl = (x2 - x1) * dyl;
									
									drdyl = (r2 - r1) * dyl;
									dgdyl = (g2 - g1) * dyl;
									dbdyl = (b2 - b1) * dyl;
									xl = x1 ;
									
									rl = r1;
									gl = g1;
									bl = b1;
									xl += dxdyl;
							
									rl += drdyl;
									gl += dgdyl;
									bl += dbdyl;
								} else
								{
									dyr = 1 / (y1 - y2);
									dxdyr = (x1 - x2) * dyr;
					
									drdyr = (r1 - r2) * dyr;
									dgdyr = (g1 - g2) * dyr;
									dbdyr = (b1 - b2) * dyr;
									xr = x2 ;
							
									rr = r2; gr = g2; br = b2;
									xr += dxdyr;
						
									rr += drdyr; gr += dgdyr; br += dbdyr;
								}
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
						
						drdyl = (r2 - r0) * dy;
						dgdyl = (g2 - g0) * dy;
						dbdyl = (b2 - b0) * dy;
						dxdyr = (x2 - x1) * dy;
	
						drdyr = (r2 - r1) * dy;
						dgdyr = (g2 - g1) * dy;
						dbdyr = (b2 - b1) * dy;
						if (y0 < 0)
						{
							dy = (0 - y0);
							xl = dxdyl * dy + x0;
							rl = drdyl * dy + r0;
							gl = dgdyl * dy + g0;
							bl = dbdyl * dy + b0;
							xr = dxdyr * dy + x1;
							rr = drdyr * dy + r1;
							gr = dgdyr * dy + g1;
							br = dbdyr * dy + b1;
							ystart = 0;
						} else
						{
							xl = x0; xr = x1;
							rl = r0; gl = g0; bl = b0;
							rr = r1; gr = g1; br = b1;
							ystart = y0;
						}
					} 
					else
					{
						dy = 1 / (y1 - y0);
						dxdyl = (x1 - x0) * dy;
						drdyl = (r1 - r0) * dy;
						dgdyl = (g1 - g0) * dy;
						dbdyl = (b1 - b0) * dy;
						dxdyr = (x2 - x0) * dy;
						drdyr = (r2 - r0) * dy;
						dgdyr = (g2 - g0) * dy;
						dbdyr = (b2 - b0) * dy;
						if (y0 < 0)
						{
							dy = (0 - y0);
							xl = dxdyl * dy + x0;
							rl = drdyl * dy + r0;
							gl = dgdyl * dy + g0;
							bl = dbdyl * dy + b0;
							xr = dxdyr * dy + x0;
							rr = drdyr * dy + r0;
							gr = dgdyr * dy + g0;
							br = dbdyr * dy + b0;
							ystart = 0;
						} else
						{
							xl = x0; xr = x0;
							rl = r0; gl = g0; bl = b0;
							rr = r0; gr = g0; br = b0;
							ystart = y0;
						}
					}
					if ((yend = y2) > height) yend = height;
					if ((x0 < 0) || (x0 > width) ||
					(x1 < 0) || (x1 > width) ||
					(x2 < 0) || (x2 > width))
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl;
							xend = xr;
							ri = rl; gi = gl; bi = bl;
							if ((dx = (xend - xstart)) > 0)
							{
								dx = 1 / dx;
								dr = (rr - rl) * dx;
								dg = (gr - gl) * dx;
								db = (br - bl) * dx;
							} else
							{
								dr = (rr - rl);
								dg = (gr - gl);
								db = (br - bl);
							}
							if (xstart < 0)
							{
								dx = 0 - xstart;
								ri += dx * dr; gi += dx * dg; bi += dx * db;
								xstart = 0;
							}
							if (xend > width) xend = width;
							for (xi = xstart; xi < xend; xi ++)
							{
								setPixel32 (xi, yi,( 0xFF000000 | int(ri) << 16 | int(gi) << 8 | int(bi) ));
								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
							xr += dxdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
						}
					} else
					{
						for (yi = ystart; yi <= yend; yi ++)
						{
							xstart = xl;
							xend = xr;
							ri = rl; gi = gl; bi = bl;
							if ((dx = (xend - xstart)) > 0)
							{
								dx = 1 / dx;
								dr = (rr - rl) * dx;
								dg = (gr - gl) * dx;
								db = (br - bl) * dx;
							} else
							{
								dr = (rr - rl);
								dg = (gr - gl);
								db = (br - bl);
							}
							for (xi = xstart; xi < xend; xi ++)
							{
								setPixel32 (xi, yi,( 0xFF000000 | int(ri) << 16 | int(gi) << 8 | int(bi) ));
								ri += dr; gi += dg; bi += db;
							}
							xl += dxdyl;
							rl += drdyl; gl += dgdyl; bl += dbdyl;
							xr += dxdyr;
							rr += drdyr; gr += dgdyr; br += dbdyr;
						}
					}
				}
		}
		public function drawLine( x0: int, y0: int, x1: int, y1: int, value: uint ): void
		{
			//if ((y0 < 0) || (y0 > height)|| (x0 < 0) || (x0 > width) &&
			//    (y1 < 0) || (y1 > height)|| (x1 < 0) || (x1 > width) ) return;
			    
			var error: int;
			
			var dx: int = x1 - x0;
			var dy: int = y1 - y0;

			var yi: int = 1;

			if( dx < dy )
			{
				//-- swap end points
				x0 ^= x1; x1 ^= x0; x0 ^= x1;
				y0 ^= y1; y1 ^= y0; y0 ^= y1;
			}

			if( dx < 0 )
			{
				dx = -dx; yi = -yi;
			}
			
			if( dy < 0 )
			{
				dy = -dy; yi = -yi;
			}
				
			if( dy > dx )
			{
				error = -( dy >> 1 );
				for( ; y1 < y0 ; y1++ )
				{
					setPixel32( x1, y1, value );

					error += dx;
					if( error > 0 )
					{
						x1 += yi;
						error -= dy;
					}
				}
			}
			else
			{
				error = -( dx >> 1 );
				for( ; x0 < x1 ; x0++ )
				{
					setPixel32( x0, y0, value );

					error += dy;
					if( error > 0 )
					{
						y0 += yi;
						error -= dx;
					}
				}
			}
		}
		public function drawWireTriangle(vt0:Vertex,vt1:Vertex,vt2:Vertex,color:uint):void
		{
			drawLine(vt0.x,vt0.y,vt1.x,vt1.y,color);
			drawLine(vt1.x,vt1.y,vt2.x,vt2.y,color);
			drawLine(vt2.x,vt2.y,vt0.x,vt0.y,color);
		}
		public function drawRect(rect:Rectangle,color:uint):void
		{
			var minx:Number=rect.topLeft.x;
			var miny:Number=rect.topLeft.y;
			var maxx:Number=rect.bottomRight.x;
			var maxY:Number=rect.bottomRight.y;
			drawLine(minx,miny,maxx,miny,color);
			drawLine(maxx,miny,maxx,maxY,color);
			drawLine(maxx,maxY,minx,maxY,color);
			drawLine(minx,maxY,minx,miny,color);
		}
		public function drawAABBox2D(box:AABBox2D,color:uint):void
		{
			var minx:Number=box.minX;
			var miny:Number=box.minY;
			var maxx:Number=box.maxX;
			var maxY:Number=box.maxY;
			drawLine(minx,miny,maxx,miny,color);
			drawLine(maxx,miny,maxx,maxY,color);
			drawLine(maxx,maxY,minx,maxY,color);
			drawLine(minx,maxY,minx,miny,color);
		}
	    public function clear(color:uint=0x0):void
	    {
	       if(transparent)
	       {
	       	  fillRect(rect,0x0);
	       }else
	       {
	       	  fillRect(rect,color);
	       }
	    	
	    }
	}
}
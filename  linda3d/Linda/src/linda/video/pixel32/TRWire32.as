package linda.video.pixel32
{
	import __AS3__.vec.Vector;
	
	import linda.video.ITriangleRenderer;
	import linda.video.TriangleRenderer;
	import linda.math.Vertex4D;
	public class TRWire32 extends TriangleRenderer implements ITriangleRenderer
	{
		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
		{
			var color:uint;
			var x0 : int; 
			var x1 : int; 
			var x2 : int; 
			var y0 : int; 
			var y1 : int; 
			var y2 : int;
			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			if ( ! material.transparenting)
			{
				 var ii:int;
			     for (var i : int = 0; i < indexCount; i += 3)
				 {
					ii  = indexList [i];
					vt0 = vertices [ii];
					ii  = indexList [int(i+ 1)];
				    vt1 = vertices [ii];
					ii  = indexList [int(i+ 2)];
					vt2 = vertices [ii];

					color = (0xFF000000 | vt0.r << 16 | vt0.g << 8 | vt0.b );
					bresenham (vt0.x, vt0.y, vt0.z, vt1.x, vt1.y, vt1.z, color);
					color = (0xFF000000 | vt1.r << 16 | vt1.g << 8 | vt1.b );
					bresenham (vt1.x, vt1.y, vt1.z, vt2.x, vt2.y, vt2.z, color);
					color = (0xFF000000 | vt2.r << 16 | vt2.g << 8 | vt2.b );
					bresenham (vt2.x, vt2.y, vt2.z, vt0.x, vt0.y, vt0.z, color);
				}
			} else
			{
				 for (i = 0; i < indexCount; i += 3)
				 {
					ii  = indexList[i];
					vt0 = vertices[ii];
					ii  = indexList[int(i+ 1)];
					vt1 = vertices[ii];
					ii  = indexList[int(i+ 2)];
					vt2 = vertices[ii];

					bresenhamAlpha (vt0.x, vt0.y, vt0.z, vt1.x, vt1.y, vt1.z, vt0.r, vt0.g, vt0.b);
					bresenhamAlpha (vt1.x, vt1.y, vt1.z, vt2.x, vt2.y, vt2.z, vt1.r, vt1.g, vt1.b);
					bresenhamAlpha (vt2.x, vt2.y, vt2.z, vt0.x, vt0.y, vt0.z, vt2.r, vt2.g, vt2.b);
				}
			}
		}
		private function bresenham (x0 : int, y0 : int, z0:Number, x1 : int, y1 : int, z1:Number, value : uint ) : void
		{
			var oldZ:Number;
            var pos:int;
			var error : int;
			var dx : int = x1 - x0;
			var dy : int = y1 - y0;
			var dz : int = z1 - z0;
			var yi : int = 1;
			var dzdy : Number;
			if (dx < dy )
			{
				//-- swap end points
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
				var temp : Number = z1;
				z1 = z0;
				z0 = temp;
			}
			if (dx < 0 )
			{
				dx = - dx;
				yi = - yi;
				dz = - dz;
			}
			if (dy < 0 )
			{
				dy = - dy;
				yi = - yi;
				dz = - dz;
			}
			if (dy > dx )
			{
				error = - (dy >> 1 );
				dzdy = dz / (y0 - y1);
				for (; y1 < y0 ; y1 +=1)
				{
					pos=x1+y1*height;
					if (z1 > buffer[pos])
					{
						target[pos] = value;
						buffer[pos] = z1;
					}
					error += dx;
					if (error > 0 )
					{
						x1 += yi;
						z1 += dzdy;
						error -= dy;
					}
				}
			} 
			else
			{
				error = - (dx >> 1 );
				dzdy = dz / (x1 - x0);
				for (; x0 < x1 ; x0 +=1)
				{
					pos=x0+y0*height;
					if (z0 > buffer[pos])
					{
						target[pos] = value;
						buffer[pos] = z0;
					}
					error += dy;
					if (error > 0 )
					{
						y0 += yi;
						z0 += dzdy;
						error -= dx;
					}
				}
			}
		}
		private function bresenhamAlpha (x0 : int, y0 : int, z0:Number, x1 : int, y1 : int, z1:Number, r : int, g : int, b : int ) : void
		{
			var bga : int;
		    var bgColor : uint;
			var error : int;
			var dx : int = x1 - x0;
			var dy : int = y1 - y0;
			var dz : int = z1 - z0;
			var yi : int = 1;
			var oldZ:Number;
            var pos:int;
			var dzdy : Number;
			if (dx < dy )
			{
				//-- swap end points
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
				var temp : Number = z1;
				z1 = z0;
				z0 = temp;
			}
			if (dx < 0 )
			{
				dx = - dx;
				yi = - yi;
				dz = - dz;
			}
			if (dy < 0 )
			{
				dy = - dy;
				yi = - yi;
				dz = - dz;
			}
			if (dy > dx )
			{
				error = - (dy >> 1 );
				dzdy = dz / (y0 - y1);
				for (; y1 < y0 ; y1 +=1)
				{
					pos=x1+y1*height;
					bgColor = target[pos];
					bga = bgColor >> 24 & 0xFF ;
					if (bga < 0xFF)
					{
						target[pos] = (((alpha*alpha + invAlpha* bga) >> 8)                   << 24 |
						               ((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  			   ((alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  			   ((alpha * b + invAlpha * (bgColor & 0xFF)) >> 8)
						              );
					}else if (z1 > buffer[pos])
					{ 
						target[pos] = ( 0xFF000000                                                   |
		                  				((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  				((alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  				((alpha * b + invAlpha * (bgColor & 0xFF)) >> 8)
								       );
					}
					error += dx;
					if (error > 0 )
					{
						x1 += yi;
						z1 += dzdy;
						error -= dy;
					}
				}
			} 
			else
			{
				error = - (dx >> 1 );
				dzdy = dz / (x1 - x0);
				for (; x0 < x1 ; x0 +=1)
				{
					pos=x0+y0*height;
					bgColor = target[pos];
					bga = bgColor >> 24 & 0xFF ;
					if (bga < 0xFF)
					{
						target[pos] = (((alpha*alpha + invAlpha* bga) >> 8)                   << 24 |
						               ((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  			   ((alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  			   ((alpha * b + invAlpha * (bgColor & 0xFF)) >> 8)
						              );
					}else if (z0 > buffer[pos])
					{ 
						target[pos] = ( 0xFF000000                                                   |
		                  				((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  				((alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  				((alpha * b + invAlpha * (bgColor & 0xFF)) >> 8)
								       );
					}
					error += dy;
					if (error > 0 )
					{
						y0 += yi;
						z0 += dzdy;
						error -= dx;
					}
				}
			}
		}
	}
}

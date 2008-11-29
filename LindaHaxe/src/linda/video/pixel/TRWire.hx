package linda.video.pixel;

	import flash.Vector;
	
	import linda.video.ITriangleRenderer;
	import linda.math.Vertex4D;
	class TRWire extends TriangleRenderer,implements ITriangleRenderer
	{
		private var z0 : Float; 
		private var z1 : Float;
		private var z2 : Float; 
		public function new()
		{
			super();
		}
		public function drawIndexedTriangleList (vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int) : Void
		{
			var color:UInt;
			var x0 : Int; 
			var x1 : Int; 
			var x2 : Int; 
			var y0 : Int; 
			var y1 : Int; 
			var y2 : Int;
			var vt0:Vertex4D;
		    var vt1:Vertex4D;
		    var vt2:Vertex4D;
			if ( ! material.transparenting)
			{
				 var i:Int = 0;
				 while ( i < indexCount)
				 {
					var ii:Int = indexList [i];
					vt0 = vertices [ii];
					ii  = indexList [i+ 1];
				    vt1 = vertices [ii];
					ii  = indexList [i+ 2];
					vt2 = vertices [ii];
					
					i += 3;

					z0 = vt0.z;
					z1 = vt1.z;
					z2 = vt2.z;

					color = (0xFF000000 | vt0.r << 16 | vt0.g << 8 | vt0.b );
					bresenham (Std.int(vt0.x), Std.int(vt0.y),vt0.z, Std.int(vt1.x), Std.int(vt1.y),vt1.z, color);
					color = (0xFF000000 | vt1.r << 16 | vt1.g << 8 | vt1.b );
					bresenham (Std.int(vt1.x), Std.int(vt1.y),vt1.z, Std.int(vt2.x), Std.int(vt2.y),vt2.z, color);
					color = (0xFF000000 | vt2.r << 16 | vt2.g << 8 | vt2.b );
					bresenham (Std.int(vt2.x), Std.int(vt2.y),vt2.z, Std.int(vt0.x), Std.int(vt0.y),vt0.z, color);
				}
			} else
			{
				var i:Int = 0;
				while ( i < indexCount)
				{
					var ii:Int = indexList [i];
					vt0 = vertices [ii];
					ii  = indexList [i+ 1];
				    vt1 = vertices [ii];
					ii  = indexList [i+ 2];
					vt2 = vertices [ii];
					
					i += 3;

					z0 = vt0.z;
					z1 = vt1.z;
					z2 = vt2.z;

					bresenhamAlpha (Std.int(vt0.x), Std.int(vt0.y),vt0.z, Std.int(vt1.x), Std.int(vt1.y),vt1.z, vt0.r, vt0.g, vt0.b);
					bresenhamAlpha (Std.int(vt1.x), Std.int(vt1.y),vt1.z, Std.int(vt2.x), Std.int(vt2.y),vt2.z, vt1.r, vt1.g, vt1.b);
					bresenhamAlpha (Std.int(vt2.x), Std.int(vt2.y),vt2.z, Std.int(vt0.x), Std.int(vt0.y),vt0.z, vt2.r, vt2.g, vt2.b);
				}
			}
		}
		private inline function bresenham (x0 : Int, y0 : Int, z0:Float, x1 : Int, y1 : Int, z1:Float, value : UInt ) : Void
		{
            var pos:Int;
			var error : Int;
			var dx : Int = x1 - x0;
			var dy : Int = y1 - y0;
			var yi : Int = 1;
			var dz : Float = z1 - z0;
			var dzdy : Float;
			if (dx < dy )
			{
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
				var t : Float = z1;z1 = z2;z2 = t;
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
				for (y in y1...y0)
				{
					pos=x1+y*height;
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
				for (x in x0...x1)
				{
					pos=x+y0*height;
					if (z0 > buffer[pos])
					{
						target[pos] = value;
						buffer[pos] = z1;
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
		private function bresenhamAlpha (x0 : Int, y0 : Int, z0:Float, x1 : Int, y1 : Int, z1:Float, r : Int, g : Int, b : Int ) : Void
		{
			var bga : Int;
		    var bgColor : UInt;
            var pos:Int;
			var error : Int;
			var dx : Int = x1 - x0;
			var dy : Int = y1 - y0;
			var yi : Int = 1;
			
			var dz : Float = z1 - z0;
			var dzdy : Float;
			if (dx < dy )
			{
				x0 ^= x1;
				x1 ^= x0;
				x0 ^= x1;
				y0 ^= y1;
				y1 ^= y0;
				y0 ^= y1;
				var t : Float = z1;z1 = z2;z2 = t;
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
				for (y in y1...y0)
				{
					pos=x1+y*height;
					if (z1 > buffer[pos])
					{
						bgColor = target[pos];
						target[pos] = (
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
				for (x in x0...x1)
				{
					pos=x+y0*height;
					if (z0 > buffer[pos])
					{
						bgColor = target[pos];
						target[pos] = (
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


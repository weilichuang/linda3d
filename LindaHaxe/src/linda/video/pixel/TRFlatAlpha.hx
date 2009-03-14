package linda.video.pixel;
    import flash.Vector;
	import linda.math.MathUtil;
	
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	import linda.video.TriangleRenderer;
class TRFlatAlpha extends TriangleRenderer,implements ITriangleRenderer
{
    private var dzdx: Float;
	private var dzdy: Float;

	private var xa: Float;
	private var xb: Float;
	private var za: Float;
	
	private var r:Int;
	private var b:Int;
	private var g:Int;

	private var dxdya: Float;
	private var dxdyb: Float;
	private var dzdya: Float;

	private var side:Bool;
	
	private var tmp:Vertex4D;
	
	private var v1:Vertex4D;
	private var v2:Vertex4D;
	private var v3:Vertex4D;
	
	private var x1:Float;
	private var y1:Float;
	private var z1:Float;
	private var x2:Float;
	private var y2:Float;
	private var z2:Float;
	private var x3:Float;
	private var y3:Float;
	private var z3:Float;
	
	private var x2x1:Float;
	private var x3x1:Float;
	private var y2y1:Float;
	private var y3y1:Float;
	private var z2z1:Float;
	private var z3z1:Float;
	
	private var y1i:Int;
	private var y2i:Int;
	private var y3i:Int;
	
	private var zi:Float;

	private var xs:Int;
	private var xe:Int;
	private var pos:Int;
	
	private var dxdy1:Float;
	private var dxdy2:Float;
	private var dxdy3:Float;
	
	private var bgColor:UInt;
	
	public function new() 
	{
		super();
	}
	public function drawIndexedTriangleList (vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int): Void
	{
		var dy: Float;
		var i:Int = 0;
		while( i < indexCount)
		{
			v1 = vertices[indexList[i]];
			v2 = vertices[indexList[i+1]];
			v3 = vertices[indexList[i + 2]];
				
			i += 3;
				
			if (v2.y < v1.y)
			{
				tmp = v1; v1 = v2; v2 = tmp;
			}
			if (v3.y < v1.y)
			{
				tmp = v1; v1 = v3; v3 = tmp;
			}
			if (v3.y < v2.y)
			{
				tmp = v2; v2 = v3; v3 = tmp;
			}
			
			x1  = v1.x + .5;
			y1  = v1.y + .5;
			x2  = v2.x + .5;
			y2  = v2.y + .5;
			x3  = v3.x + .5;
			y3  = v3.y + .5;
			
			z1  = v1.z;
			z2  = v2.z;
			z3  = v3.z;

			r = v1.r;
			g = v1.g;
			b = v1.b;
			
			y1i = Std.int(y1);
			y2i = Std.int(y2);
			y3i = Std.int(y3);
			
			x2x1 = x2 - x1;
			x3x1 = x3 - x1;
			y2y1 = y2 - y1;
			y3y1 = y3 - y1;
			z2z1 = z2 - z1;
			z3z1 = z3 - z1;

			var denom: Float = (x3x1 * y2y1 - x2x1 * y3y1);
			
			if (denom == 0) continue;
			
			denom = 1 / denom;

			dzdx = (z3z1 * y2y1 - z2z1 * y3y1) * denom;
			dzdy = (z2z1 * x3x1 - z3z1 * x2x1) * denom;

			// Calculate X-slopes along the edges
			dxdy1 = x2x1 / y2y1;
			dxdy2 = x3x1 / y3y1;
			dxdy3 = (x3 - x2) / (y3 - y2);
		
			// Determine which side of the poly the longer edge is on
			side = dxdy2 > dxdy1;

			if( y1 == y2 )
			{
				side = x1 > x2;
			}
			if( y2 == y3 )
			{
				side = x3 > x2;
			}
			
			if( !side )	// Longer edge is on the left side
			{
				// Calculate slopes along left edge
				dxdya = dxdy2;
				dzdya = dxdya * dzdx + dzdy;
				// Perform subpixel pre-stepping along left edge
				dy = 1 - ( y1 - y1i );
				xa = x1 + dy * dxdya;
				za = z1 + dy * dzdya;
				
				if (y1i < y2i)	// Draw upper segment if possibly visible
				{
					// Set right edge X-slope and perform subpixel pre-stepping
					xb = x1 + dy * dxdy1;
					dxdyb = dxdy1;
					drawSubTri( y1i, y2i );
				}	
				
				if (y2i < y3i)	// Draw lower segment if possibly visible
				{
					// Set right edge X-slope and perform subpixel pre-stepping
					xb = x2 + (1 - (y2 - y2i)) * dxdy3;
					dxdyb = dxdy3;
					drawSubTri( y2i, y3i );
				}
			}
			else	// Longer edge is on the right side
			{
				// Set right edge X-slope and perform subpixel pre-stepping
				dxdyb = dxdy2;
				dy = 1 - (y1 - y1i);
				xb = x1 + dy * dxdyb;
				
				if( y1i < y2i )	// Draw upper segment if possibly visible
				{
					// Set slopes along left edge and perform subpixel pre-stepping
					dxdya = dxdy1;
					dzdya = dxdy1 * dzdx + dzdy;
					xa = x1 + dy * dxdya;
					za = z1 + dy * dzdya;
					drawSubTri( y1i, y2i );
				}
				
				if( y2i < y3i )	// Draw lower segment if possibly visible
				{
					// Set slopes along left edge and perform subpixel pre-stepping
					dxdya = dxdy3;
					dzdya = dxdy3 * dzdx + dzdy;
					dy = 1 - ( y2 - y2i );
					xa = x2 + dy * dxdya;
					za = z2 + dy * dzdya;
					drawSubTri( y2i, y3i );
				}
			}
		}
	}
	private inline function drawSubTri( ys: Int, ye: Int ): Void
	{
		var dx: Float;
		while ( ys < ye )
		{
			xs = Std.int(xa);
			xe = Std.int(xb);

			zi = za + (1-(xa-xs)) * dzdx;	
			while( xs < xe )
			{
				pos = xs + ys * width;
				if( zi > buffer[pos] )
				{
					bgColor = target[pos];
					target[pos]=(((alpha * r + invAlpha * (bgColor >> 16 & 0xFF)) >> 8) << 16 | 
						  		 ((alpha * g + invAlpha * (bgColor >> 8 & 0xFF)) >> 8)  << 8  | 
						  		 ((alpha * b + invAlpha * (bgColor & 0xFF)) >> 8));
				}
				zi += dzdx;
				xs++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ys++;
		}
	}
}
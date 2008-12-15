package linda.video.pixel;
    import flash.Vector;
	import linda.math.MathUtil;
	
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	import linda.video.TriangleRenderer;
/**
 * for skybox
 */	
class TRTextureFlatNoZ extends TriangleRenderer,implements ITriangleRenderer
{
    private var dzdx: Float;
	private var dzdy: Float;
	private var dudx:Float;
	private var dudy:Float;
	private var dvdx:Float;
	private var dvdy:Float;

	private var xa: Float;
	private var xb: Float;
	private var za: Float;
	private var ua:Float;
	private var va:Float;

	private var dxdya: Float;
	private var dxdyb: Float;
	private var dzdya: Float;
	private var dudya:Float;
	private var dvdya:Float;

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
	
	private var tu1:Float;
	private var tv1:Float;
	private var tu2:Float;
	private var tv2:Float;
	private var tu3:Float;
	private var tv3:Float;
	
	private var x2x1:Float;
	private var x3x1:Float;
	private var y2y1:Float;
	private var y3y1:Float;
	private var z2z1:Float;
	private var z3z1:Float;
	private var tu2u1:Float;
	private var tu3u1:Float;
	private var tv2v1:Float;
	private var tv3v1:Float;
	
	private var y1i:Int;
	private var y2i:Int;
	private var y3i:Int;
	
	private var zi:Float;
	private var ui:Float;
	private var vi:Float;
	
	private var xs:Int;
	private var xe:Int;
	private var pos:Int;
	
	private var dxdy1:Float;
	private var dxdy2:Float;
	private var dxdy3:Float;
	
	private var tw:Int;
	private var th:Int;

	public function new() 
	{
		super();
	}
	public function drawIndexedTriangleList (vertices : Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int): Void
	{
		texVector = texture.getVector(0);
	    texWidth  = texture.getWidth(0);
		texHeight = texture.getHeight(0);
		tw = texWidth - 1;
		th = texHeight - 1;
		perspectiveCorrect = true;
		
		
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
			
			x1 = v1.x + .5;
			y1 = v1.y + .5;
			x2 = v2.x + .5;
			y2 = v2.y + .5;
			x3 = v3.x + .5;
			y3 = v3.y + .5;
			z1 = v1.z;
			z2 = v2.z;
			z3 = v3.z;

			tu1 = v1.u * tw * z1; tv1 = v1.v * th * z1;
			tu2 = v2.u * tw * z2; tv2 = v2.v * th * z2;
			tu3 = v3.u * tw * z3; tv3 = v3.v * th * z3;

			y1i = Std.int(y1);
			y2i = Std.int(y2);
			y3i = Std.int(y3);
			
			x2x1 = x2 - x1;
			x3x1 = x3 - x1;
			y2y1 = y2 - y1;
			y3y1 = y3 - y1;
			z2z1 = z2 - z1;
			z3z1 = z3 - z1;
			
			tu2u1 = tu2 - tu1;
			tu3u1 = tu3 - tu1;
			tv2v1 = tv2 - tv1;
			tv3v1 = tv3 - tv1;


			var denom: Float = (x3x1 * y2y1 - x2x1 * y3y1);

			if (denom == 0) continue;
			
			denom = 1 / denom;

			dzdx = (z3z1 * y2y1 - z2z1 * y3y1) * denom;
			dudx = (tu3u1 * y2y1 - tu2u1 * y3y1) * denom;
			dvdx = (tv3v1 * y2y1 - tv2v1 * y3y1) * denom;

			dzdy = (z2z1 * x3x1 - z3z1 * x2x1) * denom;
			dudy = (tu2u1 * x3x1 - tu3u1 * x2x1) * denom;
			dvdy = (tv2v1 * x3x1 - tv3v1 * x2x1) * denom;

			// Calculate X-slopes along the edges
			dxdy1 = x2x1 / y2y1;
			dxdy2 = x3x1 / y3y1;
			dxdy3 = (x3-x2) / (y3-y2);
		
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
			
			if( side==false )	// Longer edge is on the left side
			{
				// Calculate slopes along left edge
				dxdya = dxdy2;
				dzdya = dxdya * dzdx + dzdy;
				dudya = dxdya * dudx + dudy;
				dvdya = dxdya * dvdx + dvdy;
				// Perform subpixel pre-stepping along left edge
				dy = 1 - ( y1 - y1i );
				xa = x1 + dy * dxdya;
				za = z1 + dy * dzdya;
				ua = tu1 + dy * dudya;
				va = tv1 + dy * dvdya;
				
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
					dudya = dxdy1 * dudx + dudy;
				    dvdya = dxdy1 * dvdx + dvdy;

					xa = x1 + dy * dxdya;
					za = z1 + dy * dzdya;
					ua = tu1 + dy * dudya;
					va = tv1 + dy * dvdya;
					drawSubTri( y1i, y2i );
				}
				
				if( y2i < y3i )	// Draw lower segment if possibly visible
				{
					// Set slopes along left edge and perform subpixel pre-stepping
					dxdya = dxdy3;
					dzdya = dxdy3 * dzdx + dzdy;
					dudya = dxdy3 * dudx + dudy;
				    dvdya = dxdy3 * dvdx + dvdy;
					dy = 1 - ( y2 - y2i );
					xa = x2 + dy * dxdya;
					za = z2 + dy * dzdya;
					ua = tu2 + dy * dudya;
					va = tv2 + dy * dvdya;
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

			dx = 1 - ( xa - xs );
			zi = za + dx * dzdx;
			ui = ua + dx * dudx;
			vi = va + dx * dvdx;
			while( xs < xe )
			{
				pos = xs + ys * width;
				
				target[pos] = texVector[Std.int(ui/zi) + Std.int(vi/zi) * texWidth];

				zi += dzdx;
				ui += dudx;
				vi += dvdx;
				xs++;
			}
			xa += dxdya;
			xb += dxdyb;
			za += dzdya;
			ua += dudya;
			va += dvdya;
			ys++;
		}
	}
}
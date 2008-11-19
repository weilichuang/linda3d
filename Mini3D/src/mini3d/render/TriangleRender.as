package mini3d.render
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import mini3d.core.Material;
	import mini3d.core.Triangle3D;
	import mini3d.core.Vertex4D;

	public class TriangleRender implements ITriangleRender
	{
		private var _matrix:Matrix;
		public function TriangleRender()
		{
			_matrix=new Matrix();
		}
        public function drawTriangleList(triangles:Array,triangleCount:int):void
        {
        	
        	var i:int;
			var tri:Triangle3D;
			var p0:Vertex4D ;
			var p1:Vertex4D ;
		    var p2:Vertex4D ; 
		    var material:Material;
		    
		    //修改tri.matrix,并且计算z坐标
			for(i=0;i<triangleCount;i+=1)
			{
				tri = triangles[i];
				
				material=tri.material;
				
				p0 = tri.p0;
			    p1 = tri.p1;
				p2 = tri.p2;
				
				tri.z = (p0.z + p1.z + p2.z)*0.333;

				if(material.texture && tri.bitmapData)
				{
					var w:Number = tri.bitmapData.width;
					var h:Number = tri.bitmapData.height;
		
					var u0:Number = w * p0.u;
					var v0:Number = h * p0.v;
					var u1:Number = w * p1.u;
					var v1:Number = h * p1.v;
					var u2:Number = w * p2.u;
					var v2:Number = h * p2.v;
					
					// Fix perpendicular projections
					if( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) )
					{
						u0 -= (u0 > 0.05)? 0.05 : -0.05;
						v0 -= (v0 > 0.07)? 0.07 : -0.07;
					}
		
					if( u2 == u1 && v2 == v1 )
					{
						u2 -= (u2 > 0.05)? 0.04 : -0.04;
						v2 -= (v2 > 0.06)? 0.06 : -0.06;
					}

					// Precalculate matrix & correct for mip mapping
					var at :Number = ( u1 - u0 );
					var bt :Number = ( v1 - v0 );
					var ct :Number = ( u2 - u0 );
					var dt :Number = ( v2 - v0 );
		
					var m:Matrix = tri.matrix;
					m.a = at;
					m.b = bt;
					m.c = ct;
					m.d = dt;
					m.tx = u0;
					m.ty = v0;	
					m.invert();
					
					_matrix.a = p1.x - p0.x;
					_matrix.b = p1.y - p0.y;
					_matrix.c = p2.x - p0.x;
					_matrix.d = p2.y - p0.y;
					_matrix.tx = p0.x;
					_matrix.ty = p0.y;

					m.concat(_matrix);				
				}
			}
			
			// loop rest
			var len:int = triangles.length;
			for(i=triangleCount;i<len;i+=1)
			{
				tri = triangles[i];
				tri.z = 10000;
			}

        	triangles.sortOn("z", Array.NUMERIC);

        	var graphics:Graphics;
        	for(i=0;i<triangleCount;i+=1)
        	{
        		tri=triangles[i];
        		
        		material=tri.material;
        		
        		p0=tri.p0;
        		p1=tri.p1;
        		p2=tri.p2;

        		graphics=tri.target.graphics;
        		
        		if(material.fillWithLine)
        		{
        			graphics.lineStyle(1,material.lineColor,material.alpha);
        		}
        		if(tri.bitmapData)
        		{
        			graphics.beginBitmapFill(tri.bitmapData,tri.matrix,false,false);
        		}
        		else if(material.fillWithColor)
        		{
        			graphics.beginFill(material.fillColor,material.alpha)
        		}
        		
        		graphics.moveTo(p0.x,p0.y);
        		graphics.lineTo(p1.x,p1.y);
        		graphics.lineTo(p2.x,p2.y);
        		graphics.lineTo(p0.x,p0.y);
        		graphics.endFill();
        	}
        }
	}
}
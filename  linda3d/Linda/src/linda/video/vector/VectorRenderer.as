package linda.video.vector
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import linda.material.Material;
	import linda.math.*;

	internal class VectorRenderer implements IVectorRenderer
	{
		protected var target:Graphics;
		protected var rect:Rectangle=new Rectangle(0,0,1,1);
		protected var vt0:Vertex4D,vt1:Vertex4D,vt2:Vertex4D;
		protected var material:Material;
		
		protected var mipMapDistance:Number;
		protected var perspectiveCorrectDistance:Number;

		public function VectorRenderer()
		{
		}

		public function setRenderTarget(target:Graphics):void
		{
			this.target = target;
		}
		
		public function setMaterial(material:Material):void
		{
			this.material = material;
		}
		private var _matrix:Matrix=new Matrix();
		private function prepareFaces(triangles:Vector.<Face3D>, triangleCount:int):void
		{
			for(var i:int=0;i<triangleCount;i++)
			{
				var tri:Face3D = triangles[i];
				
				var p0:Vertex4D = tri.point0;
				var p1:Vertex4D = tri.point1;
				var p2:Vertex4D = tri.point2;
				
				var material:Material = tri.material;
				
				// create average z value for sorting.
				tri.z = (p0.z + p1.z + p2.z)/3;

				if(material.getTexture())
				{
					var bitmap:BitmapData = material.getTexture().getBitmapData(0);
					
					var w:Number = bitmap.width;
					var h:Number = bitmap.height;
		
					var u0:Number = w * p0.u;
					var v0:Number = h * p0.v;
					var u1:Number = w * p1.u;
					var v1:Number = h * p1.v;
					var u2:Number = w * p2.u;
					var v2:Number = h * p2.v;

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
			for(i=triangleCount;i<len;i++)
			{
				tri = triangles[i];
				tri.z = 100000;
			}
		}
		
		public function drawIndexedTriangleList (triangles:Vector.<Face3D>, triangleCount : int) : void
		{
			prepareFaces(triangles,triangleCount);
 
        	//triangles.sort(
        	//("z", Array.NUMERIC);

        	var tri:Face3D;
        	var p0:Vertex4D;
        	var p1:Vertex4D;
        	var p2:Vertex4D;
        	var material:Material;
        	var bitmapData:BitmapData;
        	var color:uint;
        	for(var i:int=0;i<triangleCount;i++)
        	{
        		tri=triangles[i];
        		
        		p0=tri.point0;
        		p1=tri.point1;
        		p2=tri.point2;
        		
        		color=( tri.point0.r << 16 | tri.point0.g << 8 | tri.point0.b );
        		
        		material=tri.material;
        		bitmapData=material.getTexture().getBitmapData(0);
        		
        		if(material.wireframe)
        		{
        			target.lineStyle(0,color,material.alpha);
        		}else if(bitmapData)
        		{
        			target.beginBitmapFill(bitmapData,tri.matrix,false,true);
        		}
        		else
        		{
        			target.beginFill(color,tri.material.alpha)
        		}
        		target.moveTo(p0.x,p0.y);
        		target.lineTo(p1.x,p1.y);
        		target.lineTo(p2.x,p2.y);
        		target.lineTo(p0.x,p0.y);
        		target.endFill();
        	}
		}
		public function setPerspectiveCorrectDistance(distance:Number=400):void
		{
			perspectiveCorrectDistance=distance;
		}
		public function setMipMapDistance(distance:Number=800):void
		{
			mipMapDistance=distance;
		}
		
	}
}
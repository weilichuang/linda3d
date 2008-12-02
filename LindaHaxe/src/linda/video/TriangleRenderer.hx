package linda.video;

	import flash.Vector;
	
	import flash.display.BitmapData;
	
	import linda.material.Material;
	import linda.math.Vertex4D;
	//Todo 设置MipMap方式需要修改
	class TriangleRenderer
	{
		private var target : Vector<UInt>;
		private var buffer : Vector<Float>;
		private var material : Material;

		private var perspectiveCorrect:Bool;
		private var perspectiveDistance:Float;
		private var mipMapDistance:Float;

		//alpha
		private var alpha:Int;
		private var invAlpha:Int;
		
		public var height:Int;
		
		public function new()
		{
			perspectiveCorrect = false;
			perspectiveDistance = 400.;
			mipMapDistance = 500.;
		}
		
		public function setVector (target : Vector<UInt>, buffer : Vector<Float>) : Void
		{
			this.target = target;
			this.buffer = buffer;
		}
		public function setHeight(height:Int):Void
		{
			this.height=height;
		}
		public function setPerspectiveCorrectDistance(?distance:Float=400.):Void
		{
			perspectiveDistance=distance;
		}
		public function setMipMapDistance(?distance:Float=500.):Void
		{
			mipMapDistance=distance;
		}
		public function setMaterial (mat : Material) : Void
		{
			material = mat;
			if(material.transparenting)
			{
				alpha = Std.int(material.alpha*0xFF);
				invAlpha = 0xFF - alpha;
			}	
		}
		/**
		*用来渲染由线段组成的物体,此类物体不需要进行光照和贴图计算等
		* @vertices  Array 点的集合
		* @vertexCount int vertices的长度
		* @indexList 点与点之间的顺序(每两个组成一条直线)
		* @indexCount int indexList.length
		*/
		public function drawIndexedLineList (vertices :Vector<Vertex4D>, vertexCount : Int, indexList : Vector<Int>, indexCount : Int): Void
		{
			var color:UInt;
			var vt0:Vertex4D;
		    var vt1:Vertex4D;
			var i:Int = 0;
			while ( i < indexCount)
			{
				var ii:Int = indexList [i];
				vt0 = vertices [ii];
				ii  = indexList [i+ 1];
				vt1 = vertices [ii];
					
				i += 2;

				color = (vt0.r << 16 | vt0.g << 8 | vt0.b );
				bresenhamdd (Std.int(vt0.x), Std.int(vt0.y),vt0.z, Std.int(vt1.x), Std.int(vt1.y),vt1.z, color);
			}
		}
		
		private inline function bresenhamdd (x0 : Int, y0 : Int, z0:Float, x1 : Int, y1 : Int, z1:Float, value : UInt ) : Void
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
				var t : Float = z1;z1 = z0;z0 = t;
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
	}


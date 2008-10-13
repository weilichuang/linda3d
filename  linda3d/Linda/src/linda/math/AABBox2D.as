package linda.math
{
	public class AABBox2D
	{
		public var minX : Number;
		public var minY : Number;
		public var maxX : Number;
		public var maxY : Number;
		public function AABBox2D (min : Vector2D = null, max : Vector2D = null)
		{
			if (min == null || max == null)
			{
				minX = 0;
				minY = 0;
				maxX = 0;
				maxY = 0;
			} 
			else
			{
				minX = min.x
				minY = min.y
		
				maxX = max.x
				maxY = max.y
			}
		}
		public function reset(x:Number,y:Number):void
		{
			    minX = x;
				minY = y;
				maxX = x;
				maxY = y;
				
		}
		public function resetVector(v:Vector2D):void
		{
			    minX = v.x;
				minY = v.y;
				maxX = v.x;
				maxY = v.y;
		}
		public function equals (other : AABBox2D) : Boolean
		{
			return minX == other.minX &&
			minY == other.minY &&
			maxX == other.maxX &&
			maxY == other.maxY;
		}
		public function addInternalPoint (point : Vector2D) : void
		{
			if (point.x > maxX)
			{
				maxX = point.x;
			}
			if (point.y > maxY)
			{
				maxY = point.y;
			}
			if (point.x < minX)
			{
				minX = point.x;
			}
			if (point.y < minY)
			{
				minY = point.y;
			}
		}
		public function addInternalPointXY (x : Number, y : Number) : void
		{
			if (x > maxX)
			{
				maxX = x;
			}
			if (y > maxY)
			{
				maxY = y;
			}
			if (x < minX)
			{
				minX = x;
			}
			if (y < minY)
			{
				minY = y;
			}
		}

		public function addInternalBox (box : AABBox2D) : void
		{
			addInternalPointXY (box.maxX, box.maxY);
			addInternalPointXY (box.minX, box.minY);
		}

		public function resetFromAABBox2D (box : AABBox2D) : void
		{
			minX = box.minX;
			minY = box.minY;
			maxX = box.maxX;
			maxY = box.maxY;
		}

		public function isPointInside (point : Vector2D) : Boolean
		{
			return ( point.x >= minX && point.x <= maxX &&
			         point.y >= minY && point.y <= maxY);
		}

		public function isPointTotalInside (point : Vector2D) : Boolean
		{
			return ( point.x > minX && point.x < maxX &&
			         point.y > minY && point.y < maxY );
		}
		
		public function getCenter () : Vector2D
		{
			return new Vector2D ( (maxX + minX) *0.5,(maxY + minY) *0.5);
		}
		public function getExtent():Vector2D
		{
			return new Vector2D( (maxX-minX)*0.5,(maxY-minY)*0.5);
		}
		
		public function repair () : void
		{
			var t : Number;
			if (minX > maxX)
			{
				t = minX;
				minX = maxX;
				maxX = t;
			}
			if (minY > maxY)
			{
				t = minY;
				minY = maxY;
				maxY = t;
			}
		}
		public function clone():AABBox2D
		{
			return new AABBox2D(new Vector2D(minX,minY),new Vector2D(maxX,maxY));
		}
		public function toString():String
		{
			var s : String = new String ("AABBox2D :\n");
			s += (int (maxX * 1000) / 1000) + "\t" + (int (maxY * 1000) / 1000) + "\n";
			s += (int (minX * 1000) / 1000) + "\t" + (int (minY * 1000) / 1000) + "\n";
			return s;
		}
	}
}

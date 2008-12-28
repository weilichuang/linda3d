package linda.math;


class Line3D
{
		public var start : Vector3;
		public var end : Vector3;
		public function new (?s : Vector3 = null, ?e : Vector3 = null)
		{
			if (s!=null)
			{
				start = s;
			}else
			{
				start = new Vector3 (0., 0., 0.);
			}
			if (e!=null)
			{
				end = e;
			}else
			{
				end = new Vector3 (0., 0., 0.);
			}
		}
		public function setLine (s : Vector3, e : Vector3) : Void
		{
			start = s;
			end = e;
		}
		public inline function getLength () : Float
		{
			var x : Float = (end.x - start.x);
			var y : Float = (end.y - start.y);
			var z : Float = (end.z - start.z);
			return MathUtil.sqrt (x * x + y * y + z * z);
		}
		public inline function getLengthSQ () : Float
		{
			var x : Float = (end.x - start.x);
			var y : Float = (end.y - start.y);
			var z : Float = (end.z - start.z);
			return (x * x + y * y + z * z);
		}
		public inline function getMiddle () : Vector3
		{
			return new Vector3 ((start.x + end.x) * 0.5, (start.y + end.y) * 0.5, (start.z + end.z) * 0.5);
		}
		public inline function getVector () : Vector3
		{
			return new Vector3 (end.x - start.x, end.y - start.y, end.z - start.z);
		}
		//前提条件是该点已经在直线上
		public inline function isPointBetweenStartAndEnd (point : Vector3) : Bool
		{
			return false;//point.isBetweenPoints (start, end);
		}
		/**
		* 返回到point最近的直线上的点
		*
		*/
		public inline function getClosestPoint (point : Vector3) : Vector3
		{
			var c : Vector3 = point.subtract(start);
			var v : Vector3 = end.subtract(start);
			var d : Float = v.getLength();
			v.scaleBy(1 / d);
			var t:Float=v.dotProduct(c);
			if (t < 0)
			{
				return start;
			}else if (t > d) {
				return end;
			}else
			{
				v.scaleBy(t);
				return start.add(v);
			}
		}
		public inline function equals (other : Line3D) : Bool
		{
			if (start.equals (other.start) && end.equals (other.end))
			{
				return true;
			}else
			{
				return false;
			}
		}
	}

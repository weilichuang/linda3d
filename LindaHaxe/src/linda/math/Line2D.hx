package linda.math;


class Line2D
{
		public var start : Vector2;
		public var end : Vector2;
		public function new (?s : Vector2 = null, ?e : Vector2 = null)
		{
			if (s!=null)
			{
				start = s;
			}else
			{
				start = new Vector2 (0., 0.);
			}
			if (e!=null)
			{
				end = e;
			}else
			{
				end = new Vector2 (0., 0.);
			}
		}
		public function setLine (s : Vector2, e : Vector2) : Void
		{
			start = s;
			end = e;
		}
		public inline function getLength () : Float
		{
			var x : Float = (end.x - start.x);
			var y : Float = (end.y - start.y);
			return MathUtil.sqrt (x * x + y * y);
		}
		public inline function getLengthSQ () : Float
		{
			var x : Float = (end.x - start.x);
			var y : Float = (end.y - start.y);
			return (x * x + y * y );
		}
		public inline function getMiddle () : Vector2
		{
			return new Vector2 ((start.x + end.x) * 0.5, (start.y + end.y) * 0.5);
		}
		public inline function getVector () : Vector2
		{
			return new Vector2 (end.x - start.x, end.y - start.y);
		}
		//前提条件是该点已经在直线上
		public inline function isPointBetweenStartAndEnd (point : Vector2) : Bool
		{
			return point.isBetweenPoints (start, end);
		}
		
		//! Tests if this line intersects with another line.
		/** \param l: Other line to test intersection with.
		\param out: If there is an intersection, the location of the
		intersection will be stored in this vector.
		\return True if there is an intersection, false if not. */
		public function intersectWith(l:Line2D,out:Vector2):Bool
		{
			// Uses the method given at:
			// http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/ 
			var commonDenominator:Float = (l.end.y - l.start.y)*(end.x - start.x) -
											(l.end.x - l.start.x)*(end.y - start.y);

			var numeratorA:Float = (l.end.x - l.start.x)*(start.y - l.start.y) -
											(l.end.y - l.start.y)*(start.x -l.start.x);

			var numeratorB:Float = (end.x - start.x)*(start.y - l.start.y) -
											(end.y - start.y)*(start.x -l.start.x); 

			if(commonDenominator== 0.)
			{ 
				// The lines are either coincident or parallel
				if(numeratorA==0. && numeratorB==0.)
				{
					// Try and find a common endpoint
					if(l.start == start || l.end == start)
						out = start;
					else if(l.end == end || l.start == end)
						out = end;
					else
						// one line is contained in the other, so for lack of a better
						// answer, pick the average of both lines
						//out = ((start + end + l.start + l.end) * 0.25);
						out.x = ((start.x + end.x + l.start.x + l.end.x) * 0.25);
                        out.x = ((start.y + end.y + l.start.y + l.end.y) * 0.25);
					return true; // coincident
				}

				return false; // parallel
			}

			// Get the point of intersection on this line, checking that
			// it is within the line segment.
			var uA:Float = numeratorA / commonDenominator;
			if(uA < 0. || uA > 1.)
				return false; // Outside the line segment

			var uB:Float = numeratorB / commonDenominator;
			if(uB < 0. || uB > 1.)
				return false; // Outside the line segment

			// Calculate the intersection point.
			out.x = start.x + uA * (end.x - start.x);
			out.y = start.y + uA * (end.y - start.y);
			return true; 
		}

		//! Get unit vector of the line.
		/** \return Unit vector of this line. */
		public inline function getUnitVector():Vector2
		{
			var len:Float = (1.0 / getLength());
			return new Vector2((end.x - start.x) * len, (end.y - start.y) * len);
		}

		//! Get angle between this line and given line.
		/** \param l Other line for test.
		\return Angle in degrees. */
		public inline function getAngleWith(l:Line2D):Float
		{
			var vect:Vector2 = getVector();
			var vect2:Vector2 = l.getVector();
			return vect.getAngleWith(vect2);
		}

		//! Tells us if the given point lies to the left, right, or on the line.
		/** \return 0 if the point is on the line
		<0 if to the left, or >0 if to the right. */
		public inline function getPointOrientation(point:Vector2):Float
		{
			return ( (end.x - start.x) * (point.y - start.y) -
					(point.x - start.x) * (end.y - start.y) );
		}

		//! Check if the given point is a member of the line
		/** \return True if point is between start and end, else false. */
		public inline function isPointOnLine(point:Vector2):Bool
		{
			var d:Float = getPointOrientation(point);
			return (d == 0 && point.isBetweenPoints(start, end));
		}

		//! Get the closest point on this line to a point
		public function getClosestPoint(point:Vector2):Vector2
		{
			var c:Vector2 = point.subtract(start);
			var v:Vector2 = end.subtract(start);
			var d:Float = v.getLength();
			v.scaleBy(1 / d);
			var t:Float = v.dotProduct(c);

			if (t < 0.0) return start;
			if (t > d) return end;
            
			v.scaleBy(t);
			
			return new Vector2(start.x + v.x, start.y + v.y);
			//v *= t;
			//return start + v;
		}

		public inline function equals (other : Line2D) : Bool
		{
			return (start.equals (other.start) && end.equals (other.end));
		}
}

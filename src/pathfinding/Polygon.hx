package pathfinding;
import luxe.Vector;

class Polygon
{
	public var vertices:Array<Vector>;
	
	public function new() 
	{
		vertices = new Array<Vector>();
	}
	
	public function addPoint(x:Float, y:Float):Vector {
		var v = new Vector(x, y);
		vertices.push(v);
		return v;
	}
	
	//ported from http://www.david-gouveia.com/portfolio/pathfinding-on-a-2d-polygonal-map/
	public function pointInside(point:Vector, toleranceOnOutside:Bool = true): Bool{
		var point:Vector = point;

		var epsilon:Float = 0.5;

		var inside:Bool = false;
		// Must have 3 or more edges
		if (vertices.length < 3) return false;

		var oldPoint:Vector = vertices[vertices.length - 1];
		var oldSqDist:Float = DistanceSquared(oldPoint.x, oldPoint.y, point.x, point.y);

		for (i in 0...vertices.length)
		{
			var newPoint:Vector = vertices[i];
			var newSqDist:Float = DistanceSquared(newPoint.x, newPoint.y, point.x, point.y);

			if (oldSqDist + newSqDist + 2.0 * Math.sqrt(oldSqDist * newSqDist) - DistanceSquared(newPoint.x, newPoint.y, oldPoint.x, oldPoint.y) < epsilon) {
				return toleranceOnOutside;
			}

			var left:Vector;
			var right:Vector;
			if (newPoint.x > oldPoint.x)
			{
				left = oldPoint;
				right = newPoint;
			}
			else
			{
				left = newPoint;
				right = oldPoint;
			}

			if (left.x < point.x && point.x <= right.x && (point.y - left.y) * (right.x - left.x) < (right.y - left.y) * (point.x - left.x))
				inside = !inside;

			oldPoint = newPoint;
			oldSqDist = newSqDist;
		}

		return inside;
	}
	
	public function DistanceSquared(vx:Float, vy:Float, wx:Float, wy:Float):Float { 
		return (vx - wx)*(vx - wx) + (vy - wy)*(vy - wy);
	}
	
	
	public function distanceToSegmentSquared(px:Float, py:Float, vx:Float, vy:Float, wx:Float, wy:Float):Float {
		var l2:Float = DistanceSquared(vx,vy,wx,wy);
		if (l2 == 0) return DistanceSquared(px, py, vx, vy);
		var t:Float = ((px - vx) * (wx - vx) + (py - vy) * (wy - vy)) / l2;
		if (t < 0) return DistanceSquared(px, py, vx, vy);
		if (t > 1) return DistanceSquared(px, py, wx, wy);
		return DistanceSquared(px, py, vx + t * (wx - vx), vy + t * (wy - vy));
	}
	
	public function distanceToSegment(px, py, vx, vy, wx, wy):Float { 
		return Math.sqrt(distanceToSegmentSquared(px, py, vx, vy, wx, wy));
	}
	
	public function getClosestPointOnEdge(p3:Vector): Vector {
		var tx:Float = p3.x;
		var ty:Float = p3.y;
		var vi1:Int = -1;
		var vi2:Int = -1;
		var mindist:Float = 100000;
		
		for (i in 0...vertices.length) {
			var dist = distanceToSegment(tx, ty, vertices[i].x, vertices[i].y, vertices[(i + 1) % vertices.length].x, vertices[(i + 1) % vertices.length].y);
			if (dist < mindist) {
				mindist = dist;
				vi1 = i;
				vi2 = (i + 1) % vertices.length;
			}
		}
		var p1:Vector = vertices[vi1];
		var p2:Vector = vertices[vi2];

		var x1:Float = p1.x;
		var y1:Float = p1.y;
		var x2:Float = p2.x;
		var y2:Float = p2.y;
		var x3:Float = p3.x;
		var y3:Float = p3.y;

		var u:Float = (((x3 - x1) * (x2 - x1)) + ((y3 - y1) * (y2 - y1))) / (((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)));

		var xu:Float = x1 + u * (x2 - x1);
		var yu:Float = y1 + u * (y2 - y1);
		
		var linevector:Vector;
		if (u < 0) linevector = new Vector(x1, y1);
		else if (u>1) linevector = new Vector(x2, y2);
		else linevector = new Vector(xu, yu);
		
		return linevector;
	}
}
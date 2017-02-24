package pathfinding;
import luxe.Vector;

class PolygonMap
{

	public var vertices_concave:Array<Vector> = new Array<Vector>();
	public var polygons:Array<Polygon> = new Array<Polygon>();

	public var mainwalkgraph:Graph;
	public var walkgraph:Graph;

	public var targetx:Float;
	public var targety:Float;

	public var startNodeIndex:Int = 0;
	public var endNodeIndex:Int = 0;

	public var calculatedpath:Array<Int>;

    public function new(w:Float, h:Float):Void {
		mainwalkgraph = new Graph();
		calculatedpath = new Array<Int>();

    }

	private function Distance(v1:Vector, v2:Vector):Float {
		var dx:Float = v1.x - v2.x;
		var dy:Float = v1.y - v2.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	//ported from http://www.david-gouveia.com/portfolio/pathfinding-on-a-2d-polygonal-map/
	private function InLineOfSight(start:Vector, end:Vector) :Bool {
		var epsilon:Float = 0.5;
		// Not in LOS if any of the ends is outside the polygon
		if (!polygons[0].pointInside(start) || !polygons[0].pointInside(end)) {
			return false;
		}

		// In LOS if it's the same start and end location
		if (Vector.Subtract(start, end).length < epsilon) {
			return true;
		}
	
		// Not in LOS if any edge is intersected by the start-end line segment
		var inSight:Bool = true;
		for (polygon in polygons) {
			for (i in 0...polygon.vertices.length) {
				var v1:Vector = polygon.vertices[i];
				var v2:Vector = polygon.vertices[(i + 1) % polygon.vertices.length];
				if (LineSegmentsCross(start, end, v1, v2)) {
					//In some cases a 'snapped' endpoint is just a little over the line due to rounding errors. So a 0.5 margin is used to tackle those cases.
					if (polygon.distanceToSegment(start.x, start.y, v1.x, v1.y, v2.x, v2.y ) > 0.5 && polygon.distanceToSegment(end.x, end.y, v1.x, v1.y, v2.x, v2.y ) > 0.5) {
						return false;
					}
				}
			}
		}

		// Finally the middle point in the segment determines if in LOS or not
		var v:Vector = Vector.Add(start, end);
		var v2:Vector = new Vector(v.x / 2, v.y / 2);
		var inside:Bool = polygons[0].pointInside(v2);
		for (i in 1...polygons.length) {
			if (polygons[i].pointInside(v2, false)) {
				inside = false;
			}
		}
		return inside;
	}

	

	public function createGraph() {
		mainwalkgraph = new Graph();
		var first:Bool = true;
		vertices_concave = new Array<Vector>();
		for (polygon in polygons) {
			if (polygon != null && polygon.vertices != null && polygon.vertices.length > 2) {
				for (i in 0...polygon.vertices.length) {
					//check using boolean 'first', because the first polygon is the walkable area
					//and all other polygons are blocking polygons inside the walkabl area and for
					//those polygons we need the non-concave vertices
					if (IsVertexConcave(polygon.vertices, i) == first) {
						var index:Int = vertices_concave.length;
						vertices_concave.push(polygon.vertices[i]);
						mainwalkgraph.addNode(new GraphNode(new Vector(polygon.vertices[i].x, polygon.vertices[i].y)));
					}
				}
			}
			first = false;
		}
		for (c1_index in 0...vertices_concave.length) {
			for (c2_index in 0...vertices_concave.length) {
				var c1 = vertices_concave[c1_index];
				var c2 = vertices_concave[c2_index];
				if (InLineOfSight(c1, c2)) {
					mainwalkgraph.addEdge(new GraphEdge(c1_index, c2_index, Distance(c1, c2)));
				}
			}
		}
	}
	
	//ported from http://www.david-gouveia.com/portfolio/pathfinding-on-a-2d-polygonal-map/
	private function LineSegmentsCross(a:Vector, b:Vector, c:Vector, d:Vector) :Bool{
		var denominator:Float = ((b.x - a.x) * (d.y - c.y)) - ((b.y - a.y) * (d.x - c.x));

		if (denominator == 0)
		{
			return false;
		}

		var numerator1:Float = ((a.y - c.y) * (d.x - c.x)) - ((a.x - c.x) * (d.y - c.y));

		var numerator2:Float = ((a.y - c.y) * (b.x - a.x)) - ((a.x - c.x) * (b.y - a.y));

		if (numerator1 == 0 || numerator2 == 0)
		{
			return false;
		}

		var r:Float = numerator1 / denominator;
		var s:Float = numerator2 / denominator;

		return (r > 0 && r < 1) && (s > 0 && s < 1);
	}

	//ported from http://www.david-gouveia.com/portfolio/pathfinding-on-a-2d-polygonal-map/
	private function IsVertexConcave(vertices:Array<Vector> , vertex:Int):Bool {
		var current:Vector = vertices[vertex];
		var next:Vector = vertices[(vertex + 1) % vertices.length];
		var previous:Vector = vertices[vertex == 0 ? vertices.length - 1 : vertex - 1];

		var left:Vector = new Vector(current.x - previous.x, current.y - previous.y);
		var right:Vector = new Vector(next.x - current.x, next.y - current.y);

		var cross:Float = (left.x * right.y) - (left.y * right.x);

		return cross < 0;
	}
	
	
	public function calculatePath(from:Vector, to:Vector):Array<Int> {

		//Clone the graph, so you can safely add new nodes without altering the original graph
		walkgraph = mainwalkgraph.clone();
		var mindistanceFrom:Float = 100000;
		var mindistanceTo:Float = 100000;

		//create new node on start position
		startNodeIndex = walkgraph.nodes.length;
		if (!polygons[0].pointInside(from)) {
			from = polygons[0].getClosestPointOnEdge(from);
		}
		if (!polygons[0].pointInside(to)) {
			to = polygons[0].getClosestPointOnEdge(to);
		}

		//Are there more polygons? Then check if endpoint is inside oine of them and find closest point on edge
		if (polygons.length > 1) {
			for (i in 1...polygons.length) {
				if (polygons[i].pointInside(to)) {
					to = polygons[i].getClosestPointOnEdge(to);
					break;
				}
			}
		}
		
		targetx = to.x;
		targety = to.y;


		var startNode:GraphNode = new GraphNode(new Vector(from.x, from.y));
		var startNodeVector:Vector = new Vector(startNode.pos.x, startNode.pos.y);
		walkgraph.addNode(startNode);

		for (c_index in 0...vertices_concave.length) {
			var c = vertices_concave[c_index];
			if (InLineOfSight(startNodeVector, c)) {
				walkgraph.addEdge(new GraphEdge(startNodeIndex, c_index, Distance(startNodeVector, c)));
			}
		}


		//create new node on end position
		endNodeIndex = walkgraph.nodes.length;

		var endNode:GraphNode = new GraphNode(new Vector(to.x, to.y));
		var endNodeVector:Vector = new Vector(endNode.pos.x, endNode.pos.y);
		walkgraph.addNode(endNode);

		for (c_index in 0...vertices_concave.length) {
			var c = vertices_concave[c_index];
			if (InLineOfSight(endNodeVector, c)) {
				walkgraph.addEdge(new GraphEdge(c_index, endNodeIndex, Distance(endNodeVector, c)));
			}
		}
		if (InLineOfSight(startNodeVector, endNodeVector)) {
			walkgraph.addEdge(new GraphEdge(startNodeIndex, endNodeIndex, Distance(startNodeVector, endNodeVector)));
		}
		
		//you can switch between A* and dijkstra algorithms by commenting one and uncommenting the other
		
		var astar:AstarAlgorithm = new AstarAlgorithm(walkgraph, startNodeIndex, endNodeIndex);
		calculatedpath = astar.getPath();

		//var dijkstra:DijkstraAlgorithm = new DijkstraAlgorithm(walkgraph, startNodeIndex, endNodeIndex);
		//calculatedpath = dijkstra.getPath();
		return calculatedpath;

	}

}
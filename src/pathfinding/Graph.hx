package pathfinding;

/*
 * All pathfinding classes are based on the AactionScript 3 implementation by Eduardo Gonzalez
 * Code is ported to HaXe and modified when needed
 * http://code.tutsplus.com/tutorials/artificial-intelligence-series-part-1-path-finding--active-4439
 */
class Graph
{

	public var nodes:Array<GraphNode>;
	public var edges:Array<Array<GraphEdge>>;
	
	public function new() {
		nodes = new Array<GraphNode>();
		edges = new Array<Array<GraphEdge>>();
	}
	
	public function clone():Graph {
		var g:Graph = new Graph();
		for (n in 0...nodes.length) {
			g.nodes[n] = nodes[n].clone();
		}
		for (i in 0...edges.length) {
			g.edges[i] = new Array<GraphEdge>();
			for (e in edges[i]) {
				g.edges[i].push(e.clone());
			}
		}
		return g;
	}

	public function getEdge(from:Int,to:Int):GraphEdge {
		var from_Edges:Array<GraphEdge> = edges[from];
		for(a in 0 ... from_Edges.length)
		{
			if(from_Edges[a].to==to)
			{
				return from_Edges[a];
			}
		}
		return null;
	}

	public function addNode(node:GraphNode):Int {
		nodes.push(node);
		edges.push(new Array());
		return 0;
	}
	
	public function addEdge(edge:GraphEdge) {
		if (getEdge(edge.from, edge.to) == null) {
			edges[edge.from].push(edge);
		}
		if (getEdge(edge.to, edge.from) == null) {
			edges[edge.to].push(new GraphEdge(edge.to, edge.from, edge.cost));
		}
	}
}

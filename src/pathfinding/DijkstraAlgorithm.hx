package pathfinding;

/*
 * All pathfinding classes are based on the AactionScript 3 implementation by Eduardo Gonzalez
 * Code is ported to HaXe and modified when needed
 * http://code.tutsplus.com/tutorials/artificial-intelligence-series-part-1-path-finding--active-4439
 */
class DijkstraAlgorithm {
		
	public var graph:Graph;
	public var SPT:Array<GraphEdge>;		//This array will store the Shortest Path Three
	public var cost2Node:Array<Float>;		//This array will store the costs of getting to each node
	public var SF:Array<GraphEdge>;			//This will be our search frontier, it will contain
	public var source:Int;
	public var target:Int;

	public function new(_graph:Graph,_source:Int,_target:Int) {
		graph=_graph;
		source=_source;
		target=_target;
		
		
		SPT= new Array<GraphEdge>();
		cost2Node = new Array<Float>();
		SF = new Array<GraphEdge>();
		
		for (i in 0...graph.nodes.length) {
			cost2Node[i] = 0;
		}
		
		search();
	}
	private function search()
	{
		var pq:IndexedPriorityQueue = new IndexedPriorityQueue(cost2Node);
		pq.insert(source);
		while(!pq.isEmpty())
		{
			var NCN:Int = pq.pop();
			SPT[NCN]=SF[NCN];
			if (NCN == target) return;
			var edges:Array<GraphEdge>=graph.edges[NCN];
			
			for (edge in edges)
			{
				var nCost:Float = cost2Node[NCN]+edge.cost;
				if(SF[edge.to]==null)
				{
					cost2Node[edge.to]=nCost;
					pq.insert(edge.to);
					SF[edge.to]=edge;
				}  
				else if((nCost<cost2Node[edge.to])&&(SPT[edge.to]==null))
				{
					cost2Node[edge.to]= nCost;
					pq.reorderUp();
					SF[edge.to]=edge;
				}
			}
		}
	}
	
	public function getPath():Array<Int>
	{
		var path:Array<Int> = new Array<Int>();
		if ((target < 0) || (SPT[target] == null)) return path;
		var nd:Int = target;
		path.push(nd);
		while ((nd != source) && (SPT[nd] != null)) {
			nd = SPT[nd].from;
			path.push(nd);
		}
		path.reverse();
		return path;
	}
}
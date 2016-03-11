package pathfinding;
import luxe.Vector;

/*
 * All pathfinding classes are based on the AactionScript 3 implementation by Eduardo Gonzalez
 * Code is ported to HaXe and modified when needed
 * http://code.tutsplus.com/tutorials/artificial-intelligence-series-part-1-path-finding--active-4439
 */
class AstarAlgorithm {
	public var graph:Graph;
	public var SPT:Array<GraphEdge>;
	public var G_Cost:Array<Float>;	//This array will store the G cost of each node
	public var F_Cost:Array<Float>;	//This array will store the F cost of each node
	public var SF:Array<GraphEdge>;
	public var source:Int;
	public var target:Int;

	public function new(_graph:Graph,_source:Int,_target:Int)
	{
		graph=_graph;
		source=_source;
		target=_target;
		
		SPT= new Array<GraphEdge>();
		G_Cost = new Array<Float>();
		F_Cost = new Array<Float>();
		SF = new Array<GraphEdge>();
		
		for (i in 0...graph.nodes.length) {
			G_Cost[i] = 0;
			F_Cost[i] = 0;
		}
		
		search();
	}
	
	private function search()
	{
		var pq:IndexedPriorityQueue = new IndexedPriorityQueue(F_Cost);
		pq.insert(source);
		while(!pq.isEmpty())
		{
			var NCN:Int = pq.pop();
			SPT[NCN]=SF[NCN];
			if(NCN==target)return;
			var edges:Array<GraphEdge>=graph.edges[NCN];
			for (edge in edges)
			{
				var Hcost:Float = Vector.Subtract(graph.nodes[edge.to].pos, graph.nodes[target].pos).length;
				//var Hcost:Float = graph.nodes[edge.to].pos.distanceTo(graph.nodes[target].pos);
				var Gcost:Float = G_Cost[NCN] + edge.cost;
				var to:Int=edge.to;
				if (SF[edge.to] == null)
				{
					F_Cost[edge.to]=Gcost+Hcost;
					G_Cost[edge.to]=Gcost;
					pq.insert(edge.to);
					SF[edge.to]=edge;
				}
				else if ((Gcost < G_Cost[edge.to]) && (SPT[edge.to] == null))
				{
					F_Cost[edge.to]=Gcost+Hcost;
					G_Cost[edge.to]=Gcost;
					pq.reorderUp();
					SF[edge.to]=edge;
				}
			}
		}
	}
	
	public function getPath():Array<Int>
	{
		var path:Array<Int> = new Array();
		if(target<0) return path;
		var nd:Int = target;
		path.push(nd);
		while((nd!=source)&&(SPT[nd]!=null))
		{
			nd = SPT[nd].from;
			path.push(nd);
		}
		path.reverse();
		return path;
	}
}
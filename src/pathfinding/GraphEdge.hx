package pathfinding;

/*
 * All pathfinding classes are based on the AactionScript 3 implementation by Eduardo Gonzalez
 * Code is ported to HaXe and modified when needed
 * http://code.tutsplus.com/tutorials/artificial-intelligence-series-part-1-path-finding--active-4439
 */
class GraphEdge
{

	public var from:Int;
	public var to:Int;
	public var cost:Float;

	public function new(_from:Int,_to:Int,_cost:Float=1.0)
	{
		from = _from;
		to = _to;
		cost = _cost;
	}
	
	public function clone():GraphEdge {
		return new GraphEdge(this.from, this.to, this.cost);
	}
}
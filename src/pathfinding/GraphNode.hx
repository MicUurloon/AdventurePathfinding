package pathfinding;
import luxe.Vector;

/*
 * All pathfinding classes are based on the AactionScript 3 implementation by Eduardo Gonzalez
 * Code is ported to HaXe and modified when needed
 * http://code.tutsplus.com/tutorials/artificial-intelligence-series-part-1-path-finding--active-4439
 */
class GraphNode
	{
		public var pos:Vector;

		
		public function new(_pos:Vector)
		{
			pos=_pos;
		}
		
		public function clone():GraphNode {
			var r:GraphNode = new GraphNode(new Vector(pos.x, pos.y));
			return r;
		}
	}
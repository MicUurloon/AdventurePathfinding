package pathfinding;

/*
 * All pathfinding classes are based on the AactionScript 3 implementation by Eduardo Gonzalez
 * Code is ported to HaXe and modified when needed
 * http://code.tutsplus.com/tutorials/artificial-intelligence-series-part-1-path-finding--active-4439
 */
class IndexedPriorityQueue
{
	private var keys:Array<Float>;
	private var data:Array<Int>;
	public function new(_keys:Array<Float>)
	{
		keys=_keys;
		data = new Array<Int>();
	}
	
	public function insert(index:Int)
	{
		data[data.length] = index;
		reorderUp();
	}
	
	public function pop():Int
	{
		var r:Int=data[0];
		data[0]=data[data.length-1];
		data.pop();
		reorderDown();
		return r;
	}
	
	public function reorderUp()
	{
		var a:Int = data.length-1;
		while (a > 0) {
			if(keys[data[a]]<keys[data[a-1]])
			{
				var tmp:Int=data[a];
				data[a]=data[a-1];
				data[a-1]=tmp;
			}
			else return;
			a--;
		}
	}
	
	public function reorderDown()
	{
		for(a in 0...data.length-1)
		{
			if(keys[data[a]]>keys[data[a+1]])
			{
				var tmp:Int=data[a];
				data[a]=data[a+1];
				data[a+1]=tmp;
			}
			else return;
		}
	}
	
	public function isEmpty():Bool
	{
		return (data.length==0);
	}
}
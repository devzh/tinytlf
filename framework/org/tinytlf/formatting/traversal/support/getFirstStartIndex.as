package org.tinytlf.formatting.traversal.support
{
	import asx.array.first;
	import asx.array.pluck;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	
	import trxcllnt.ds.HRTree;
	
	/**
	 * @author ptaylor
	 */
	public function getFirstStartIndex(bounds:Edge, cache:HRTree):int {
		const intersections:Array = getIntersections(bounds, cache);
		const item:Element = first(intersections) as Element;
		return item ? item.index : 0;
	}
}

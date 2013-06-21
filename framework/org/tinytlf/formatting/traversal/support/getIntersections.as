package org.tinytlf.formatting.traversal.support
{
	import asx.array.pluck;
	
	import org.tinytlf.Edge;
	
	import trxcllnt.ds.HRTree;

	/**
	 * @author ptaylor
	 */
	public function getIntersections(bounds:Edge, cache:HRTree):Array {
		rectangle.setTo(bounds.left, bounds.top, bounds.width, bounds.height);
		
		const intersections:Array = pluck(cache.search(rectangle), 'item');
		intersections.sortOn('index', Array.NUMERIC);
		
		return intersections;
	}
}
import flash.geom.Rectangle;

internal const rectangle:Rectangle = new Rectangle();
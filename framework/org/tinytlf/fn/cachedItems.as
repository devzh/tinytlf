package org.tinytlf.fn
{
	import asx.array.pluck;
	
	import flash.geom.Rectangle;
	
	import trxcllnt.ds.HRTree;

	/**
	 * @author ptaylor
	 */
	public function cachedItems(cache:HRTree, area:Rectangle):Array/*<Values>*/ {
		const cached:Array = pluck(cache.search(area), 'item');
		cached.sortOn('index', Array.NUMERIC);
		return cached;
	}
}
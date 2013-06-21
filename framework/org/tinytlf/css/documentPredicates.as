package org.tinytlf.css
{
	import asx.fn.I;
	import asx.fn.aritize;
	import asx.fn.memoize;
	import asx.fn.partial;
	import asx.object.newInstance;
	
	/**
	 * @author ptaylor
	 */
	internal const documentPredicates:Function = memoize(aritize(partial(newInstance, Array), 0), I);
}
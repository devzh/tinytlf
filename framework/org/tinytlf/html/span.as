package org.tinytlf.html
{
	import asx.fn.sequence;
	
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	
	import org.tinytlf.flash.toElementFormat;
	import org.tinytlf.xml.wrapTextNodes;
	
	import raix.interactive.toEnumerable;

	/**
	 * @author ptaylor
	 */
	public function span(render:Function, value:XML):ContentElement {
		
		const contents:Array = toEnumerable(value.children()).
			map(sequence(wrapTextNodes, render)).
			toArray();
		
		return new GroupElement(Vector.<ContentElement>(contents), toElementFormat(null));
	}
}

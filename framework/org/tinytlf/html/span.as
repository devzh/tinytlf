package org.tinytlf.html
{
	import asx.fn.sequence;
	
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	
	import org.tinytlf.CSS;
	import org.tinytlf.flash.toElementFormat;
	import org.tinytlf.xml.readKey;
	import org.tinytlf.xml.wrapTextNodes;
	
	import raix.interactive.toEnumerable;

	/**
	 * @author ptaylor
	 */
	public function span(css:CSS, render:Function, value:XML):ContentElement {
		
		const contents:Array = toEnumerable(value.children()).
			map(sequence(wrapTextNodes, render)).
			toArray();
		
		const styles:Object = css.lookup(readKey(value));
		
		return new GroupElement(Vector.<ContentElement>(contents), toElementFormat(styles));
	}
}

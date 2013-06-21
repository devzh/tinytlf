package org.tinytlf.formatting.layouts
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	
	public function cascadeLayout(document:Element, element:Element, currentLayout:Function = null):Function {
		
		if(currentLayout == null || isLayoutRoot(element)) {
			return layout(document, element, [], []);
		}
		
		return currentLayout;
	}
}

import org.tinytlf.Element;

internal function isLayoutRoot(element:Element):Boolean {
	
	const isRoot:Boolean = element.isRoot();
	const isFloated:Boolean = element.floated('none') == false;
	const canOverflow:Boolean = element.overflowed('visible') == false;
	const isBlockRoot:Boolean = element.displayed('inline-block', 'inline-table', 'table-row', 'table-cell', 'table-caption');
	const isPositioned:Boolean = element.positioned('static', 'relative') == false;
	
	// TODO: Block progression check
	
	return isRoot || isFloated || canOverflow || isBlockRoot || isPositioned;
}

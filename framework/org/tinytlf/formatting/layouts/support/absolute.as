package org.tinytlf.formatting.layouts.support
{
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	
	/**
	 * @author ptaylor
	 */
	internal function absolute(element:Element):Element {
		const constraints:Edge = element.constraints;
		return element.
			size(constraints.width, constraints.height, Element.LOCAL, Element.INLINE).
			move(constraints.left, constraints.top, Element.LOCAL, Element.INLINE);
	}

}
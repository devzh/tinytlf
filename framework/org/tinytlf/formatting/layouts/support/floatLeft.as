package org.tinytlf.formatting.layouts.support
{
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	
	/**
	 * @author ptaylor
	 */
	internal function floatLeft(flowRoot:Element,
								left:Element,
								right:Element,
								element:Element,
								inline:Boolean = false):Element {
		
		const flowBounds:Edge = flowRoot.inside();
		const margins:Edge = element.margins;
		
		var availableWidth:Number = 0;
		
		if(left) {
			const gap:Number = inline ? flowRoot.getStyle('space-width') : 0;
			const leftBounds:Edge = left.bounds(inline ? Element.INLINE : Element.LOCAL);
			const leftMargins:Edge = left.margins;
			
			if(element.cleared('left', 'both') || left.cleared('right', 'both')) {
				return flowAroundLeft(0, flowRoot, left, element, inline);
			} else {
				if(right) {
					const rightBounds:Edge = right.bounds();
					const rightMargins:Edge = right.margins;
					
					// Only position "between" the floats if the right float
					// vertically intersects with the left float.
					if( rightBounds.top <= leftBounds.bottom &&
						rightBounds.bottom >= leftBounds.top) {
						
						availableWidth = (rightBounds.left - rightMargins.left) - (leftBounds.right + leftMargins.right) - (gap * 2);
						
						return flowAroundLeft(availableWidth, flowRoot, left, element, inline);
					}
				}
				
				availableWidth = flowBounds.right - gap - (leftBounds.right + leftMargins.right);
				
				return flowAroundLeft(availableWidth, flowRoot, left, element, inline);
			}
		}
		
		return element.
			size(flowBounds.width, flowBounds.height, Element.LOCAL, Element.INLINE).
			move(
				flowBounds.left + margins.left,
				flowBounds.top + margins.top,
				Element.LOCAL, Element.INLINE
			);
	}
}

import org.tinytlf.Edge;
import org.tinytlf.Element;

internal function flowAroundLeft(availableWidth:Number,
								 flowRoot:Element,
								 sibling:Element,
								 target:Element,
								 inline:Boolean = false):Element {
	
	const flowBounds:Edge = flowRoot.inside();
	const margins:Edge = target.margins;
	const siblingBounds:Edge = sibling.bounds(inline ? Element.INLINE : Element.LOCAL);
	const siblingMargins:Edge = sibling.margins;
	const gap:Number = inline ? flowRoot.getStyle('space-width') : 0;
	
	if(availableWidth > target.width + margins.left + margins.right) {
		return target.
			size(
				availableWidth - margins.left - margins.right,
				flowBounds.height,
				Element.LOCAL, Element.INLINE
			).move(
				siblingBounds.right + siblingMargins.right + margins.left + gap,
				siblingBounds.top - siblingMargins.top + margins.top,
				Element.LOCAL, Element.INLINE
			);
	}
	
	return target.
		size(
			flowBounds.width - margins.left - margins.right,
			flowBounds.height,
			Element.LOCAL, Element.INLINE
		).move(
			flowBounds.left + margins.left,
			siblingBounds.bottom + siblingMargins.bottom + margins.top,
			Element.LOCAL, Element.INLINE
		);
}

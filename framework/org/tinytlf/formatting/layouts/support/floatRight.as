package org.tinytlf.formatting.layouts.support
{
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	
	/**
	 * @author ptaylor
	 */
	internal function floatRight(flowRoot:Element,
								 right:Element,
								 left:Element,
								 element:Element,
								 inline:Boolean = false):Element {
		
		const flowBounds:Edge = flowRoot.inside();
		const margins:Edge = element.margins;
		
		var availableWidth:Number = 0;
		
		if(right) {
			const gap:Number = inline ? flowRoot.getStyle('space-width') : 0;
			const rightBounds:Edge = right.bounds(inline ? Element.INLINE : Element.LOCAL);
			const rightMargins:Edge = right.margins;
			
			if(element.cleared('right', 'both') || right.cleared('left', 'both')) {
				return flowAroundRight(0, flowRoot, right, element, inline);
			} else {
				if(left) {
					const leftBounds:Edge = left.bounds();
					const leftMargins:Edge = left.margins;
					
					// Only position "between" the floats if the left float vertically
					// intersects with the right float.
					if(leftBounds.top <= rightBounds.bottom &&
						leftBounds.bottom >= rightBounds.top) {
						
						availableWidth = (rightBounds.left - rightMargins.left) - (leftBounds.right + leftMargins.right) - (gap * 2);
						
						return flowAroundRight(availableWidth, flowRoot, right, element, inline);
					}
				}
				
				availableWidth = flowBounds.width - gap - (leftBounds.right + leftMargins.right);
				
				return flowAroundRight(availableWidth, flowRoot, right, element, inline);
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

internal function flowAroundRight(availableWidth:Number,
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
			).
			move(
				siblingBounds.right - availableWidth - margins.right - gap,
				siblingBounds.top - siblingMargins.top + margins.top,
				Element.LOCAL, Element.INLINE
			);
	}
	
	return target.
		size(
			flowBounds.width - margins.left - margins.right,
			flowBounds.height,
			Element.LOCAL, Element.INLINE
		).
		move(
			flowBounds.width - target.width - margins.right,
			siblingBounds.bottom + siblingMargins.bottom + margins.top,
			Element.LOCAL, Element.INLINE
		);
}


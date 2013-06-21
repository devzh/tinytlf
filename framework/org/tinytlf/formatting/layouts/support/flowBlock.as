package org.tinytlf.formatting.layouts.support
{
	import asx.array.first;
	import asx.array.last;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function flowBlock(flowed:Array,
							  container:Element,
							  element:Element):Element {
		
		const collaborator:Element = last(flowed) as Element;
		const bounds:Edge = container.inside();
		const borders:Edge = container.borders;
		const margins:Edge = container.margins;
		const padding:Edge = container.padding;
		
		const margins2:Edge = element.margins;
		
		element.size(
			bounds.width - margins2.left - margins2.right,
			bounds.height,
			Element.LOCAL, Element.INLINE
		);
		
		if(collaborator == null) {
			return element.move(
				bounds.left + margins2.left,
				bounds.top + margins2.top,
				Element.LOCAL, Element.INLINE
			);
		}
		
		// If our container was the last positioned element, attempt to collapse
		// the margins with this element.
		if(collaborator == container) {
			
			// If our container isn't the only collaborator, collapse the margins
			// between the previous collaborator, the container, and this element.
			if(flowed.length > 1) {
				
				const collaborator2:Element = Element(first(flowed.slice(-2)));
				const margins3:Edge = collaborator2.margins;
				
				if(container.depth == collaborator2.depth) {
					// If the previous collaborator is inline, ignore its margins and
					// only collapse between the container and the element.
					if(collaborator2.displayed('inline')) {
						container.move(
							container.x,
							collaborator2.y +
							collaborator2.height +
							Math.max(margins.top, margins2.top),
							Element.LOCAL, Element.INLINE
						);
						
						return element.move(bounds.left + margins2.left, 0, Element.LOCAL, Element.INLINE);
					}
					
					if(collaborator2.displayed('block')) {
						// If the previous collaborator isn't a block, only collapse
						// between the container and the element. Update the container's Y,
						// set the element's Y to 0.
						container.move(
							container.x,
							collaborator2.y +
							collaborator2.height +
							margins3.bottom +
							Math.max(margins.top, margins2.top),
							Element.LOCAL, Element.INLINE
						);
						
						return element.move(bounds.left + margins2.left, 0, Element.LOCAL, Element.INLINE);
					}
					
					if(padding.top <= 0 && borders.top <= 0) {
						// If the previous collaborator is a block and the container has
						// no padding or borders between the previous collaborator and
						// the element, update the container's position to the collapsed
						// margin and set the element Y to 0.
						
						container.move(
							container.x,
							collaborator2.y +
							collaborator2.height +
							margins3.bottom +
							Math.max(margins.top, margins2.top, margins3.bottom),
							Element.LOCAL, Element.INLINE
						);
						
						return element.move(bounds.left + margins2.left, 0, Element.LOCAL, Element.INLINE);
					}
				}
				
				// If the previous collaborator isn't a block or there's
				// padding or borders, leave the container alone and position
				// the element relative to the parent.
				return element.move(
					bounds.left + margins2.left,
					bounds.top + margins2.top,
					Element.LOCAL, Element.INLINE
				);
			}
			
			// If there isn't a previous collaborator and there's no padding or
			// borders on the container, collapse the margins between the container
			// and the element. Update the container's Y and set the element's Y to 0.
			if(padding.top <= 0 && borders.top <= 0) {
				container.move(
					container.x,
					container.y - margins.top + Math.max(margins.top, margins2.top),
					Element.LOCAL, Element.INLINE
				);
				
				return element.move(bounds.left + margins2.left, 0, Element.LOCAL, Element.INLINE);
			}
			
			// Otherwise, just position the element relative to the container.
			return element.move(
				bounds.left + margins2.left,
				bounds.top + margins2.top,
				Element.LOCAL, Element.INLINE
			);
		}
		
		// Collapse margins between block-level collaborators.
		if(collaborator.displayed('block')) {
			return element.move(
				bounds.left + margins2.left,
				collaborator.y + collaborator.height + Math.max(margins.bottom, margins2.top),
				Element.LOCAL, Element.INLINE
			);
		}
		
		// Otherwise don't collapse the margins
		return element.move(
			bounds.left + margins2.left,
			collaborator.y + collaborator.height + margins.bottom + margins2.top,
			Element.LOCAL, Element.INLINE
		);
	}
}
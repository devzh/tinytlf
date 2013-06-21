package org.tinytlf.formatting.layouts.support
{
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	
	import raix.reactive.scheduling.Scheduler;
	
	/**
	 * @author ptaylor
	 */
	public function layout2(floats:Array,
							flowed:Array,
							document:Element,
							flowRoot:Element,
							container:Element):Function {
		
		return function(element:Element, addToFlowCache:Boolean = true):Element {
			
			if(element.positioned('fixed', 'absolute')) return element;
			
			if(element.floated('left', 'right') && addToFlowCache) {
				// If the element is floated, add it to the floated elements cache.
				floats.push(element);
			} else {
				
				if(addToFlowCache) {
					// After we've finished rendering an element, put it at the
					// end of the flowed cache so it becomes the nearest
					// collaborator for its siblings.
					flowed.push(element);
					
					// memory optimization -- only hold on to the last two flowed elements.
					if(flowed.length >= 3) flowed.splice(0, flowed.length - 2);
				}
				
				if(element.hasInlineBounds) {
					
					// Update the inline bounds of the container from the
					// inline bounds of the child element.
					
					const cInlineBounds:Edge = container.bounds(Element.INLINE);
					const eInlineBounds:Edge = element.bounds(Element.INLINE);
					
					container.
						move(
							Math.min(cInlineBounds.left,	eInlineBounds.left),
							Math.min(cInlineBounds.top,		eInlineBounds.top),
							Element.INLINE
						).
						size(
							Math.max(cInlineBounds.width,	eInlineBounds.width),
							Math.max(cInlineBounds.height,	eInlineBounds.height),
							Element.INLINE
						);
				}
				
				const eBounds:Edge = element.bounds();
				
				if(element.numChildren == 0) {
					
					const eEdges:Edge = element.bordersCollapsed ?
						element.padding.subtractFrom(element.borders) :
						element.padding.addTo(element.borders);
					
					element.size(
						Math.max(eBounds.width, eEdges.left + eEdges.right),
						eEdges.top + eEdges.bottom,
						Element.LOCAL, Element.INLINE
					);
				}
				
				const cBounds:Edge = container.bounds();
				const cEdges:Edge = container.padding.addTo(container.borders);
				
				// Finalize the size of the container based on the positions and sizes of its children.
				container.size(
					Math.max(
						cBounds.width,
						cEdges.left + cEdges.right + eBounds.width
					),
					cEdges.bottom + eBounds.bottom
				);
			}
			
			return element;
		}
	}
}
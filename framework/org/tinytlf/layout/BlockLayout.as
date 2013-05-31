package org.tinytlf.layout
{
	import org.tinytlf.Edge;
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFBlockContainer;
	import org.tinytlf.TTLFLayout;
	
	public class BlockLayout implements TTLFLayout
	{
		public function BlockLayout(documentRoot:TTLFBlock, flowRoot:TTLFBlock)
		{
			dRoot = documentRoot;
			fRoot = flowRoot;
		}
		
		protected var dRoot:TTLFBlock;
		protected var fRoot:TTLFBlock;
		protected const floatedBlocks:Array = [];
		protected const flowedBlocks:Array = [];
		
		public function approximatePosition(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout
		{
			if(child.positioned('fixed')) {
				positionWithRespectTo(child, dRoot);
			} else if(child.positioned('absolute')) {
				positionWithRespectTo(child, fRoot);
			} else if(child.floated('left')) {
				floatedBlocks.push(approximateLeftFloat(floatedBlocks, container, child));
			} else if(child.floated('right')) {
				floatedBlocks.push(approximateRightFloat(floatedBlocks, container, child));
			} else if(child.displayed('inline')) {
				flowedBlocks.push(approximateInline(flowedBlocks, container, child));
			} else if(child.displayed('inline-block')) {
				flowedBlocks.push(approximateInlineBlock(flowedBlocks, container, child));
			} else if(child.displayed('block')) {
				flowedBlocks.push(approximateBlock(flowedBlocks, container, child));
			}
			
			return this;
		}
		
		public function approximateSize(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout
		{
			const borders:Edge = container.borders;
			const padding:Edge = container.padding;
			const margins:Edge = child.margins;
			
			const availableWidth:Number = container.width -
				borders.left - padding.left - margins.left - 
				borders.right - padding.right - margins.right;
			
			const availableHeight:Number = container.height;
			
			const constraints:Edge = child.constrain(availableWidth, availableHeight);
			
			child.size(constraints.right, constraints.bottom);
			
			return this;
		}
		
		public function finalizePosition(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout
		{
			
			
			return this;
		}
		
		public function finalizeSize(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout
		{
			return this;
		}
		
		public function finalize():TTLFLayout {
			floatedBlocks.length = 0;
			flowedBlocks.length = 0;
			return this;
		}
	}
}

import asx.array.last;

import org.tinytlf.Edge;
import org.tinytlf.TTLFBlock;
import org.tinytlf.TTLFBlockContainer;

internal const emptyEdge:Edge = new Edge();

internal function positionWithRespectTo(child:TTLFBlock, root:TTLFBlock):TTLFBlock {
	// TODO
	return child;
}

internal function approximateInline(flowed:Array, container:TTLFBlockContainer, child:TTLFBlock):TTLFBlock {
	return approximateInlineElement(flowed, container, child, false):
}

internal function approximateInlineBlock(flowed:Array, container:TTLFBlockContainer, child:TTLFBlock):TTLFBlock {
	return approximateInlineElement(flowed, container, child, true):
}

internal function approximateInlineElement(flowed:Array, container:TTLFBlockContainer, child:TTLFBlock, useMargin:Boolean):TTLFBlock {
	const collaborator:TTLFBlock = last(flowed) as TTLFBlock;
	
	const borders:Edge = container.borders;
	const padding:Edge = container.padding;
	
	const margins:Edge = container.margins;
	const margins2:Edge = child.margins;
	
	if(collaborator == null || collaborator == container) {
		return child.move(
			borders.left + padding.left + margins2.left,
			borders.top + padding.top + (useMargin ? margins2.top : 0)
		);
	}
	
	const margins3:Edge = collaborator.margins;
	
	if(collaborator.displayed('block')) {
		return child.move(
			borders.left + padding.left + margins2.left,
			collaborator.y + collaborator.height + margins3.bottom + (useMargin ? margins2.top : 0)
		);
	}
	
	const availableWidth:Number = container.width -
		padding.left - padding.right - 
		borders.left - borders.right - 
		collaborator.x - collaborator.width;
	
	if(availableWidth >= child.width + margins2.left + margins2.right) {
		return child.move(
			collaborator.x + collaborator.width + margins3.right,
			collaborator.y - margins3.top + (useMargin ? margins2.top : 0)
		);
	}
	
	return child.move(
		borders.left + padding.left + margins2.left,
		collaborator.y + collaborator.height + margins3.bottom + (useMargin ? margins2.top : 0)
	);
}

// TODO: Abstract this into a smaller function that gets called with the
// collapsed margin or something.
internal function approximateBlock(flowed:Array, container:TTLFBlockContainer, child:TTLFBlock):TTLFBlock {
	
	const collaborator:TTLFBlock = last(flowed) as TTLFBlock;
	const borders:Edge = container.borders;
	const margins:Edge = container.margins;
	const padding:Edge = container.padding;
	const children:Array = container.children;
	
	const margins2:Edge = child.margins;
	
	if(collaborator == null) {
		return child.move(
			borders.left + padding.left + margins2.left,
			borders.top + padding.top + margins2.top
		);
	}
	
	// If our container was the last positioned element, attempt to collapse
	// the margins with this child.
	if(collaborator == container) {
		
		// If our container isn't the only collaborator, collapse the margins
		// between the previous collaborator, the container, and this child.
		if(flowed.length > 1) {
			
			const collaborator2:TTLFBlock = flowed.slice(-2)[0] as TTLFBlock;
			const margins3:Edge = collaborator2.margins;
			
			// If the previous collaborator is inline, ignore its margins and
			// only collapse between the container and the child.
			if(collaborator2.displayed('inline')) {
				container.move(
					container.x,
					collaborator2.y +
					collaborator2.height +
					Math.max(margins.top, margins2.top)
				);
				
				return child.move(borders.left + padding.left + margins2.left, 0);
			} else if(collaborator2.displayed('inline-block') == false) {
				// If the previous collaborator isn't a block, only collapse
				// between the container and the child. Update the container's Y,
				// set the child's Y to 0.
				container.move(
					container.x,
					collaborator2.y +
					collaborator2.height +
					margins3.bottom +
					Math.max(margins.top, margins2.top)
				);
				
				return child.move(borders.left + padding.left + margins2.left, 0);
			} else if(padding.top <= 0 && borders.top <= 0) {
				// If the previous collaborator is a block and the container has
				// no padding or borders between the previous collaborator and
				// the child, update the container's position to the collapsed
				// margin and set the child Y to 0.
				
				container.move(
					container.x,
					collaborator2.y +
					collaborator2.height +
					margins3.bottom +
					Math.max(margins.top, margins2.top, margins3.bottom)
				);
				
				return child.move(borders.left + padding.left + margins2.left, 0);
			} else {
				// If the previous collaborator isn't a block or there's
				// padding or borders, leave the container alone and position
				// the child relative to the parent.
				return child.move(
					borders.left + padding.left + margins2.left,
					borders.top + padding.top + margins2.top
				);
			}
		}
		
		// If there isn't a previous collaborator and there's no padding or
		// borders on the container, collapse the margins between the container
		// and the child. Update the container's Y and set the child's Y to 0.
		if(padding.top <= 0 && borders.top <= 0) {
			container.move(
				container.x,
				Math.max(margins.top, margins2.top)
			);
			
			return child.move(borders.left + padding.left + margins2.left, 0);
		}
		
		// Otherwise, just position the child relative to the container.
		return child.move(
			borders.left + padding.left + margins2.left,
			borders.top + padding.top + margins2.top
		);
	}
	
	// Collapse margins between block-level collaborators.
	if(collaborator.displayed('block')) {
		return child.move(
			borders.left + padding.left + margins2.left,
			collaborator.y + collaborator.height + Math.max(margins.bottom, margins2.top)
		);
	}
	
	// Otherwise don't collapse the margins
	return child.move(
		borders.left + padding.left + margins2.left,
		collaborator.y + collaborator.height + margins.bottom + margins2.top
	);
}

internal function approximateLeftFloat(last:TTLFBlock, container:TTLFBlockContainer, child:TTLFBlock):TTLFBlock {
	// TODO
	return child;
}

internal function approximateRightFloat(last:TTLFBlock, container:TTLFBlockContainer, child:TTLFBlock):TTLFBlock {
	// TODO
	return child;
}

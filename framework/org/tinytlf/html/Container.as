package org.tinytlf.html
{
	import asx.array.detect;
	import asx.array.first;
	import asx.array.last;
	import asx.array.len;
	import asx.array.pluck;
	import asx.fn.partial;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.events.validateEvent;
	import org.tinytlf.events.validateEventType;
	import org.tinytlf.xml.readKey;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	import trxcllnt.ds.HRTree;
	
	public class Container extends Block implements TTLFContainer
	{
		public function Container()
		{
			super();
		}
		
		override public function set viewport(value:Rectangle):void {
			if(value.width != viewport.width)
				invalidate('cached');
			else if(value.bottom > height || unfinishedChild)
				invalidate('incomplete');
			
			super.viewport = value;
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="block")]
		public var createChild:Function;
		
		// protected var skin:TTLFSkin = new Skin();
		protected const cache:HRTree = new HRTree();
		
		public function get renderedWidth():Number {
			return cache.mbr.width;
		}
		
		public function get renderedHeight():Number {
			return cache.mbr.height;
		}
		
		protected function cachedItems(area:Rectangle):Array {
			const cached:Array = pluck(cache.search(area), 'item');
			cached.sortOn('index', Array.NUMERIC);
			return cached;
		}
		
		protected function continueRender(viewport:Rectangle, child:TTLFBlock):Boolean {
			if(cache.hasItem(child)) {
				// If the element is cached and it intersects with the
				// viewport, render it.
				return viewport.intersects(cache.find(child).boundingBox);
			}
			
			// If there's still room in the viewport, render the next element.
			return cache.mbr.bottom <= viewport.bottom;
		};
		
		private var unfinishedChild:TTLFBlock;
		private var invalidateTimeout:int = -1;
		
		override protected function draw():void {
			
			if(invalidateTimeout > -1) clearTimeout(invalidateTimeout);
			
			const node:XML = XML(content);
			
			const elements:XMLList = node.elements();
			
			const cached:Array = cachedItems(viewport);
			
			var elementIndex:int = 0;
			
			// The child iteration index can be out of sync with the 
			// display list index, because some XML elements don't
			// create block-level representations of themselves.
			var displayListIndex:int = 0;
			
			// Figure out which child to start processing at.
			if(isInvalid('cached')) {
				// If the size of the viewport changed such that the existing
				// children need to be re-rendered, start from the index of the
				// first visible child.
				if(len(cached) > 0) {
					elementIndex = first(cached).index;
					displayListIndex = getChildIndex(first(cached) as DisplayObject);
				}
			} else if(unfinishedChild) {
				// Else, if there's any children that didn't finish rendering,
				// start rendering there.
				elementIndex = unfinishedChild.index;
				displayListIndex = getChildIndex(unfinishedChild as DisplayObject);
			} else if(len(cached) > 0) {
				// If all our children are finished rendering, start rendering
				// from the last successfully rendered visible child.
				elementIndex = last(cached).index + 1;
				displayListIndex = getChildIndex(last(cached) as DisplayObject) + 1;
			} else {
				// In the default case, pick up from where we left off.
				elementIndex = displayListIndex = numChildren;
			}
			
			while(elementIndex < elements.length()) {
				
				const prev:Rectangle = (displayListIndex > 0) ?
					getChildAt(displayListIndex - 1).bounds :
					emptyRect;
				
				const child:TTLFBlock = createChild(elements[elementIndex]);
				
				// The createChild function can return null for a DisplayObject,
				// for example, if it's a <style/> block, or some other node
				// with no Block-level representation.
				// If the createChild function didn't return a DisplayObject
				// instance for the node, process the next node.
				if(child == null) {
					++elementIndex;
					continue;
				}
				
				if(contains(child as DisplayObject) == false)
					addChild(child as DisplayObject);
				
				// The child should set its CSS style properties here.
				child.content = elements[elementIndex];
				
				const position:Point = approximateLayout(prev, child, viewport);
				const maybeSize:Rectangle = approximateSize(position, child, viewport);
				
				child.x = position.x;
				child.y = position.y;
				child.viewport = maybeSize;
				
				// Does the child need to validate?
				// If not, process the next child.
				if(child.isInvalid() == false) {
					cache.update(child.bounds, child);
					++displayListIndex;
					++elementIndex;
					continue;
				}
				
				// If so, wait for this one to validate before processing the next one.
				child.addEventListener(validateEventType, childValidationListener(child, elements.length() - 1));
				
				break;
			}
		}
		
		protected function approximateLayout(prev:Rectangle, child:TTLFBlock, viewport:Rectangle):Point {
			const m:Number = child.getStyle('margin') || 0;
			const ml:Number = child.getStyle('marginLeft') || m;
			const mt:Number = child.getStyle('marginTop') || m;
			
			return new Point(viewport.x + ml, prev.bottom + mt);
		}
		
		protected function approximateSize(position:Point, child:TTLFBlock, viewport:Rectangle):Rectangle {
			const m:Number = child.getStyle('margin') || 0;
			const mr:Number = child.getStyle('marginRight') || m;
			const mb:Number = child.getStyle('marginBottom') || m;
			
			return new Rectangle(
				Math.max(viewport.x - position.x, 0),
				Math.max(viewport.y - position.y, 0),
				viewport.right - position.x - mr,
//				viewport.bottom - position.y - mb
//				viewport.width,
				viewport.height
			);
		}
		
		protected function finalizeDimensions(sibling:TTLFBlock, child:TTLFBlock, viewport:Rectangle):Rectangle {
			
			const prev:Rectangle = sibling ? sibling.bounds : emptyRect;
			const pm:Number  = sibling ? sibling.getStyle('margin')			|| 0  : 0;
			const pml:Number = sibling ? sibling.getStyle('marginLeft')		|| pm : 0;
			const pmt:Number = sibling ? sibling.getStyle('marginTop')		|| pm : 0;
			const pmr:Number = sibling ? sibling.getStyle('marginRight')	|| pm : 0;
			const pmb:Number = sibling ? sibling.getStyle('marginBottom')	|| pm : 0;
			
			const size:Rectangle = child.bounds.clone();
			
			const display:String = child.getStyle('display') || 'block';
			const float:String = child.getStyle('float') || 'none';
			
			const m:Number = child.getStyle('margin') || 0;
			const ml:Number = child.getStyle('marginLeft') || m;
			const mt:Number = child.getStyle('marginTop') || m;
			const mr:Number = child.getStyle('marginRight') || m;
			const mb:Number = child.getStyle('marginBottom') || m;
			
			if(float == 'left' || display == 'inline-block' || display == 'inline') {
				if(prev.right + size.width + ml > viewport.right) {
					size.x = viewport.x + ml;
					size.y = prev.bottom + mt;
				} else {
					size.x = prev.right + ml;
					size.y = prev.y - pmt + mt;
				}
			} else if(float == 'right') {
				if(prev.x - size.width - mr < viewport.left) {
					size.x = viewport.right - size.width - mr;
					size.y = prev.bottom + mt;
				} else {
					size.x = prev.x - size.width - mr;
					size.y = prev.y - pmt + mt;
				}
			} else {
				size.x = child.x;
				size.y = child.y;
			}
			
			size.width += mr;
			size.height += mb;
			
			return size;
		}
		
		private function childValidationListener(child:TTLFBlock, lastIndex:int):Function {
			
			const listener:Function = function(childValidateEvent:Event):void {
				
				childValidateEvent.stopImmediatePropagation();
				child.removeEventListener(validateEventType, listener);
				
				const rendered:Boolean = Boolean(childValidateEvent.data);
				const continueRendering:Boolean = continueRender(viewport, child);
				
				const area:Rectangle = finalizeDimensions(firstPreviousSibling(child), child, viewport);
				child.x = area.x;
				child.y = area.y;
				child.setSize(area.width, area.height);
				
				cache.update(area, child);
				
				setSize(renderedWidth, renderedHeight);
				
				if(rendered == false) {
					
					unfinishedChild = child;
					
					// Report to our parent that we're not fully rendered,
					// because at least one of our children isn't. Don't cycle
					// around for another layout pass until we have more space
					// to re-validate this unfinished child.
					dispatchEvent(validateEvent(false));
				} else {
					
					if(child == unfinishedChild)
						unfinishedChild = null;
					
					// This child is fully rendered. Are we?
					
					// Should we keep rendering?
					if(continueRendering == false) {
						dispatchEvent(validateEvent(false));
						return;
					}
					
					// We know we're done rendering children when our last child
					// reports that it's fully rendered.
					const childrenRendered:Boolean = child.index == lastIndex;
					
					// TODO: Skinning
					const skinRendered:Boolean = true;
					
					const fullyRendered:Boolean = childrenRendered && skinRendered;
					
					if(fullyRendered) {
						// Report to our parent that we're fully rendered.
						dispatchEvent(validateEvent(true));
					} else {
						// Do another layout pass, process the next child.
						invalidate('nextChild');
						// invalidateTimeout = setTimeout(partial(invalidate, 'nextChild'), 0);
					}
				}
			};
			
			return listener;
		}
		
		/**
		 * Returns the first previously rendered sibling with the same value for
		 * its css "display" value, or the first sibling with "block" display
		 * value. Returns null if no sibling was found.
		 * 
		 * @private
		 */
		private function firstPreviousSibling(child:TTLFBlock):TTLFBlock {
			const i:int = children.indexOf(child);
			
			if(i < 0) throw new Error('wot');
			if(i == 0) return null;
			
			const display:String = child.getStyle('display');
			const siblings:Array = children.slice(0, i).reverse();
			const sibling:TTLFBlock = detect(siblings, function(block:TTLFBlock):Boolean {
				const style:String = block.getStyle('display');
				return style == display || style == 'block';
			}) as TTLFBlock;
			
			// If no similar sibling was found, return the previous sibling.
			return sibling || first(siblings) as TTLFBlock;
		}
	}
}
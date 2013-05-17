package org.tinytlf.html
{
	import asx.array.detect;
	import asx.array.first;
	import asx.array.last;
	import asx.array.len;
	import asx.array.pluck;
	import asx.fn.I;
	import asx.fn.K;
	import asx.fn.apply;
	import asx.fn.distribute;
	import asx.fn.getProperty;
	import asx.fn.ifElse;
	import asx.fn.sequence;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.events.fromStarlingEvent;
	import org.tinytlf.events.renderEvent;
	import org.tinytlf.events.renderEventType;
	
	import raix.interactive.IEnumerable;
	import raix.interactive.toEnumerable;
	import raix.reactive.IObservable;
	import raix.reactive.Observable;
	import raix.reactive.scheduling.Scheduler;
	
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	
	import trxcllnt.ds.HRTree;
	
	public class Container extends Block implements TTLFContainer
	{
		public function Container()
		{
			super();
		}
		
		override public function size(w:Number, h:Number):void {
			if(width == 0) {
				invalidate('incomplete');
			} else if(w != width) {
				invalidate('cached');
			} else if(h > height) {
				invalidate('incomplete');
			}
			
			super.size(w, h);
		}
		
		override public function scroll(x:Number, y:Number):void {
			if(unfinishedChild) invalidate('incomplete');
			
			super.scroll(x, y);
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="block")]
		public var createChild:Function;
		
		// protected var skin:TTLFSkin = new Skin();
		protected const cache:HRTree = new HRTree();
		
		public function get renderedWidth():Number {
			// return cache.mbr.width;
			return cache.mbr.right;
		}
		
		public function get renderedHeight():Number {
			// return cache.mbr.height;
			return cache.mbr.bottom;
		}
		
		private static const viewportHelper:Rectangle = new Rectangle();
		
		protected function cachedItems():Array {
			viewportHelper.setTo(scrollX, scrollY, width, height);
			const cached:Array = pluck(cache.search(viewportHelper), 'item');
			cached.sortOn('index', Array.NUMERIC);
			return cached;
		}
		
		protected function continueRender(child:TTLFBlock):Boolean {
			if(cache.hasItem(child)) {
				// If the element is cached and it intersects with the
				// viewport, render it.
				
				const size:Rectangle = cache.getBounds(child);
				return size.y <= scrollY + height;
			}
			
			// If there's still room in the viewport, render the next element.
			return cache.mbr.bottom <= scrollY + height;
		};
		
		private var unfinishedChild:TTLFBlock;
		
		override protected function draw():void {
			
			// If styles have set an explicit width or height, use that instead.
			if(hasStyle('width')) actualWidth = getStyle('width');
			if(hasStyle('height')) actualHeight = getStyle('height');
			
			const node:XML = XML(content);
			
			const elements:XMLList = node.elements();
			
			const cached:Array = cachedItems();
			
			var startIndex:int = 0;
			
			const processCached:Boolean = ('cached' in _invalidationFlags);
			
			// Figure out which child to start processing at.
			if(processCached) {
				// If the size of the viewport changed such that the existing
				// children need to be re-rendered, start from the index of the
				// first visible child.
				startIndex = len(cached) ? first(cached).index : 0;
			} else if(unfinishedChild) {
				// Else, if there's any children that didn't finish rendering,
				// start rendering there.
				startIndex = unfinishedChild.index;
			} else if(len(cached) > 0) {
				// If all our children are finished rendering, start rendering
				// from the last successfully rendered visible child.
				startIndex = last(cached).index + 1;
			} else {
				// In the default case, pick up from where we left off.
				startIndex = numChildren;
			}
			
			const enumerable:IEnumerable = toEnumerable(elements, startIndex).
				map(distribute(I, createChild)).
				// Only take non-null children
				filter(last).
				// Stop if we iterate past our boundaries.
				takeWhile(sequence(last, continueRender)).
				// Add the child
				map(distribute(first, sequence(last, ifElse(contains, I, addChild)))).
				// Create an Observable that waits until the child is rendered.
				map(apply(function(node:XML, child:TTLFBlock):IObservable{
					
					const index:int = getChildIndex(child as DisplayObject);
					const prev:Rectangle = (index > 0) ? getChildAt(index - 1).bounds : null;
					
					// The child should set its CSS style properties here.
					child.content = node;
					
					const approxSize:Point = approximateSize(child);
					child.size(approxSize.x, approxSize.y);
					
					const approxPosition:Point = approximateLayout(prev, child);
					child.move(approxPosition.x, approxPosition.y);
					
					const approxScroll:Point = approximateScroll(approxPosition);
					child.scroll(approxScroll.x, approxScroll.y);
					
					if(child.isInvalid() == false) {
						cache.update(child.bounds, child);
						// Cool! No waiting required.
						return Observable.value([true, child]);
					}
					
					// Wait for the child to validate.
					return fromStarlingEvent(child as EventDispatcher, renderEventType).
						map(distribute(getProperty('data'), K(child))).
						observeOn(Scheduler.asynchronous).
						take(1);
				}));
			
			enumerable.concatMany().
				// Stop at the first child that doesn't complete rendering.
				takeWhile(apply(function(rendered:Boolean, child:TTLFBlock):Boolean {
					
					const area:Rectangle = finalizeDimensions(firstPreviousSibling(child), child);
					child.move(area.x, area.y);
					child.size(area.width, area.height);
					
					cache.update(area, child);
					
					if(rendered == false)
						unfinishedChild = child;
					
					return rendered;
				})).
				subscribe(function(...args):void {
					unfinishedChild = null;
				},
				function():void {
					
					const lastIndex:int = numChildren > 0 ? last(children).index : -1;
					
					const childrenRendered:Boolean = unfinishedChild == null && lastIndex >= elements.length() - 1;
					
					actualWidth = hasStyle('width') ? getStyle('width') : Math.max(renderedWidth, actualWidth);
					actualHeight = hasStyle('height') ? getStyle('height') : renderedHeight;
					
					// TODO: Skinning
					const skinRendered:Boolean = true;
					
					dispatchEvent(renderEvent(childrenRendered && skinRendered));
				});
		}
		
		protected function approximateLayout(prev:Rectangle, child:TTLFBlock):Point {
			
			const size:Rectangle = child.bounds.clone();
			const display:String = child.getStyle('display') || 'block';
			const float:String = child.getStyle('float') || 'none';
			
			const inner:Rectangle = innerBounds;
			
			if(float == 'left' || display == 'inline-block' || display == 'inline') {
				
				if(prev == null) return new Point(inner.x, inner.y);
				
				if(prev.right + size.width > inner.width) return new Point(inner.x, prev.bottom);
				
				return new Point(prev.right, prev.y);
			
			} else if(float == 'right') {
				
				if(prev == null) return new Point(inner.width - size.width, inner.y);
				
				if(prev.x - size.width < 0) return new Point(inner.width - size.width, prev.bottom);
				
				return new Point(prev.x - size.width, prev.y);
			}
			
			return new Point(inner.x, prev ? prev.bottom : inner.y);
		}
		
		protected function approximateSize(child:TTLFBlock):Point {
			
			const inner:Rectangle = innerBounds;
			
			const w:Number = child.hasStyle('width') ?
				child.getStyle('width') :
				inner.width;// - child['marginLeft'] - child['marginRight'];
			
			const h:Number = child.hasStyle('height') ? child.getStyle('height') : inner.height;
			
			return new Point(w, h);
		}
		
		protected function approximateScroll(position:Point):Point {
			return new Point(Math.max(scrollX - position.x, 0), Math.max(scrollY - position.y, 0));
		}
		
		protected function finalizeDimensions(sibling:TTLFBlock, child:TTLFBlock):Rectangle {
			
			const prev:Rectangle = sibling ? sibling.bounds : emptyRect;
			
			const size:Rectangle = child.bounds.clone();
			
			const display:String = child.getStyle('display') || 'block';
			const float:String = child.getStyle('float') || 'none';
			
			if(display != 'block' || float != 'none') {
				const p:Point = approximateLayout(prev, child);
				size.x = p.x;
				size.y = p.y;
			}
			
			return size;
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
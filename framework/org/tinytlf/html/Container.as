package org.tinytlf.html
{
	import asx.array.last;
	import asx.fn.I;
	import asx.fn.apply;
	import asx.fn.distribute;
	import asx.fn.partial;
	import asx.fn.sequence;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.fn.cachedItems;
	import org.tinytlf.fn.wrapTextNodes;
	
	import raix.interactive.IEnumerable;
	import raix.interactive.toEnumerable;
	
	import trxcllnt.ds.HRTree;

	public class Container extends Block implements TTLFContainer
	{
		private static const emptyRect:Rectangle = new Rectangle();
		
		public function Container(node:XML)
		{
			super(node);
		}
		
		private const _cache:HRTree = new HRTree();
		public function get cache():HRTree {
			return _cache;
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="block")]
		public var createChild:Function;
		
		override public function update(value:XML, viewport:Rectangle):TTLFBlock {
			
			// TODO: explicit and percent-based sizes
			
			// Propagate viewport updates down to the children regardless of
			// whether the viewport is invalid or not.
			
			const elements:XMLList = wrapTextNodes(value).elements();
			
			// Remove the children not on the screen anymore.
			const cached:IEnumerable = cleanDisplayList(viewport);
			const first:TTLFBlock = cached.firstOrDefault() as TTLFBlock;
			const nodes:IEnumerable = toEnumerable(elements, first == null ? 0 : first.index);
			
			var latest:Rectangle = emptyRect;
			
			const room:Function = partial(continueRender, viewport);
			
			children = nodes.
				map(distribute(I, createChild)).
				takeWhile(sequence(last, room)).
				map(apply(function(node:XML, child:TTLFBlock):TTLFBlock {
					
					latest = cache.hasItem(child) ? 
						cache.find(child).boundingBox :
						layout(latest, child, viewport);
					
					child.x = latest.x;
					child.y = latest.y;
					
					const sub:Rectangle = new Rectangle(
						Math.max(viewport.x - latest.x, 0),
						Math.max(viewport.y - latest.y, 0),
						viewport.width, viewport.height
					);
					
					child.update(node, sub);
					
					latest = child.bounds;
					latest.x = child.x;
					latest.y = child.y;
					
					cache.update(latest, child);
					
					return child;
				})).
				toArray();
			
			return this;
		}
		
		protected function cleanDisplayList(viewport:Rectangle):IEnumerable {
			return toEnumerable(cachedItems(cache, viewport));
			// const children:IEnumerable = toEnumerable(container.children);
			// const cached:IEnumerable = toEnumerable(cachedItems(cache, viewport));
			// const toRemove:IEnumerable = 
			// 
			// forEach(children.except(cached), ifElse(container.contains, container.removeChild, I));
			// 
			// return cached;
		};
		
//		override protected function areNewChildrenInView(oldViewport:Rectangle, newViewport:Rectangle):Boolean {
//			
//			if(!oldViewport) return true;
//			
//			const mbr:Rectangle = cache.mbr;
//			
//			// If the cache is smaller than the new viewport, do an update.
//			if(mbr.bottom < newViewport.bottom) return true;
//			
//			const oldViews:Array = cachedItems(cache, oldViewport);
//			const newViews:Array = cachedItems(cache, newViewport);
//			
//			// If there are different children in view, do an update.
//			if(oldViews.length != newViews.length) return true;
//			
//			// Will return true on the first pair that isn't equivalent.
//			return detect(zip(oldViews, newViews), apply(not(areEqual)));
//		}
		
		protected function continueRender(viewport:Rectangle, child:TTLFBlock):Boolean {
			if(cache.hasItem(child)) {
				// If the element is cached and it intersects with the
				// viewport, render it.
				return viewport.intersects(child.bounds);
			}
			
			// If there's still room in the viewport, render the next element.
			return cache.mbr.bottom <= viewport.bottom;
		};
		
		protected function layout(prev:Rectangle, child:TTLFBlock, viewport:Rectangle):Rectangle {
			
			// Start with the container boundaries and pare them down with our
			// layout routine.
			const rect:Rectangle = new Rectangle(0, 0, viewport.width, viewport.height);
			
			rect.x = viewport.x;
			rect.y = prev.bottom;
			
//			const display:String = child.getStyle('display') || 'block';
//			const float:String = child.getStyle('float') || 'none';
//			
//			if(display == 'block' && float == 'none') {
//				rect.x = viewport.x;
//				rect.y = prev.bottom;
//			} else if(float == 'right') {
//				if(prev.x - child.width < viewport.left) {
//					rect.x = boundaries.left - rect.width;
//					rect.y = prev.bottom;
//				} else {
//					rect.x = prev.x - rect.width;
//					rect.y = prev.y;
//				}
//			} else if(float == 'left' || display == 'inline-block' || display == 'inline') {
//				if(prev.right + rect.width > boundaries.right) {
//					rect.x = boundaries.x;
//					rect.y = prev.bottom;
//				} else {
//					rect.x = prev.right;
//					rect.y = prev.y;
//				}
//			}
			
			return rect;
		}
	}
}
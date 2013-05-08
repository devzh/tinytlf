package org.tinytlf.html
{
	import asx.array.last;
	import asx.fn.I;
	import asx.fn.apply;
	import asx.fn.distribute;
	import asx.fn.partial;
	import asx.fn.sequence;
	
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.fn.cachedItems;
	import org.tinytlf.fn.wrapTextNodes;
	
	import raix.interactive.IEnumerable;
	import raix.interactive.toEnumerable;
	
	import starling.display.DisplayObject;
	
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
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle {
			return bounds;
		}
		
		override public function get bounds():Rectangle {
			return cache.mbr.clone();
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="block")]
		public var createChild:Function;
		
		override public function update(value:XML, viewport:Rectangle):TTLFBlock {
			
			super.update(value, viewport);
			
			if(hasStyle('width')) viewport.width = getStyle('width');
			if(hasStyle('height')) viewport.height = getStyle('height');
			
			// TODO: explicit and percent-based sizes
			
			// Propagate viewport updates down to the children
			
			const elements:XMLList = wrapTextNodes(value).elements();
			
			// Remove the children not on the screen anymore.
			const cached:IEnumerable = cleanDisplayList(viewport);
			const first:TTLFBlock = cached.firstOrDefault() as TTLFBlock;
			const nodes:IEnumerable = toEnumerable(elements, first == null ? 0 : first.index);
			
			var latest:Rectangle = emptyRect;
			
			children = nodes.
				map(distribute(I, createChild)).
				takeWhile(sequence(last, partial(continueRender, viewport))).
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
		};
		
		protected function continueRender(viewport:Rectangle, child:TTLFBlock):Boolean {
			if(cache.hasItem(child)) {
				// If the element is cached and it intersects with the
				// viewport, render it.
				return viewport.intersects(cache.find(child).boundingBox);
			}
			
			// If there's still room in the viewport, render the next element.
			return cache.mbr.bottom <= viewport.bottom;
		};
		
		protected function layout(prev:Rectangle, child:TTLFBlock, viewport:Rectangle):Rectangle {
			
			// Start with the container boundaries and pare them down with our
			// layout routine.
			const bounds:Rectangle = child.bounds;
			const rect:Rectangle = new Rectangle(0, 0, viewport.width, viewport.height);
			
			const display:String = child.getStyle('display') || 'block';
			const float:String = child.getStyle('float') || 'none';
			
			if(display == 'block' && float == 'none') {
				rect.x = viewport.x;
				rect.y = prev.bottom;
			} else if(float == 'right') {
				if(prev.x - bounds.width < viewport.left) {
					rect.x = viewport.left - rect.width;
					rect.y = prev.bottom;
				} else {
					rect.x = prev.x - rect.width;
					rect.y = prev.y;
				}
			} else if(float == 'left' || display == 'inline-block' || display == 'inline') {
				if(prev.right + bounds.width > viewport.right) {
					rect.x = viewport.x;
					rect.y = prev.bottom;
				} else {
					rect.x = prev.right;
					rect.y = prev.y;
				}
			}
			
			return rect;
		}
	}
}
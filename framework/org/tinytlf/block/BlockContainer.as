package org.tinytlf.block
{
	import asx.array.first;
	import asx.array.last;
	import asx.array.len;
	import asx.fn.I;
	import asx.fn.apply;
	import asx.fn.callProperty;
	import asx.fn.distribute;
	import asx.fn.partial;
	import asx.fn.sequence;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFBlockContainer;
	import org.tinytlf.TTLFLayout;
	import org.tinytlf.TTLFStyleProxy;
	import org.tinytlf.layout.BlockLayout;
	
	import raix.interactive.IEnumerable;
	import raix.interactive.toEnumerable;
	import raix.reactive.IObservable;
	
	import starling.display.DisplayObject;
	
	import trxcllnt.ds.HRTree;
	
	public class BlockContainer extends Block implements TTLFBlockContainer
	{
		public function BlockContainer()
		{
			super();
		}
		
		public function makeRoot():BlockContainer {
			return window = this;
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="block")]
		public var createChild:Function;
		
		private var _layout:TTLFLayout = null;
		
		public function set layout(value:TTLFLayout):void {
			if(value == _layout) return;
			
			_layout = value;
			cache.clear();
			
			invalidate('layout');
		}
		
		protected function getLayout():TTLFLayout {
			return isLayoutRoot() ?
				new BlockLayout(window, this) :
				_layout;
		}
		
		protected function isLayoutRoot():Boolean {
			const node:XML = content as XML;
			const isRoot:Boolean = node ? node.parent() == null || node.localName() == 'body' : false;
			const isFloated:Boolean = floated('none') == false;
			const canOverflow:Boolean = overflowed('visible') == false;
			const isBlockRoot:Boolean = displayed('inline-block', 'inline-table', 'table-cell', 'table-caption');
			const isPositioned:Boolean = positioned('static', 'relative') == false;
			
			// TODO: Block progression check
			
			return isRoot || isFloated || canOverflow || isBlockRoot || isPositioned;
		}
		
		private var _start:* = emptyPoint;
		
		public function get start():* {
			return _start;
		}
		
		public function set start(value:*):void {
			if(_start == value) return;
			
			invalidate('start');
			_start = value;
		}
		
		protected const cache:HRTree = new HRTree();
		protected var unfinished:TTLFBlock;
		
		override protected function draw():void {
			super.draw();
			
			// I know AS3 functions are slow, but this is the most
			// straightforward way to implement the asynchronous child-rendering
			// algorithm. Attempting to keep function invocations to a minimum.
			
			_layout = getLayout();
			
			enumerate().concatMany().
				takeWhile(apply(finalizeChild)).
				subscribe(
					function(...args):void { unfinished = null; },
					finalizeBlock
				);
		}
		
		protected function enumerate():IEnumerable {
			
			const node:XML = XML(content);
			const elements:XMLList = node.elements();
			const start:Number = getStartIndex();
			
			return toEnumerable(elements, start).
				map(distribute(I, createChild)).
				takeWhile(apply(continueRender)).
				map(apply(renderChild));
		}
		
		protected function getStartIndex():int {
			
			if(start is Point) {
				
				const x:Number = Point(start).x;
				const y:Number = Point(start).y;
				
				const cached:Array = cachedItems(x, y);
				
				if(isInvalid('resized')) return len(cached) ? first(cached).index : 0;
				
				if(unfinished) return unfinished.index;
				
				if(len(cached)) return last(cached).index + 1;
				
				return 0;
			}
			
			return 0;
		}
		
		private static const viewportHelper:Rectangle = emptyRect.clone();
		
		protected function cachedItems(startX:int, startY:int):Array {
			viewportHelper.setTo(startX, startY, width, height);
			const cached:Array = pluck(cache.search(viewportHelper), 'item');
			cached.sortOn('index', Array.NUMERIC);
			return cached;
		}
		
		protected function continueRender(node:XML, child:TTLFBlock):Boolean {
			
			const startX:Number = start is Point ? Point(start).x : 0;
			const startY:Number = start is Point ? Point(start).y : 0;
			
			if(cache.hasItem(child)) {
				// If the element is cached and it intersects with the
				// viewport, render it.
				
				const size:Rectangle = cache.getBounds(child);
				return (size.x <= startX + width && size.y <= startY + height);
			}
			
			const mbr:Rectangle = cache.mbr;
			
			// If there's still room in the viewport, render the next element.
			return (mbr.right <= startX + width && mbr.bottom <= startY + height);
		}
		
		protected function renderChild(node:XML, child:TTLFBlock):IObservable {
			
			if(child is DisplayObject) {
				if(contains(child as DisplayObject) == false) {
					addChild(child as DisplayObject);
				}
			}
			
			if(child is Block) child['window'] = window;
			
			if(child is TTLFBlockContainer) child['layout'] = _layout;
			
			child.content = node;
			
			_layout.
				approximateSize(this, child).
				approximatePosition(this, child);
			
			setChildStart(child);
			
			return child.refresh().
				map(distribute(I, K(child))).
				take(1);
		}
		
		protected function setChildStart(child:TTLFBlock):TTLFBlock {
			
			if((child is TTLFBlockContainer) == false) return child;
			
			if(start is Point) {
				
				const x:Number = Point(start).x;
				const y:Number = Point(start).y;
				
				child['start'] = new Point(Math.max(x - child.x, 0), Math.max(y - child.y, 0));
			} else {
				child['start'] = start;
			}
			
			return child;
		}
		
		protected function finalizeChild(rendered:Boolean, child:TTLFBlock):Boolean {
			
			_layout.
				finalizeSize(this, child).
				finalizePosition(this, child)
			
			cache.update(child.bounds, child);
			
			if(rendered == false) unfinished = child;
			
			return rendered;
		}
		
		protected function finalizeBlock():void {
			// TODO: If the start value isn't a point, figure out how to
			// translate it into a point, re-invalidate ourselves, and delay
			// dispatching the rendered event.
			
			// Set our actualWidth and actualHeight properties to their
			// "preferred" values based on our display property.
			
			const mbr:Rectangle = cache.mbr;
			
			if(displayed('inline-block')) {
				actualWidth = mbr.right;
			}
			
			actualHeight = mbr.bottom;
			
			if(isLayoutRoot()) _layout.finalize();
		}
	}
}
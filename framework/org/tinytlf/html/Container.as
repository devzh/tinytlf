package org.tinytlf.html
{
	import asx.array.first;
	import asx.array.forEach;
	import asx.array.last;
	import asx.array.len;
	import asx.array.pluck;
	import asx.array.zip;
	import asx.fn.I;
	import asx.fn.apply;
	import asx.fn.distribute;
	import asx.fn.ifElse;
	import asx.fn.not;
	import asx.fn.partial;
	import asx.fn.sequence;
	import asx.object.keys;
	import asx.object.values;
	
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.TTLFSkin;
	import org.tinytlf.xml.readKey;
	import org.tinytlf.xml.wrapTextNodes;
	
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
		
		protected var skin:TTLFSkin = new Skin();
		override public function set children(value:Array):void {
			super.children = [skin].concat(value);
		}
		
		private const _cache:HRTree = new HRTree();
		public function get cache():HRTree {
			return _cache;
		}
		
		protected function cachedItems(cache:HRTree, area:Rectangle):Array {
			const cached:Array = pluck(cache.search(area), 'item');
			cached.sortOn('index', Array.NUMERIC);
			return cached;
		}
		
		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle {
			return cache.mbr.clone();
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="block")]
		public var createChild:Function;
		
		private var unfinishedChildren:Array = [];
		private var lastViewport:Rectangle = emptyRect;
		
		override public function update(value:XML, viewport:Rectangle):Boolean {
			
			if(hasStyle('width')) viewport.width = getStyle('width');
			if(hasStyle('height')) viewport.height = getStyle('height');
			
			const cached:Array = cachedItems(cache, viewport);
			
			var start:int = 0;
			
			if(lastViewport.width != viewport.width) {
				start = len(cached) > 0 ? first(cached).index : 0;
			} else if(len(unfinishedChildren) > 0) {
				start = first(unfinishedChildren)[1].index;
			} else if(len(cached) > 0) {
				start = last(cached).index;
			} else {
				start = numChildren;
			}
			
			lastViewport = viewport.clone();
			
			const until:int = Math.min(unfinishedChildren.length, cached.length);
			
			const elements:XMLList = wrapTextNodes(value).elements();
			
			const unfinished:IEnumerable = toEnumerable(elements, start).take(until);
			const unrendered:IEnumerable = toEnumerable(elements, start + until);
			
			var lastNode:XML = <_/>;
			var lastRect:Rectangle = emptyRect;
			
			const add:Function = ifElse(not(contains), addChild, I);
			
			unfinishedChildren = unfinished.concat(unrendered).
				map(distribute(I, createChild)).
				filter(last).
				map(distribute(first, sequence(last, add))).
				takeWhile(sequence(last, partial(continueRender, viewport))).
				filter(apply(function(node:XML, child:TTLFBlock):Boolean {
					
					const styles:Object = css.lookup(readKey(node));
					const k:Array = keys(styles);
					const v:Array = values(styles);
					forEach(zip(k, v), apply(child.setStyle));
					
					lastNode = node;
					lastRect = cache.hasItem(child) ? 
						cache.find(child).boundingBox :
						layout(lastRect, child, viewport);
					
					child.x = lastRect.x;
					child.y = lastRect.y;
					
					const sub:Rectangle = new Rectangle(
						Math.max(viewport.x - lastRect.x, 0),
						Math.max(viewport.y - lastRect.y, 0),
						viewport.width, viewport.height
					);
					
					const fullyRendered:Boolean = child.update(node, sub);
					
					lastRect = child.bounds;
					lastRect.x = child.x;
					lastRect.y = child.y;
					
					cache.update(lastRect, child);
					
					return fullyRendered == false;
				})).
				toArray();
			
			const fullyRendered:Boolean = (unfinishedChildren.length == 0) &&
				(lastNode.childIndex() == elements.length() - 1);
			
			return fullyRendered && skin.update(this, viewport, fullyRendered);
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
		
		protected function layout(prev:Rectangle, child:TTLFBlock, viewport:Rectangle):Rectangle {
			
			// Start with the container boundaries and pare them down with our
			// layout routine.
			const bounds:Rectangle = child.bounds;
			const rect:Rectangle = new Rectangle(0, 0, viewport.width, viewport.height);
			
			const display:String = child.getStyle('display') || 'block';
			const float:String = child.getStyle('float') || 'none';
			
			const m:Number = child.getStyle('margin') || 0;
			const ml:Number = child.getStyle('marginLeft') || m;
			const mt:Number = child.getStyle('marginTop') || m;
			const mr:Number = child.getStyle('marginRight') || m;
			const mb:Number = child.getStyle('marginBottom') || m;
			
			if(display == 'block' && float == 'none') {
				rect.x = viewport.x + ml;
				rect.y = prev.bottom + mt;
			} else if(float == 'right') {
				if(prev.x - bounds.width < viewport.left) {
					rect.x = viewport.left - rect.width + ml;
					rect.y = prev.bottom + mt;
				} else {
					rect.x = prev.x - rect.width + ml;
					rect.y = prev.y + mt;
				}
			} else if(float == 'left' || display == 'inline-block' || display == 'inline') {
				if(prev.right + bounds.width > viewport.right) {
					rect.x = viewport.x + ml;
					rect.y = prev.bottom + mt;
				} else {
					rect.x = prev.right + ml;
					rect.y = prev.y + mt;
				}
			}
			
			rect.width +=  mr;
			rect.height +=  mb;
			
			rect.x = Math.ceil(rect.x);
			rect.y = Math.ceil(rect.y);
			rect.width = Math.ceil(rect.width);
			rect.height = Math.ceil(rect.height);
			
			return rect;
		}
	}
}
import flash.geom.Rectangle;

import org.tinytlf.TTLFBlock;
import org.tinytlf.TTLFSkin;

import starling.display.Quad;
import starling.display.Sprite;

internal class Skin extends Sprite implements TTLFSkin {
	
	public function Skin() {
		super();
	}
	
	private var background:Quad;
	
	public function update(block:TTLFBlock, size:Rectangle, fullyRendered:Boolean):Boolean {
		
		if(block.hasStyle('backgroundColor')) {
			
			const bgcolor:uint = block.getStyle('backgroundColor');
			
			if(background == null) {
				addChild(background = new Quad(size.width, size.height, bgcolor));
			} else {
				background.color = bgcolor;
			}
		} else if(background) {
			removeChild(background);
		}
		
		return fullyRendered;
	}
	
}
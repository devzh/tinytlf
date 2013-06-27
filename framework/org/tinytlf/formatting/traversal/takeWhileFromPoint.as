package org.tinytlf.formatting.traversal
{
	import asx.fn.I;
	import asx.fn.memoize;

	/**
	 * @author ptaylor
	 */
	
	public const takeWhileFromPoint:Function = memoize(predicate, I);
}

import asx.array.forEach;
import asx.fn._;
import asx.fn.partial;

import flash.geom.Point;
import flash.geom.Rectangle;

import org.tinytlf.Edge;
import org.tinytlf.Element;
import org.tinytlf.formatting.traversal.support.getIntersections;
import org.tinytlf.formatting.traversal.takeWhileFromPoint;

import trxcllnt.ds.HRTree;

internal function predicate(element:Element):Function {
	
	var lastBounds:Edge = Edge.empty;
	
	return function(start:Point, width:Number, height:Number):Function {
		
		return function(element:Element, cache:HRTree, layout:Function, render:Function):Function {
			
			const bounds:Edge = element.bounds().clone();
			
			return function(...args):Function {
				
				if(args.length > 0) {
					
					const child:Element = args[0];
					const dx:Number = Math.max(start.x - child.x, 0);
					const dy:Number = Math.max(start.y - child.y, 0);
					
					const factory:Function = takeWhileFromPoint(child)(new Point(dx, dy), width, height);
					
					return factory.apply(null, args);
				}
				
				const viewport:Edge = new Edge(
					start.y,
					start.x + width,
					start.y + height,
					start.x
				);
				
				if(bounds.width == lastBounds.width) {
					// Run all the previously rendered visible children through the
					// layout2 pass to add them to the proper internal flow and
					// float layout caches, so newly rendered children are laid out
					// with respect to the previous floated and flowed children.
					
					const intersections:Array = getIntersections(viewport, cache);
					
					forEach(intersections, partial(layout, _, true));
					forEach(intersections, partial(render, _, false));
					forEach(intersections, partial(render, _, true));
				}
				
				lastBounds = bounds.clone();
				
				return function(child:Element):Boolean {
					const isCached:Boolean = cache.hasItem(child);
					
					// Re-render a cached element if it intersects with the viewport.
					const rect:Rectangle = isCached ?
						cache.getBounds(child) :
						cache.mbr;
					
					return isCached ?
						// Compare the cached element's X and Y to the visible
						// region to determine if it's in view.
						(rect.x < viewport.right || rect.y < viewport.bottom) :
						// If we're processing an element that hasn't been rendered
						// yet, compare the cache MBR's right and bottom properties
						// to the visible area.
						// (Math.floor(rect.right) < Math.floor(viewport.right) ||
						Math.floor(rect.bottom) <= Math.floor(viewport.bottom)//);
				};
			}
		}
	}
}

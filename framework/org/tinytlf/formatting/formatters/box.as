package org.tinytlf.formatting.formatters
{
	import asx.fn.apply;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	import org.tinytlf.css.inheritCSSPredicates;
	import org.tinytlf.formatting.layouts.cascadeLayout;
	
	import raix.interactive.IEnumerable;
	import raix.reactive.IObservable;
	import raix.reactive.scheduling.Scheduler;
	
	import trxcllnt.ds.HRTree;
	
	/**
	 * @author ptaylor
	 */
	internal function box(getFormatter:Function,
						  document:Element):Function {
		
		const cache:HRTree = new HRTree();
		
		var unfinishedIndex:int = 0;
		
		return function(element:Element,
						getPredicate:Function, /*(element, cache, layout):Function*/
						getEnumerable:Function /*(startFactory, index):Function*/,
						getLayout:Function, /*(container):Function*/
						layout:Function,
						create:Function):IObservable/*<Element, Boolean>*/ {
			
			if(document == null) document = element;
			
			getLayout = cascadeLayout(document, element, getLayout);
			
			// Initially lay out the container before iterating through the container's children.
			if(layout != null) layout(element);
			if(create != null) create(element);
			
			const numChildren:int = element.numChildren;
			
			const inheritCSS:Function = inheritCSSPredicates(document, element);
			
			const childLayout:Function = getLayout(element);
			
			const predicateFactory:Function = getPredicate(element, cache, childLayout);
			
			const format:Function = getFormatter(document, element, predicateFactory, getLayout, childLayout);
			
			const elements:IEnumerable = getEnumerable(element, cache, predicateFactory(), unfinishedIndex);
			
			return elements.
				map(inheritCSS).
				map(format).
				concatMany(Scheduler.asynchronous).
				takeWhile(apply(childFinishedPredicate)).
				lastOrDefault().
				map(apply(mapElementFinished));
			
			function childFinishedPredicate(child:Element, finished:Boolean, render:Boolean = true):Boolean {
				
				if(render) {
					
					child.render();
					
					if(finished) cache.update(child.outerBounds.toRectangle(), child);
					else unfinishedIndex = Math.min(child.index, numChildren);
				}
				
				return finished;
			};
			
			function mapElementFinished(child:Element = null, finished:Boolean = false, render:Boolean = true):Array {
				
				unfinishedIndex = Math.min(
					child ? 
						child.index + 1 :
						unfinishedIndex,
					numChildren
				);
				
				const elementFinished:Boolean = child ?
					(finished && child.index >= numChildren - 1) :
					unfinishedIndex >= numChildren;
				
				if(layout != null) layout(element, true);
				
				return [element, elementFinished];
			};
		}
	}
}


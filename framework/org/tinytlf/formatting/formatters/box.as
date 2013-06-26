package org.tinytlf.formatting.formatters
{
	import asx.fn.K;
	import asx.fn.apply;
	import asx.fn.callProperty;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	import org.tinytlf.css.inheritCSSPredicates;
	import org.tinytlf.formatting.layouts.cascadeLayout;
	
	import raix.interactive.IEnumerable;
	import raix.reactive.IObservable;
	import raix.reactive.Observable;
	import raix.reactive.scheduling.Scheduler;
	import raix.reactive.subjects.IConnectableObservable;
	
	import trxcllnt.ds.HRTree;
	
	/**
	 * @author ptaylor
	 */
	internal function box(getFormatter:Function,
						  document:Element,
						  asynchronous:Boolean):Function {
		
		const cache:HRTree = new HRTree();
		var lastChildIndex:int = 0;
		
		return function(element:Element,
						getPredicate:Function, /*(element, cache, layout):Function*/
						getEnumerable:Function /*(startFactory, index):Function*/,
						getLayout:Function, /*(container):Function*/
						layout:Function,
						create:Function):IObservable/*<Element, Boolean>*/ {
			
			if(document == null) document = element;
			
			getLayout = cascadeLayout(document, element, getLayout);
			
			// Initially lay out the container before iterating through the container's children.
			layout(element);
			create(element);
			
			const numChildren:int = element.numChildren;
			
			const inheritCSS:Function = inheritCSSPredicates(document, element);
			
			const childLayout:Function = getLayout(element);
			
			const predicateFactory:Function = getPredicate(element, cache, childLayout);
			
			const format:Function = getFormatter(document, element, predicateFactory, getLayout, childLayout);
			
			const elements:IEnumerable = getEnumerable(element, cache, predicateFactory(), lastChildIndex);
			
			const formatted:IConnectableObservable = elements.
				map(inheritCSS).
				map(format).
				concatMany(
					// asynchronous ?
					//	Scheduler.asynchronous :
						Scheduler.synchronous
				).
				peek(apply(childFinished)).
				map(K([element, false])).
				publish().refCount();
			
			const end:IConnectableObservable = formatted.
				lastOrDefault().
				map(childrenFinished).
				publish().refCount();
			
			// Can't use skipLast(1) because skipLast doesn't dispatch values
			// until the source Observable has completed. We want to dispatch
			// values as they're reported. The 'end' Observable will dispatch
			// to this takeUntil, effectively forcing this Observable to skip
			// dispatching the last value.
			const front:IObservable = formatted.takeUntil(end);
			
			return front.merge(end);
			
			function childFinished(child:Element, finished:Boolean):void {
				
				if(finished)
					cache.update(child.outerBounds.toRectangle(), child);
				
				layout(element, true, false);
				
				lastChildIndex = Math.max(lastChildIndex, Math.min(child.index + int(finished), numChildren));
			};
			
			function childrenFinished(result:Array = null):Array {
				
				layout(element, true);
				
				element.render();
				
				return [element, lastChildIndex >= numChildren];
			};
		}
	}
}


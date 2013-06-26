package org.tinytlf.formatting.formatters
{
	import org.tinytlf.Element;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;

	/**
	 * @author ptaylor
	 */
	public function nonFormatted(element:Element,
								 getPredicate:Function, /*(element, cache, layout):Function*/
								 getEnumerable:Function, /*(startFactory, index):Function*/
								 getLayout:Function,
								 layout:Function,
								 create:Function):IObservable {
		
		if(layout != null) layout(element, true, false);
		
		return Observable.value([element, false]);
	}
}
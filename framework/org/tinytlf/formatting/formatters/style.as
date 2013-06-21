package org.tinytlf.formatting.formatters
{
	import org.tinytlf.Element;
	import org.tinytlf.css.applyCSSPredicates;
	import org.tinytlf.css.injectCSSPredicates;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;

	/**
	 * @author ptaylor
	 */
	public function style(document:Element):Function {
		return function(element:Element, ...args):IObservable {
			injectCSSPredicates(document, element.text);
			applyCSSPredicates(document, null, document);
			return Observable.value([element, true, false]);
		}
	}
}
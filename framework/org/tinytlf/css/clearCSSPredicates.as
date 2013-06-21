package org.tinytlf.css
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function clearCSSPredicates(document:Element):void {
		documentPredicates(document).length = 0;
	}
}
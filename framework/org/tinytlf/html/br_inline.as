package org.tinytlf.html
{
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextElement;

	/**
	 * @author ptaylor
	 */
	public function br_inline(...args):TextElement {
		
		return new TextElement('\n', new ElementFormat());
	}
}
package org.tinytlf.html
{
	import flash.text.engine.TextElement;
	
	import org.tinytlf.fn.toElementFormat;

	/**
	 * @author ptaylor
	 */
	public function text(value:XML):TextElement {
		return new TextElement(value.toString(), toElementFormat(null));
	}
}
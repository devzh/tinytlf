package org.tinytlf.html
{
	import flash.text.engine.TextElement;
	
	import org.tinytlf.flash.toElementFormat;

	/**
	 * @author ptaylor
	 */
	public function text(value:XML):TextElement {
		return new TextElement(value.toString(), toElementFormat(null));
	}
}
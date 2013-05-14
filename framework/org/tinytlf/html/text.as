package org.tinytlf.html
{
	import flash.text.engine.TextElement;
	
	import org.tinytlf.CSS;
	import org.tinytlf.flash.toElementFormat;
	import org.tinytlf.xml.readKey;

	/**
	 * @author ptaylor
	 */
	public function text(css:CSS, value:XML):TextElement {
		return new TextElement(value.toString(), toElementFormat(css.lookup(readKey(value))));
	}
}
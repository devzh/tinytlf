package org.tinytlf.html
{
	import org.tinytlf.CSS;
	import org.tinytlf.TTLFBlock;

	/**
	 * @author ptaylor
	 */
	public function style(css:CSS, value:XML):TTLFBlock {
		
		css.inject(value.text().toString());
		
		return null;
	}
}
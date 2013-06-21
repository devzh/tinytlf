package org.tinytlf.formatting.configuration.inline
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function getInlineFormatter(document:Element, element:Element):Function {
		
		const map:Object = formatters(document);
		const name:String = element.name;
		
		const formatter:Function = map.hasOwnProperty(name) ?
			map[name] :
			map['no-mapping'];
		
		return formatter(element);
	}
}

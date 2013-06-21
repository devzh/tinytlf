package org.tinytlf.formatting.configuration.inline
{
	import asx.array.forEach;
	import asx.fn.partial;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function mapInlineFormatter(document:Element, formatter:Function, ...names):Function {
		const map:Object = formatters(document);
		forEach(names, function(name:String):void {
			map[name] = formatter;
		});
		return partial(mapInlineFormatter, document);
	}
}
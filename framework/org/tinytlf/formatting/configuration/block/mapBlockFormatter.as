package org.tinytlf.formatting.configuration.block
{
	import asx.array.forEach;
	import asx.fn.partial;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function mapBlockFormatter(document:Element, formatter:Function, ...names):Function {
		const map:Object = formatters(document);
		forEach(names, function(name:String):void {
			map[name] = formatter;
		});
		return partial(mapBlockFormatter, document);
	}
}
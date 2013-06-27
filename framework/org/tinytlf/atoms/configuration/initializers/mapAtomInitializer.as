package org.tinytlf.atoms.configuration.initializers
{
	import asx.array.forEach;
	import asx.fn.partial;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function mapAtomInitializer(document:Element, initialize:Function, ...names):Function {
		const map:Object = atoms(document);
		forEach(names, function(name:String):void {
			map[name] = initialize;
		});
		return partial(mapAtomInitializer, document);
	}
}
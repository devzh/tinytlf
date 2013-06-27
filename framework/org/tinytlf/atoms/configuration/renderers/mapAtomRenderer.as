package org.tinytlf.atoms.configuration.renderers
{
	import asx.array.forEach;
	import asx.fn.partial;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function mapAtomRenderer(document:Element, renderer:Function, ...names):Function {
		const map:Object = atoms(document);
		forEach(names, function(name:String):void {
			map[name] = renderer;
		});
		return partial(mapAtomRenderer, document);
	}
}
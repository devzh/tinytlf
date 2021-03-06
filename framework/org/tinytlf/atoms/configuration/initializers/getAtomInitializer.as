package org.tinytlf.atoms.configuration.initializers
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function getAtomInitializer(document:Element, element:Element):Function {
		
		const map:Object = atoms(document);
		const name:String = element.name;
		
		return map.hasOwnProperty(name) ?
			map[name] :
			map['no-mapping'];
	}
}

package org.tinytlf.atoms.configuration
{
	import asx.fn.K;
	import asx.fn.aritize;
	import asx.fn.getProperty;
	import asx.fn.memoize;
	import asx.fn.partial;
	
	import org.tinytlf.Element;
	import org.tinytlf.atoms.configuration.initializers.mapAtomInitializer;
	import org.tinytlf.atoms.configuration.renderers.mapAtomRenderer;
	import org.tinytlf.atoms.initializers.starling.box;
	import org.tinytlf.atoms.renderers.starling.box;
	import org.tinytlf.atoms.renderers.starling.img;
	import org.tinytlf.atoms.renderers.starling.textline;
	
	import starling.display.DisplayObjectContainer;

	/**
	 * @author ptaylor
	 */
	public function mapStarlingAtoms(document:Element, window:DisplayObjectContainer):void {
		
		const boxInitializer:Function = org.tinytlf.atoms.initializers.starling.box(window);
		const boxRenderer:Function = org.tinytlf.atoms.renderers.starling.box(window);
		
		const lineRenderer:Function = textline(window);
		const imgRenderer:Function = img(window);
		
		mapAtomInitializer(document, boxInitializer, 'no-mapping');
		mapAtomRenderer(document,
			  boxRenderer, 'no-mapping'
			  // 'html', 'body', 'article', 'div', 'footer', 'header',
			  // 'section', 'table', 'tbody', 'tr', 'td', 'p', 'span', 'object'
			)(lineRenderer, 'line'
			)(imgRenderer, 'img'
			);
	}
}

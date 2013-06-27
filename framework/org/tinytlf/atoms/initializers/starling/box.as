package org.tinytlf.atoms.initializers.starling
{
	import asx.fn.I;
	import asx.fn.memoize;
	
	import starling.display.DisplayObject;

	/**
	 * @author ptaylor
	 */
	public const box:Function = memoize(boxForWindow, I);
}

import org.tinytlf.Element;

import starling.display.DisplayObjectContainer;
import starling.display.Sprite;

internal function boxForWindow(window:DisplayObjectContainer):Function {
	return function(element:Element):void {
		const container:Sprite = element.getStyle('ui') || new Sprite();
		element.setStyle('ui', container);
		window.addChild(container);
	}
}
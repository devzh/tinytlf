package org.tinytlf.atoms.renderers.starling
{
	import asx.fn.I;
	import asx.fn.memoize;
	
	/**
	 * @author ptaylor
	 */
	
	public const textline:Function = memoize(lineForWindow, I);
}

import flash.geom.Point;

import org.tinytlf.Element;
import org.tinytlf.atoms.initializers.starling.box;
import org.tinytlf.atoms.renderers.starling.box;

import raix.reactive.IObservable;
import raix.reactive.Observable;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;

internal function lineForWindow(window:DisplayObjectContainer):Function {
	
	const initializeBox:Function = org.tinytlf.atoms.initializers.starling.box(window);
	const renderBox:Function = org.tinytlf.atoms.renderers.starling.box(window);
	
	return function(element:Element):void {
		
		const position:Point = element.offset(Element.GLOBAL);
		
		const line:Image = element.getStyle('line');
		const lineHeight:Number = element.lineHeight;
		const renderHeight:Number = line.height;
		
		const renderOffset:Number = Math.min((lineHeight - renderHeight) * 0.5, 0);
		
		line.name = element.key;
		line.x = position.x;
		line.y = position.y + renderOffset;
		
		if(element.positioned('relative')) {
			line.x += element.left;
			line.y += element.top;
		}
		
		// Round the coords up to the nearest whole number so the lines
		// don't appear blurry when they're blitted to the Stage bitmap.
		line.x = Math.round(line.x);
		line.y = Math.round(line.y);
		
		initializeBox(element);
		renderBox(element);
		
		window.addChild(line);
	}
}

package org.tinytlf.atoms.renderers.starling
{
	import asx.fn.I;
	import asx.fn.memoize;

	/**
	 * @author ptaylor
	 */
	
	public const img:Function = memoize(imgForWindow, I);
}

import flash.display.BitmapData;
import flash.geom.Point;

import org.tinytlf.Element;
import org.tinytlf.atoms.initializers.starling.box;
import org.tinytlf.atoms.renderers.starling.box;

import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

internal function imgForWindow(window:DisplayObjectContainer):Function {
	
	const initializeBox:Function = org.tinytlf.atoms.initializers.starling.box(window);
	const renderBox:Function = org.tinytlf.atoms.renderers.starling.box(window);
	
	return function(element:Element):void {
		
		const position:Point = element.offset(Element.GLOBAL);
		const data:BitmapData = element.getStyle('image');
		const width:Number = element.width;
		const height:Number = element.height;
		
		const scale:Number = Math.min(width / data.width, height / data.height);
		const image:Image = new Image(Texture.fromBitmapData(data, true, true, scale));
		
		image.name = element.key;
		image.x = position.x;
		image.y = position.y;
		
		if(element.positioned('relative')) {
			image.x += element.left;
			image.y += element.top;
		}
		
		initializeBox(element);
		renderBox(element);
		
		window.addChild(image);
	}
}
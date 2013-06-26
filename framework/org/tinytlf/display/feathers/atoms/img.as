package org.tinytlf.display.feathers.atoms
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
import org.tinytlf.display.feathers.atoms.box;

import raix.reactive.IObservable;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

internal function imgForWindow(window:DisplayObjectContainer):Function {
	
	const drawBox:Function = box(window);
	
	return function(element:Element, asynchronous:Boolean):IObservable /*<DisplayObject>*/ {
		
		const data:BitmapData = element.getStyle('image');
		const position:Point = element.offset(Element.GLOBAL);
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
		
		return drawBox(element, asynchronous).map(function(container:Sprite):DisplayObject {
			return window.addChild(image);
		});
	}
}
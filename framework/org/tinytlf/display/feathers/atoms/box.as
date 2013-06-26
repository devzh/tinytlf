package org.tinytlf.display.feathers.atoms
{
	import asx.fn.I;
	import asx.fn.memoize;

	/**
	 * @author ptaylor
	 */
	
	public const box:Function = memoize(boxForWindow, I);
}

import asx.fn.memoize;

import flash.display.BitmapData;
import flash.geom.Point;

import org.tinytlf.Edge;
import org.tinytlf.Element;
import org.tinytlf.net.loadImage;

import raix.reactive.IObservable;
import raix.reactive.Observable;

import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;

internal function boxForWindow(window:DisplayObjectContainer):Function {
	
	return function(element:Element, asynchronous:Boolean):IObservable /*<DisplayObject>*/ {
		
		var backgroundImageObs:IObservable = Observable.empty();
		var tempQuad:Quad;
		
		const background:Sprite = new Sprite();
		const width:Number = element.width;
		const height:Number = element.height;
		const bounds:Edge = element.bounds();
		const borders:Edge = element.borders;
		const position:Point = element.offset(Element.GLOBAL);
		
		background.name = element.key;
		
		// TODO: Parse the 'background' style -- should I write a central
		// CSS attribute parsing routine and set the 'background-color' and
		// 'background-image' attributes?
		
		// const hasBackground:Boolean = element.hasStyle('background');
		const hasBackgroundColor:Boolean = element.hasStyle('backgroundColor');
		const hasBackgroundImage:Boolean = element.hasStyle('backgroundImage');
		const hasBorders:Boolean = borders.isEmpty() == false;
		
		if(/*hasBackground ||*/ hasBackgroundColor || hasBackgroundImage || hasBorders) {
			
			if(hasBackgroundImage) {
				const url:String = element.backgroundImage;
				backgroundImageObs = loadImage(url).peek(function(data:BitmapData):void {
					// Add the background image quad to the background sprite.
					background.unflatten();
					
					tempQuad = new Image(Texture.fromBitmapData(data, false, true, 1));
					tempQuad.alpha = element.backgroundImageAlpha;
					
					background.addChildAt(tempQuad, 1);
					background.flatten();
				});
			}
			
			if(hasBackgroundColor) {
				
				tempQuad = new Quad(
					width - borders.left - borders.right,
					height - borders.top - borders.bottom,
					element.backgroundColor
				);
				tempQuad.alpha = element.backgroundAlpha;
				
				background.addChild(tempQuad);
			}
			
			if(hasBorders) {
				if(borders.left > 0) {
					tempQuad = new Quad(borders.left, height, element.borderLeftColor);
					tempQuad.alpha = element.borderLeftAlpha;
					background.addChild(tempQuad);
				}
				if(borders.right > 0) {
					tempQuad = new Quad(borders.right, height, element.borderRightColor);
					tempQuad.alpha = element.borderRightAlpha;
					tempQuad.x = bounds.width - borders.right;
					background.addChild(tempQuad);
				}
				if(borders.top > 0) {
					tempQuad = new Quad(width, borders.top, element.borderTopColor);
					tempQuad.alpha = element.borderTopAlpha;
					background.addChild(tempQuad);
				}
				if(borders.bottom > 0) {
					tempQuad = new Quad(width, borders.bottom, element.borderBottomColor);
					tempQuad.alpha = element.borderBottomAlpha;
					tempQuad.y = bounds.height - borders.bottom;
					background.addChild(tempQuad);
				}
			}
			
			background.flatten();
			
			background.x = position.x;
			background.y = position.y;
			
			if(element.positioned('relative')) {
				const constraints:Edge = element.constraints;
				
				background.x += constraints.left;
				background.y += constraints.top;
			}
			
		}
		
		window.addChild(background);
		
		return backgroundImageObs.concat(Observable.value(background)).last();
	}
}
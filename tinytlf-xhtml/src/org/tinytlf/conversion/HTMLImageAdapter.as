/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.conversion
{
    import flash.display.Shape;
    import flash.events.EventDispatcher;
    import flash.net.URLRequest;
    import flash.text.engine.*;
    
    import org.tinytlf.layout.properties.LayoutProperties;
    import org.tinytlf.model.ITLFNode;
    import org.tinytlf.util.fte.*;

    public class HTMLImageAdapter extends ContentElementFactory
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
            var img:ITLFNode = data as ITLFNode;
			var imageProperties:Object = engine.styler.describeElement(img);
			var inheritedProperties:Object = engine.styler.describeElement(img.parent);
			
			var lp:LayoutProperties = new LayoutProperties(imageProperties);
			
			var format:ElementFormat = getElementFormat(context);
			format.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			
			var element:ContentElement;
			
			if(imageProperties.float)
			{
	            element = new GraphicElement(
					new ImageLoader(img['src'], lp), 
					lp.width, 
					lp.height, 
					format, 
					getEventMirror(img) || new EventDispatcher());
				
	            element.userData = img;
				
				//Decorate this element?
				engine.decor.decorate(
					element, 
					inheritedProperties, 
					inheritedProperties.layer, 
					null, 
					inheritedProperties.foreground);
				
				var lBreakGraphic:GraphicElement = new GraphicElement(new Shape(),0, 0, new ElementFormat());
				lBreakGraphic.userData = 'lineBreak';
				
				return ContentElementUtil.lineBreakBeforeAndAfter(
					new GroupElement(new <ContentElement>[element, lBreakGraphic]));
			}
			
            element = new GraphicElement(
				new ImageLoader(img['src'], lp), 
				lp.width + lp.paddingLeft + lp.paddingRight, 
				lp.height + lp.paddingTop + lp.paddingBottom, 
				format, getEventMirror(img) || new EventDispatcher());
			
            element.userData = img;
			
			engine.decor.decorate(
				element, 
				inheritedProperties, 
				inheritedProperties.layer, 
				null, 
				inheritedProperties.foreground);
			
            return element;
        }
    }
}

import flash.display.*;
import flash.events.*;
import flash.geom.Matrix;
import flash.net.URLRequest;

import org.tinytlf.layout.properties.LayoutProperties;

internal class ImageLoader extends Sprite
{
	private var lp:LayoutProperties;
	
	public function ImageLoader(src:String, lp:LayoutProperties)
	{
		this.lp = lp;
		
		graphics.beginFill(0x00, 0);
		graphics.drawRect(0, 0, lp.width, lp.height);
		
		var loader:Loader = new Loader();
		loader.load(new URLRequest(src));
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
	}
	
	private function onError(event:IOErrorEvent):void
	{
		var li:LoaderInfo = LoaderInfo(event.target);
		li.removeEventListener(event.type, onError);
		trace(event.toString());
	}
	
	private function onComplete(event:Event):void
	{
		var li:LoaderInfo = LoaderInfo(event.target);
		li.removeEventListener(event.type, onComplete);
		
		var child:Bitmap = Bitmap(li.content);
		
		var m:Matrix = new Matrix();
		m.scale(lp.width / child.width, lp.height / child.height);
		var bmd:BitmapData = new BitmapData(lp.width, lp.height);
		bmd.draw(child, m);
		
		var bitmap:Bitmap = new Bitmap(bmd);
		addChild(bitmap);
	}
}
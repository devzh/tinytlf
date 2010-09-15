/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories.adapters
{
    import flash.net.URLRequest;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GraphicElement;
    import flash.text.engine.TextBaseline;
    
    import org.tinytlf.layout.Terminators;
    import org.tinytlf.layout.descriptions.TextFloat;
    import org.tinytlf.layout.model.factories.ContentElementFactory;
    import org.tinytlf.layout.model.factories.XMLDescription;
    import org.tinytlf.layout.properties.LayoutProperties;

    public class HTMLImageAdapter extends ContentElementFactory
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
            var img:XMLDescription = context[context.length - 1];
			var style:Object = engine.styler.describeElement(img);
			var lp:LayoutProperties = new LayoutProperties(style);
			
			var format:ElementFormat = new ElementFormat();
			format.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			
			var element:ContentElement;
			
			if(style.float)
			{
	            element = new GraphicElement(new ImageLoader(img.attributes.src, lp), 
					lp.paddingLeft + lp.paddingRight, lp.paddingTop + lp.paddingBottom, format, getEventMirror(context));
				
	            element.userData = Vector.<XMLDescription>(context);
				
				return Terminators.terminateClear(element);
			}
			
            element = new GraphicElement(new ImageLoader(img.attributes.src, lp), 
				lp.width + lp.paddingLeft + lp.paddingRight, lp.height + lp.paddingTop + lp.paddingBottom, 
				format, getEventMirror(context));
			
            element.userData = Vector.<XMLDescription>(context);
			
            return element;
        }
    }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
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
		graphics.drawRect(lp.paddingLeft, lp.paddingTop, lp.width + lp.paddingRight, lp.height + lp.paddingBottom);
		
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
		m.translate(lp.paddingLeft, lp.paddingTop);
		
		var bmd:BitmapData = new BitmapData(lp.width, lp.height);
		bmd.draw(child, m);
		
		var bitmap:Bitmap = new Bitmap(bmd);
		addChild(bitmap);
	}
}
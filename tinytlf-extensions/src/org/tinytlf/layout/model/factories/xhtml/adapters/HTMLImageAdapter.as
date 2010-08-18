/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories.xhtml.adapters
{
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GraphicElement;
    import flash.text.engine.TextBaseline;
    
    import org.tinytlf.layout.model.factories.ContentElementFactory;

    public class HTMLImageAdapter extends ContentElementFactory
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
            var element:ContentElement;

            var name:String = "";

            var img:XML;
            if (context.length)
                img = context[context.length - 1];

            if (!img)
                return super.execute(data, context);

            name = img.localName().toString();

            var url:String = img.@src;
            var size:Point = new Point(Number(img.@width) || 15, Number(img.@height) || 15);

            var loader:ImageLoader = new ImageLoader(url, size.x, size.y);
			var format:ElementFormat = getElementFormat(context);
			format.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			
            element = new GraphicElement(loader, size.x, size.y, format, getEventMirror(name));
            element.userData = context;
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
import flash.geom.Matrix;
import flash.geom.Point;
import flash.net.URLRequest;

internal class ImageLoader extends Sprite
{
	private var w:Number = 0;
	private var h:Number = 0;
	
	public function ImageLoader(src:String, w:Number, h:Number)
	{
		this.w = w;
		this.h = h;
		var loader:Loader = new Loader();
		loader.load(new URLRequest(src));
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
	}
	
	private function onComplete(event:Event):void
	{
		var li:LoaderInfo = LoaderInfo(event.target);
		li.removeEventListener(event.type, onComplete);
		
		var child:Bitmap = Bitmap(li.content);
		
		var m:Matrix = new Matrix();
		m.scale(w / child.width, h / child.height);
		
		var bmd:BitmapData = new BitmapData(w, h);
		bmd.draw(child, m);
		
		var bitmap:Bitmap = new Bitmap(bmd);
		addChild(bitmap);
	}
}
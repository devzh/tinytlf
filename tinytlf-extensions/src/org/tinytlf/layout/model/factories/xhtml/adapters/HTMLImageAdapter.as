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
    
    import org.tinytlf.layout.LayoutProperties;
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
			
			var style:Object = engine.styler.describeElement(img);
			var lp:LayoutProperties = new LayoutProperties(style);
            var url:String = img.@src;
			
            var size:Point = new Point(Number(style.width) || 15, Number(style.height) || 15);
            var loader:ImageLoader = new ImageLoader(url, size.x, size.y, lp.paddingLeft, lp.paddingTop);
			
			var format:ElementFormat = getElementFormat(context);
			format.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			
            element = new GraphicElement(loader, size.x + lp.paddingLeft + lp.paddingRight, size.y + lp.paddingTop + lp.paddingBottom, format, getEventMirror(name));
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
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.net.URLRequest;

internal class ImageLoader extends Sprite
{
	private var w:Number = 0;
	private var h:Number = 0;
	private var _x:Number = 0;
	private var _y:Number = 0;
	
	public function ImageLoader(src:String, w:Number, h:Number, x:Number = 0, y:Number = 0)
	{
		this.w = w;
		this.h = h;
		_x = x;
		_y = y;
		var loader:Loader = new Loader();
		loader.load(new URLRequest(String(src)));
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
		m.scale(w / child.width, h / child.height);
		m.translate(_x, _y);
		
		var bmd:BitmapData = new BitmapData(w, h);
		bmd.draw(child, m);
		
		var bitmap:Bitmap = new Bitmap(bmd);
		addChild(bitmap);
	}
}
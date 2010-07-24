/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.extensions.layout.adapter.xml.html
{
    import flash.display.Loader;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.text.engine.ContentElement;
    import flash.text.engine.GraphicElement;

    import org.tinytlf.layout.adapter.ContentElementAdapter;

    public class ImageAdapter extends ContentElementAdapter
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

            var loader:Loader = new Loader();
            loader.load(new URLRequest(url));

            element = new GraphicElement(loader, size.x, size.y, getElementFormat(context), getEventMirror(name));
            element.userData = context;

            return element;
        }
    }
}
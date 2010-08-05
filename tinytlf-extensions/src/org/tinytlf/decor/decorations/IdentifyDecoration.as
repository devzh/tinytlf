/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor.decorations
{
    import flash.display.Graphics;
    import flash.geom.Rectangle;
    import flash.text.engine.ContentElement;
    import flash.text.engine.TextLine;
    import flash.utils.Dictionary;

    import org.tinytlf.decor.TextDecoration;

    public class IdentifyDecoration extends TextDecoration
    {
        public function IdentifyDecoration(styleObject:Object = null)
        {
            super(styleObject);
        }

        override public function setup(layer:int = 0, ...args):Vector.<Rectangle>
        {
            var bounds:Vector.<Rectangle> = new <Rectangle>[];

            if (args.length <= 0)
                return bounds;

            var arg:* = args[0];
            var rect:Rectangle;

            if (arg is ContentElement)
            {
                var temp:Dictionary = new Dictionary(true);
                var lines:Vector.<TextLine> = getTextLines(arg);
                for each(var line:TextLine in lines)
                {
                    rect = line.getBounds(line.parent);
                    bounds.push(new Rectangle(rect.x, rect.y + line.ascent, rect.width, 0));
                    bounds.push(new Rectangle(rect.x, rect.y, rect.width, 0));
                    bounds.push(new Rectangle(rect.x, rect.y + line.ascent + line.descent, rect.width, 0));

                    temp[engine.layout.getContainerForLine(line)] = true;
                }

                for (var c:* in temp)
                    containers.push(c);

                associateBoundsWithContainers(bounds, layer);
            }
            else if (arg is TextLine)
            {
                var tl:TextLine = arg as TextLine;
                rect = line.getBounds(line.parent);
                bounds.push(new Rectangle(rect.x, rect.y + tl.ascent, rect.width, 0));
                bounds.push(new Rectangle(rect.x, rect.y, rect.width, 0));
                bounds.push(new Rectangle(rect.x, rect.y + tl.ascent + tl.descent, rect.width, 0));

                associateBoundsWithContainers(bounds, layer);
            }
            else
            {
                bounds = super.setup.apply(null, [layer].concat(args));
            }

            return bounds;
        }

        override public function draw(bounds:Vector.<Rectangle>):void
        {
            var colors:Array = [0x0000FF, 0x00FF00, 0xFF0000];
            var rects:Vector.<Rectangle> = bounds.concat();
            var rect:Rectangle;
            var color:uint;
            var g:Graphics;

            while (rects.length)
            {
                rect = rects.pop();
                color = colors.pop();
                colors.unshift(color);
                g = getShapeForRectangle(rect).graphics;
                g.lineStyle(2, color);
                g.drawRect(rect.x, rect.y, rect.width, rect.height);
                g.endFill();
            }
        }
    }
}
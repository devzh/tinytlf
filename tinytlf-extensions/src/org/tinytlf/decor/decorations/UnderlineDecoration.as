/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor.decorations
{
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import org.tinytlf.decor.TextDecoration;
    
    public class UnderlineDecoration extends TextDecoration
    {
		public function UnderlineDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
        override public function draw(bounds:Vector.<Rectangle>):void
        {
            super.draw(bounds);
            
            var start:Point;
            var end:Point;
            var rect:Rectangle;
            var g:Graphics;
            var copy:Vector.<Rectangle> = bounds.concat();
            var underlineDelta:Number = Math.round((getStyle("fontSize") || 12) / 6);
            
            while(copy.length > 0)
            {
                rect = copy.pop();
                g = rectToLayer(rect).graphics;
                start = new Point(rect.left, rect.bottom - underlineDelta);
                end = new Point(rect.right, rect.bottom - underlineDelta);
                
                g.lineStyle(
                    getStyle("underlineThickness") || 2,
                    getStyle("underlineColor") || getStyle("color") || 0x00,
                    getStyle("underlineAlpha") || getStyle("alpha") || 1,
                    getStyle("pixelHinting") || false,
                    getStyle("scaleMode") || "normal",
                    getStyle("caps") || null,
                    getStyle("joints") || null,
                    getStyle("miterLimit") || 3);
                
                g.moveTo(start.x, start.y);
                g.lineTo(end.x, end.y);
                
                g.lineStyle();
            }
        }
    }
}


/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor.decorations
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import org.tinytlf.decor.TextDecoration;
    
    public class StrikeThroughDecoration extends TextDecoration
    {
		public function StrikeThroughDecoration(styleObject:Object = null)
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
            var layer:Sprite;
            
            while(bounds.length > 0)
            {
                rect = bounds.pop();
				
				layer = rectToLayer(rect);
				if(!layer)
					continue;
				
				g = layer.graphics;
                
                start = new Point(rect.x, rect.y + (rect.height * 0.5));
                end = new Point(rect.x + rect.width, rect.y + (rect.height * 0.5));
                
                g.lineStyle(
                    getStyle("weight") || 2,
                    getStyle("strikethroughColor") || getStyle("color") || 0x00,
                    getStyle("strikethroughAlpha") || getStyle("alpha") || 1,
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


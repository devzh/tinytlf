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
    import flash.text.engine.ContentElement;
    import flash.text.engine.FontMetrics;
    import flash.text.engine.TextElement;
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineMirrorRegion;
    
    import org.tinytlf.decor.TextDecoration;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.util.fte.ContentElementUtil;
    
    public class UnderlineDecoration extends ContentElementDecoration
    {
		public function UnderlineDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override protected function processContentElement(element:ContentElement):void
		{
			super.processContentElement(element);
			var metrics:FontMetrics = element.elementFormat.getFontMetrics();
			setStyle("underlineThickness", metrics.underlineThickness);
		}
		
		override protected function processTLMR(tlmr:TextLineMirrorRegion):Rectangle
		{
			var rect:Rectangle = tlmr.bounds.clone();
			rect.y = emBox.y;
			rect.height = emBox.height - getStyle('underlineThickness');
			rect.offset(tlmr.textLine.x, tlmr.textLine.y);
			return rect;
		}
		
        override public function draw(bounds:Vector.<Rectangle>):void
        {
            super.draw(bounds);
            
            var start:Point;
            var end:Point;
            var rect:Rectangle;
            var g:Graphics;
            var copy:Vector.<Rectangle> = bounds.concat();
			var thickness:Number = getStyle("underlineThickness") || 2;
            
            while(copy.length > 0)
            {
                rect = copy.pop();
                g = rectToLayer(rect).graphics;
                start = new Point(rect.left, rect.bottom - thickness);
                end = new Point(rect.right, rect.bottom - thickness);
                
                g.lineStyle(
					thickness,
                    getStyle("underlineColor") || getStyle("color") || 0x00,
                    getStyle("underlineAlpha") || getStyle("alpha") || 1,
                    getStyle("pixelHinting") || false,
                    getStyle("scaleMode") || "normal",
                    getStyle("caps") || null,
                    getStyle("joints") || null,
                    getStyle("miterLimit") || 3);
                
                g.moveTo(start.x, start.y);
                g.lineTo(end.x, end.y);
				g.endFill();
	            g.lineStyle();
            }
        }
    }
}


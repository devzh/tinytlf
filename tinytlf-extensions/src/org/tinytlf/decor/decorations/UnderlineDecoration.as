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
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineMirrorRegion;
    
    import org.tinytlf.decor.TextDecoration;
    import org.tinytlf.util.fte.ContentElementUtil;
    
    public class UnderlineDecoration extends TextDecoration
    {
		public function UnderlineDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override public function setup(layer:int=0, ...parameters):Vector.<Rectangle>
		{
			if(parameters.length < 1)
				return super.setup.apply(null, [layer].concat(parameters));
			
			var arg:* = parameters[0];
			if(!(arg is ContentElement))
				return super.setup.apply(null, [layer].concat(parameters));
			
			var element:ContentElement = ContentElement(arg);
			var metrics:FontMetrics = element.elementFormat.getFontMetrics();
			setStyle("underlineThickness", metrics.underlineThickness);
			
			var emBox:Rectangle = metrics.emBox;
			
			var bounds:Vector.<Rectangle> = new Vector.<Rectangle>();
			var tlmrs:Vector.<TextLineMirrorRegion> = ContentElementUtil.getMirrorRegions(ContentElement(arg));
			var tlmr:TextLineMirrorRegion;
			var line:TextLine;
			var rect:Rectangle;
			
			var n:int = tlmrs.length;
			for(var i:int = 0; i < n; ++i)
			{
				tlmr = tlmrs[i];
				rect = tlmr.bounds.clone();
				rect.y = emBox.y;
				rect.height = emBox.height - metrics.underlineThickness;
				
				rect.offset(tlmr.textLine.x, tlmr.textLine.y);
				
				rectToContainer[rect] = assureLayerExists(
					engine.layout.getContainerForLine(tlmr.textLine), layer);
				
				bounds.push(rect);
			}
			
			return bounds;
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
            var underlineDelta:Number = Math.round((getStyle("fontSize") || 12) / 6);
            
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
	            g.lineStyle();
            }
        }
    }
}


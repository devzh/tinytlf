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
    
    import org.tinytlf.decor.TextDecoration;
    
    public class BackgroundColorDecoration extends TextDecoration
    {
        public function BackgroundColorDecoration(styleName:String = "")
        {
            super(styleName);
        }
        
        override public function draw(bounds:Vector.<Rectangle>):void
        {
            super.draw(bounds);
            
            var rect:Rectangle;
            var g:Graphics;
            var copy:Vector.<Rectangle> = bounds.concat();
            var bgColor:uint;
            var bgAlpha:Number;
            
            while(copy.length > 0)
            {
                rect = copy.pop();
                g = getShapeForRectangle(rect).graphics;
                g.lineStyle();
                
                bgColor = uint(getStyle('backgroundColor'));
                bgAlpha = Number(getStyle('backgroundAlpha'));
                
                g.beginFill(isNaN(bgColor) ? 0x000000 : bgColor, isNaN(bgAlpha) ? 1 : bgAlpha);
                g.drawRect(rect.x, rect.y, rect.width, rect.height);
            }
        }
    }
}


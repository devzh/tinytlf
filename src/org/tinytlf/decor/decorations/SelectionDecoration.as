/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor.decorations
{
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.decor.TextDecoration;
    
    public class SelectionDecoration extends TextDecoration
    {
        override public function draw(bounds:Vector.<Rectangle>):void
        {
            super.draw(bounds);
            
            var rect:Rectangle;
            var parent:Sprite;
            
            while(bounds.length > 0)
            {
                rect = bounds.pop();
                parent = getShapeForRectangle(rect);
                
                if(!parent)
                    continue;
                
                parent.graphics.beginFill(getStyle("selectionColor") || 0x000000, getStyle("selectionAlpha") || 1);
                parent.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
            }
        }
    }
}


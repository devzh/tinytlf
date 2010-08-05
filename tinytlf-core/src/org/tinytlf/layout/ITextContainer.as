/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    
    public interface ITextContainer
    {
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
        function get target():DisplayObjectContainer;
        function set target(textContainer:DisplayObjectContainer):void;
        
        function get shapes():Sprite;
        function set shapes(shapesContainer:Sprite):void;
        
        function get explicitWidth():Number;
        function set explicitWidth(value:Number):void;
        
        function get explicitHeight():Number;
        function set explicitHeight(value:Number):void;
        
        function get measuredWidth():Number;
        function get measuredHeight():Number;
        
        function clear():void;
        function resetShapes():void;
        
        function prepLayout():void;
        function layout(block:TextBlock, line:TextLine):TextLine;
        function hasLine(line:TextLine):Boolean;
    }
}


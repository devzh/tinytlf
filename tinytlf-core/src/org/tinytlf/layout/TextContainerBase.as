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
    import flash.text.engine.LineJustification;
    import flash.text.engine.SpaceJustifier;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.descriptions.TextAlign;
    
    public class TextContainerBase implements ITextContainer
    {
        public function TextContainerBase(container:DisplayObjectContainer, 
										  explicitWidth:Number = NaN, 
										  explicitHeight:Number = NaN)
        {
            this.target = container;
            
            _explicitWidth = explicitWidth;
            _explicitHeight = explicitHeight;
        }
        
        protected var _target:DisplayObjectContainer;
        
        public function get target():DisplayObjectContainer
        {
            return _target;
        }
        
        public function set target(doc:DisplayObjectContainer):void
        {
            if(doc == _target)
                return;
            
            _target = doc;
            
            shapes = Sprite(target.addChild(new Sprite()));
        }
        
        protected var _engine:ITextEngine;
        
        public function get engine():ITextEngine
        {
            return _engine;
        }
        
        public function set engine(textEngine:ITextEngine):void
        {
            if(textEngine == _engine)
                return;
            
            _engine = textEngine;
        }
        
        private var _shapes:Sprite;
        
        public function get shapes():Sprite
        {
            return _shapes;
        }
        
        public function set shapes(shapesContainer:Sprite):void
        {
            if(shapesContainer === _shapes)
                return;
            
            var children:Array = [];
            if(shapes)
            {
                while(shapes.numChildren)
                    children.push(shapes.removeChildAt(0));
                if(shapes.parent && shapes.parent.contains(shapes))
                    shapes.parent.removeChild(shapes);
            }
            
            _shapes = shapesContainer;
            
            if(shapes)
                while(children.length)
                    shapes.addChild(children.shift());
        }
        
        protected var _explicitWidth:Number = NaN;
        
        public function get explicitWidth():Number
        {
            return _explicitWidth;
        }
        
        public function set explicitWidth(value:Number):void
        {
            _explicitWidth = value;
        }
        
        protected var _explicitHeight:Number = NaN;
        
        public function get explicitHeight():Number
        {
            return _explicitHeight;
        }
        
        public function set explicitHeight(value:Number):void
        {
            _explicitHeight = value;
        }
        
        protected var width:Number = 0;
        
        public function get measuredWidth():Number
        {
            return width;
        }
        
        protected var height:Number = 0;
        
        public function get measuredHeight():Number
        {
            return height;
        }
        
        protected var blocks:Dictionary = new Dictionary(false);
        
        public function hasLine(line:TextLine):Boolean
        {
            for(var block:* in blocks)
            {
                if(line in blocks[block])
                    return true;
            }
            
            return false;
        }
        
        public function clear():void
        {
            for(var block:* in blocks)
            {
                for(var line:* in blocks[block])
                    removeLine(line);
                
                delete blocks[block];
            }
            
            height = 0;
        }
        
        public function resetShapes():void
        {
            if(!shapes)
                return;
            
            shapes.graphics.clear();
            
            while(shapes.numChildren)
                shapes.removeChildAt(0);
        }
        
        public function prepLayout():void
        {
            height = 0;
            width = explicitWidth;
        }
        
        public function layout(block:TextBlock, line:TextLine):TextLine
        {
            if(!(block in blocks))
                blocks[block] = new Dictionary(false);
            
            var doc:DisplayObjectContainer;
            var props:LayoutProperties = getLayoutProperties(block);
            
            setupBlockJustifier(block);
            
            var y:Number = height + props.paddingTop;
            if(block.firstInvalidLine)
            {
                line = block.firstInvalidLine;
                y = line.y - line.ascent;
                line = line.previousLine;
            }
            
            line = createLine(block, line);
            
            while(line)
            {
                blocks[block][line] = true;
                
                line.userData = engine;
                
                doc = hookLine(line);
                
                y += line.ascent;
                doc.y = y;
                y += line.descent + props.lineHeight;
                
                target.addChild(doc);
                
                if(!isNaN(explicitHeight) && measuredHeight > explicitHeight)
                    return line;
                
                line = createLine(block, line);
            }
            
            height = y + props.paddingBottom;
            
            var blockLines:Dictionary = new Dictionary(true);
            line = block.firstLine;
            while(line)
            {
                blockLines[line] = true;
                line = line.nextLine;
            }
            
            for(var l:* in blocks[block])
            {
                if(!(l in blockLines))
                {
                    removeLine(l);
                }
            }
            
            blockLines = null;
            
            return line;
        }
        
        protected function createLine(block:TextBlock, line:TextLine = null):TextLine
        {
            var props:LayoutProperties = getLayoutProperties(block);
            
            var w:Number = props.width || explicitWidth;
            var x:Number = 0;
            
            if(line == null)
            {
                w -= props.textIndent;
                x += props.textIndent;
            }
            
            w -= props.paddingLeft;
            w -= props.paddingRight;
            
            line = block.createTextLine(line, w, 0, true);
            
            if(!line)
                return null;
            
            switch(props.textAlign)
            {
                case TextAlign.LEFT:
                case TextAlign.JUSTIFY:
                    x += props.paddingLeft;
                    break;
                case TextAlign.CENTER:
                    x = (width - line.width) * 0.5;
                    break;
                case TextAlign.RIGHT:
                    x = width - line.width + props.paddingRight;
                    break;
            }
            
            line.x = x;
            
            return line;
        }
        
        protected function removeLine(line:TextLine):void
        {
            if(target.contains(line))
                target.removeChild(line);
            
            var block:TextBlock = line.textBlock;
            
            delete blocks[block][line];
        }
        
        protected function hookLine(line:TextLine):DisplayObjectContainer
        {
            line.doubleClickEnabled = true;
            
            engine.interactor.getMirror(line);
            
            return line;
        }
        
        protected function setupBlockJustifier(block:TextBlock):void
        {
            var props:LayoutProperties = getLayoutProperties(block);
            var justification:String = LineJustification.UNJUSTIFIED;
            
            if(props.textAlign == TextAlign.JUSTIFY)
                justification = LineJustification.ALL_BUT_LAST;
            
            if(!block.textJustifier || block.textJustifier.lineJustification != justification)
            {
                block.textJustifier = new SpaceJustifier("en", justification, true);
            }
        }
        
        protected function getLayoutProperties(block:TextBlock):LayoutProperties
        {
            return (block.userData as LayoutProperties) || new LayoutProperties();
        }
    }
}


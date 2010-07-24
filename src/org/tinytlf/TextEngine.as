/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    import flash.utils.Dictionary;
    import flash.utils.setTimeout;

    import org.tinytlf.core.Dimension;
    import org.tinytlf.decor.*;
    import org.tinytlf.extensions.styles.fcss.FCSSTextStyler;
    import org.tinytlf.interaction.*;
    import org.tinytlf.interaction.gesture.GestureInteractor;
    import org.tinytlf.layout.*;
    import org.tinytlf.styles.*;

    public class TextEngine extends EventDispatcher implements ITextEngine
    {
        public function TextEngine(stage:Stage = null)
        {
            this.stage = stage;
        }
        
        protected var _decor:ITextDecor;
        
        public function get decor():ITextDecor
        {
            if(!_decor)
                _decor = new TextDecor();
            
            _decor.engine = this;
            
            return _decor;
        }
        
        public function set decor(textDecor:ITextDecor):void
        {
            if(textDecor == _decor)
                return;
            
            _decor = textDecor;
            
            _decor.engine = this;
        }
        
        protected var _interactor:ITextInteractor;
        
        public function get interactor():ITextInteractor
        {
            if(!_interactor)
                _interactor = new GestureInteractor();
            
            _interactor.engine = this;
            
            return _interactor;
        }
        
        public function set interactor(textInteractor:ITextInteractor):void
        {
            if(textInteractor == _interactor)
                return;
            
            _interactor = textInteractor;
            
            _interactor.engine = this;
        }
        
        protected var _layout:ITextLayout;
        
        public function get layout():ITextLayout
        {
            if(!_layout)
                _layout = new TextLayoutBase();
            
            _layout.engine = this;
            
            return _layout;
        }
        
        public function set layout(textLayout:ITextLayout):void
        {
            if(textLayout == _layout)
                return;
            
            _layout = textLayout;
            
            _layout.engine = this;
        }
        
        protected var _stage:Stage;
        
        public function set stage(theStage:Stage):void
        {
            if(theStage === _stage)
                return;
            
            _stage = theStage;
            invalidateStage();
        }
        
        protected var _styler:ITextStyler;
        
        public function get styler():ITextStyler
        {
            if(!_styler)
                _styler = new FCSSTextStyler();
            
            _styler.engine = this;
            
            return _styler;
        }
        
        public function set styler(textStyler:ITextStyler):void
        {
            if(textStyler == _styler)
                return;
            
            _styler = textStyler;
        }
        
        public function getBlockPosition(block:TextBlock):int
        {
            return blocks.getItemPosition(block);
        }
        
        public function getBlockSize(block:TextBlock):int
        {
            return blocks.getItemSize(block);
        }
        
        private var _caretIndex:int = 0;
        public function get caretIndex():int
        {
            return _caretIndex;
        }
        
        public function set caretIndex(index:int):void
        {
            var block:TextBlock = indexToTextBlock(index);
            if(!block)
                return;
            
            _caretIndex = index;
            
            var blockPosition:int = getBlockPosition(block);
            var blockSize:int = getBlockSize(block);
            
            var line:TextLine = block.getTextLineAtCharIndex(Math.min(index - blockPosition, blockSize - 1));
            var rect:Rectangle = line.getAtomBounds(Math.min(index - blockPosition - line.textBlockBeginIndex, line.atomCount - 1));
            rect.x += line.x;
            rect.y += line.y;
            
            decor.undecorate(null, 'caret');
            decor.decorate(rect, {caret:true}, TextDecor.CARET_LAYER, new <ITextContainer>[layout.getContainerForLine(line)]);
        }
        
        private var _selection:Point = new Point(NaN, NaN);
        
        public function get selection():Point
        {
            return _selection;
        }
        
        public function select(startIndex:Number = NaN, endIndex:Number = NaN):void
        {
            decor.undecorate(null, 'selectionColor');
            
            if(isNaN(startIndex) || isNaN(endIndex))
            {
                selection.x = NaN;
                selection.y = NaN;
                return;
            }
            
            var temp:Point = new Point(startIndex, endIndex);
            
            //  Normalize the inputs.
            startIndex = Math.min(temp.x, temp.y);
            endIndex = Math.max(temp.x, temp.y);
            
            //  Get the textBlocks that span these indicies
            var textBlocks:Array = blocks.getItemsAt(startIndex, endIndex, false);
            
            if(!textBlocks || !textBlocks.length)
                return;
            
            selection.x = startIndex;
            selection.y = endIndex;
            
            //  Gotta keep track of which containers this selection spans
            var containers:Dictionary = new Dictionary(false);
            
            //  The rectangles that this selection represents
            var rects:Vector.<Rectangle> = new <Rectangle>[];
            var rect:Rectangle;
            
            var blockPosition:int;
            var blockSize:int;
            var lineSize:int;
            
            var block:TextBlock;
            var line:TextLine;
            var uiLineClass:Class = EventLineInfo.uiLineClass;
            var lineParent:DisplayObjectContainer;
            
            var n:int = textBlocks.length;
            for(var i:int = 0; i < n; i++)
            {
                block = textBlocks[i];
                
                blockPosition = getBlockPosition(block);
                blockSize = getBlockSize(block);
                
                startIndex -= blockPosition;
                endIndex -= blockPosition;
                
                line = block.getTextLineAtCharIndex(startIndex);
                while(line)
                {
                    containers[layout.getContainerForLine(line)] = true;
                    
                    lineSize = line.textBlockBeginIndex + line.rawTextLength;
                    
                    rect = line.getAtomBounds(startIndex - line.textBlockBeginIndex);
                    rect = (endIndex < lineSize) ?
                        rect.union(line.getAtomBounds(Math.max(endIndex - line.textBlockBeginIndex, 0))) :
                        rect.union(line.getAtomBounds(line.atomCount - 1));
                    
                    lineParent = (uiLineClass && line.parent is uiLineClass) ? line.parent : line;
                    
                    rect.x += lineParent.x;
                    rect.y += lineParent.y;

                    rects.push(rect);
                    
                    line = endIndex >= lineSize ? line.nextLine : null;
                    if(line)
                        startIndex = line.textBlockBeginIndex;
                }
                
                startIndex = blockPosition + blockSize;
                endIndex += blockPosition;
            }
            
            var textContainers:Vector.<ITextContainer> = new <ITextContainer>[];
            for(var container:* in containers)
                textContainers.push(container);
            
            containers = null;
            
            decor.decorate(rects,
                {selectionColor:styler.getStyle('selectionColor'), selectionAlpha: styler.getStyle('selectionAlpha')},
                TextDecor.SELECTION_LAYER,
                textContainers);
        }
        
        private function indexToTextBlock(index:int):TextBlock
        {
            if(!blocks || !blocks.length)
                return null;
            
            var items:Array = blocks.getItemsAt(index, 0);
            if(items.length)
                return items[0];
            
            return null;
        }
        
        public function pointToIndex(point:Point):int
        {
            var children:Array;
            var containers:Vector.<ITextContainer> = layout.containers;
            var n:int = containers.length;
            var k:int = 0;
            
            for(var i:int = 0; i < n; ++i)
            {
                children = containers[i].target.getObjectsUnderPoint(point);
                
                if(!children || !children.length)
                    continue;
                
                k = children.length;
                for(var j:int = 0; j < k; ++j)
                {
                    if(!(children[j] is TextLine))
                        continue;
                    
                    return TextLine(children[j]).getAtomIndexAtPoint(point.x, point.y);
                }
            }
            
            return -1;
        }
        
        protected var blocks:Dimension;
        
        public function prerender(... args):void
        {
            decor.removeAll();
            
            var textBlocks:Vector.<TextBlock> = layout.textBlockFactory.createBlocks(args);
            if(!blocks)
                blocks = new Dimension();
            
            blocks.clear();
            
            if(!textBlocks || !textBlocks.length)
                return;
            
            var n:int = textBlocks.length;
            for(var i:int = 0; i < n; i++)
            {
                blocks.add(textBlocks[i], textBlocks[i].content.rawText.length);
            }
        }
        
        public function invalidate():void
        {
            invalidateLines();
            invalidateDecorations();
        }
        
        protected var invalidateLinesFlag:Boolean = false;
        
        public function invalidateLines():void
        {
            if(invalidateLinesFlag)
                return;
            
            invalidateLinesFlag = true;
            invalidateStage();
        }
        
        protected var invalidateDecorationsFlag:Boolean = false;
        
        public function invalidateDecorations():void
        {
            if(invalidateDecorationsFlag)
                return;
            
            invalidateDecorationsFlag = true;
            invalidateStage();
        }
        
        protected function invalidateStage():void
        {
            if(!_stage)
                return;
            
            _stage.addEventListener(Event.RENDER, onRender);
            
            if(rendering)
                setTimeout(_stage.invalidate, 0);
            else
                _stage.invalidate();
        }
        
        protected function onRender(event:Event):void
        {
            if(!_stage)
                return;
            
            _stage.removeEventListener(Event.RENDER, onRender);
            
            render();
        }
        
        protected var rendering:Boolean = false;
        
        public function render():void
        {
            rendering = true;
            
            if(invalidateLinesFlag)
                renderLines();
            invalidateLinesFlag = false;
            
            if(invalidateDecorationsFlag)
                renderDecorations();
            invalidateDecorationsFlag = false;
            
            rendering = false;
        }
        
        public function renderLines():void
        {
            layout.clear();
            layout.render(layout.textBlockFactory.blocks);
        }
        
        public function renderDecorations():void
        {
            layout.resetShapes();
            decor.render();
        }
    }
}


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
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    import flash.utils.Dictionary;
    import flash.utils.setTimeout;
    
    import org.tinytlf.core.Dimension;
    import org.tinytlf.decor.*;
    import org.tinytlf.interaction.*;
    import org.tinytlf.layout.*;
    import org.tinytlf.styles.*;

    public class TextEngine implements ITextEngine
    {
        public function TextEngine(stage:Stage = null)
        {
            this.stage = stage;
        }
		
		public function set configuration(engineConfiguration:ITextEngineConfiguration):void
		{
			engineConfiguration.configure(this);
		}
        
        protected var _decor:ITextDecor;
        
        public function get decor():ITextDecor
        {
            if(!_decor)
                decor = new TextDecor();
            
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
                interactor = new TextInteractorBase();
            
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
                layout = new TextLayoutBase();
            
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
                styler = new TextStyler();
            
            return _styler;
        }
        
        public function set styler(textStyler:ITextStyler):void
        {
            if(textStyler == _styler)
                return;
            
            _styler = textStyler;
			
			_styler.engine = this;
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
			//Don't set the caretIndex if we don't have a caret decoration.
			if(!decor.hasDecoration('caret'))
				return;
			
            decor.undecorate(null, 'caret');
			
            var block:TextBlock = indexToTextBlock(index);
            if(!block)
                return;
            
            _caretIndex = index;
            
            var blockPosition:int = getBlockPosition(block);
            var blockSize:int = getBlockSize(block);
			
            var line:TextLine = block.getTextLineAtCharIndex(Math.max(
				0, 
				Math.min(index - blockPosition, blockSize - 1)
			));
			
			var atomIndex:int = Math.min(index - blockPosition - line.textBlockBeginIndex, line.atomCount - 1);
            var rect:Rectangle = line.getAtomBounds(atomIndex);
			
            rect.x += line.x;
            rect.y += line.y;
			
			var pos:String = index - blockPosition - line.textBlockBeginIndex >= line.atomCount ? 'right' : 'left';
			
            decor.decorate(rect, {caret:true, position:pos}, TextDecor.CARET_LAYER, 
				new <ITextContainer>[layout.getContainerForLine(line)]
			);
        }
        
        private var _selection:Point = new Point(NaN, NaN);
        
        public function get selection():Point
        {
            return _selection;
        }
        
        public function select(startIndex:Number = NaN, endIndex:Number = NaN):void
        {
			//Don't try to select if we don't have a selection decoration.
			if(!decor.hasDecoration('selection'))
				return;
			
            decor.undecorate(null, 'selection');
            
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
                    
                    lineSize = line.textBlockBeginIndex + line.atomCount;
                    
                    rect = line.getAtomBounds(startIndex - line.textBlockBeginIndex);
                    rect = (endIndex < lineSize) ?
                        rect.union(line.getAtomBounds(Math.max(endIndex - line.textBlockBeginIndex, 0))) :
                        rect.union(line.getAtomBounds(line.atomCount - 1));
                    
                    rect.x += line.x;
                    rect.y += line.y;

                    rects.push(rect);
                    
                    line = endIndex >= lineSize ? line.nextLine : null;
					
                    if(line)
					{
                        startIndex = line.textBlockBeginIndex;
					}
                }
                
                startIndex = blockPosition + blockSize;
                endIndex += blockPosition;
            }
            
            var textContainers:Vector.<ITextContainer> = new <ITextContainer>[];
            for(var container:* in containers)
                textContainers.push(container);
            
            containers = null;
            
            decor.decorate(rects,
                {
					selection:true, 
					selectionColor:styler.getStyle('selectionColor'), 
					selectionAlpha: styler.getStyle('selectionAlpha')
				},
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
        
        public function invalidate(preRender:Boolean = false):void
        {
			if(preRender)
			{
				invalidateData();
			}
			
            invalidateLines();
            invalidateDecorations();
        }
        
        protected var invalidateDataFlag:Boolean = false;
        
        public function invalidateData():void
        {
            if(invalidateDataFlag)
                return;
            
			invalidateDataFlag = true;
            invalidateStage();
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
            
			if(invalidateDataFlag)
				renderData();
			invalidateDataFlag = false;
			
            if(invalidateLinesFlag)
                renderLines();
            invalidateLinesFlag = false;
            
            if(invalidateDecorationsFlag)
                renderDecorations();
            invalidateDecorationsFlag = false;
            
            rendering = false;
        }
		
		protected var blocks:Dimension;
		
		protected function renderData():void
		{
			decor.removeAll();
			layout.clear();
			
			var textBlocks:Vector.<TextBlock> = createTextBlocks();
			
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
		
		protected function createTextBlocks():Vector.<TextBlock>
		{
			return layout.textBlockFactory.createBlocks();
		}
        
        protected function renderLines():void
        {
            layout.render(layout.textBlockFactory.blocks);
        }
        
		protected function renderDecorations():void
        {
            layout.resetShapes();
            decor.render();
        }
    }
}

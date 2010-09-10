/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf
{
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.*;
    import flash.text.engine.*;
    import flash.utils.*;
    
    import org.tinytlf.decor.*;
    import org.tinytlf.interaction.*;
    import org.tinytlf.layout.*;
    import org.tinytlf.styles.*;
	
	/**
	 * @see org.tinytlf.ITextEngine
	 */
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
			var n:int = blocks.length;
			var count:int = 0;
			for(var i:int = 0; i < n; ++i)
			{
				if(blocks[i] === block)
					return count;
				
				count += blocks[i].content.rawText.length;
			}
			
			return count;
        }
        
        public function getBlockSize(block:TextBlock):int
        {
			return block.content ? 
				block.content.rawText ? block.content.rawText.length : 0 : 0;
        }
		
		protected function getBlockRange(startIndex:int, endIndex:int):Vector.<TextBlock>
		{
			var textBlocks:Vector.<TextBlock> = new Vector.<TextBlock>();
			var n:int = blocks.length;
			var aggregateSize:int = 0;
			
			for(var i:int = 0; i < n; ++i)
			{
				if((aggregateSize + getBlockSize(blocks[i])) > startIndex && aggregateSize <= endIndex)
					textBlocks.push(blocks[i]);
				else if(aggregateSize > endIndex)
					return textBlocks;
				
				aggregateSize += getBlockSize(blocks[i]);
			}
			
			return textBlocks;
		}
		
		protected function get totalLength():Number
		{
			var textBlocks:Vector.<TextBlock> = new Vector.<TextBlock>();
			var n:int = blocks.length;
			var aggregateSize:int = 0;
			
			for(var i:int = 0; i < n; ++i)
			{
				aggregateSize += getBlockSize(blocks[i]);
			}
			
			return aggregateSize;
		}
        
        private var _caretIndex:int = 0;
        public function get caretIndex():int
        {
            return _caretIndex;
        }
        
		private var caretIndexChanged:Boolean = false;
        public function set caretIndex(index:int):void
        {
			if(index === _caretIndex)
				return;
			
            _caretIndex = Math.max(Math.min(index, totalLength - 1), 0);
            
			//Don't draw the caretIndex if we don't have a caret decoration.
			if(!decor.hasDecoration('caret'))
				return;
			
            decor.undecorate(null, 'caret');
			
            var block:TextBlock = indexToTextBlock(index);
            if(!block)
                return;
			
			caretIndexChanged = true;
			
			invalidateDecorations();
        }
        
        private var _selection:Point = new Point(NaN, NaN);
        
        public function get selection():Point
        {
            return _selection;
        }
        
		private var selectionChanged:Boolean = false;
        public function select(startIndex:Number = NaN, endIndex:Number = NaN):void
        {
            if(isNaN(startIndex) || isNaN(endIndex))
            {
                selection.x = NaN;
                selection.y = NaN;
				decor.undecorate(null, 'selection');
                return;
            }
			
            var temp:Point = new Point(startIndex, endIndex);
            
            //  Normalize the inputs.
            startIndex = Math.min(temp.x, temp.y);
            endIndex = Math.max(temp.x, temp.y);
			
			if(startIndex == selection.x && endIndex == selection.y)
				return;
			
            //  Get the textBlocks that span these indicies
            var textBlocks:Vector.<TextBlock> = getBlockRange(startIndex, endIndex);
            
            if(!textBlocks || !textBlocks.length)
                return;
            
            selection.x = startIndex;
            selection.y = endIndex;
            
			//Don't draw selection if we don't have a selection decoration.
			if(!decor.hasDecoration('selection'))
				return;
			
            decor.undecorate(null, 'selection');
			
			selectionChanged = true;
			
			invalidateDecorations();
        }
        
		protected function indexToTextBlock(index:int):TextBlock
        {
            if(!blocks || !blocks.length)
                return null;
            
            var textBlocks:Vector.<TextBlock> = getBlockRange(index, index);
            if(textBlocks.length)
                return textBlocks[0];
            
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
		
		protected var blocks:Vector.<TextBlock>;
		
		protected function renderData():void
		{
			layout.clear();
			decor.removeAll();
			
			blocks = createTextBlocks();
		}
		
		protected function createTextBlocks():Vector.<TextBlock>
		{
			return layout.textBlockFactory.createBlocks();
		}
        
        protected function renderLines():void
        {
            layout.render(blocks);
        }
        
		protected function renderDecorations():void
        {
			if(selectionChanged)
				renderSelection();
			selectionChanged = false;
			
			if(caretIndexChanged)
				renderCaretIndex();
			caretIndexChanged = false;
			
            layout.resetShapes();
            decor.render();
        }
		
		protected function renderSelection():void
		{
			var startIndex:Number = selection.x;
			var endIndex:Number = selection.y;
			
			//  Get the textBlocks that span these indicies
			var textBlocks:Vector.<TextBlock> = getBlockRange(startIndex, endIndex);
			
			//  Keep track of which containers this selection spans
			var containers:Dictionary = new Dictionary(false);
			var container:ITextContainer;
			
			//  The rectangles that this selection represents
			var rects:Vector.<Rectangle> = new Vector.<Rectangle>();
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
					container = layout.getContainerForLine(line);
					if(!(container in containers))
					{
						rects = new Vector.<Rectangle>();
						containers[container] = rects;
					}
					
					lineSize = line.textBlockBeginIndex + line.atomCount;
					
					rect = line.getAtomBounds(Math.min(startIndex - line.textBlockBeginIndex, 
						line.atomCount - 1));
					
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
			
			for(var tmp:* in containers)
			{
				decor.decorate(containers[tmp],
					{
						selection:true, 
						selectionColor:styler.getStyle('selectionColor'), 
						selectionAlpha: styler.getStyle('selectionAlpha')
					},
					TextDecor.SELECTION_LAYER, ITextContainer(tmp), true);
			}
			
			containers = null;
		}
		
		protected function renderCaretIndex():void
		{
			var block:TextBlock = indexToTextBlock(caretIndex);
			var blockPosition:int = getBlockPosition(block);
			var blockSize:int = getBlockSize(block);
			
			var line:TextLine = block.getTextLineAtCharIndex(Math.max(
				0, 
				Math.min(caretIndex - blockPosition, blockSize - 1)
			));
			
			if(!line)
				return;
			
			var atomIndex:int = Math.min(caretIndex - blockPosition - line.textBlockBeginIndex, line.atomCount - 1);
			var rect:Rectangle = line.getAtomBounds(atomIndex);
			
			rect.x += line.x;
			rect.y += line.y;
			
			var pos:String = atomIndex == (line.atomCount - 1) ? 'right' : 'left';
			
			decor.decorate(rect, {caret:true, position:'left'}, TextDecor.CARET_LAYER, 
				layout.getContainerForLine(line), true);
			
			if(line.stage)
				line.stage.focus = line;
		}
    }
}

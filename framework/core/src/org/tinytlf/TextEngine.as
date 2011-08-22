/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.decoration.*;
	
//	import org.tinytlf.interaction.*;
//	import org.tinytlf.layout.*;
//	import org.tinytlf.styles.*;
	
	/**
	 * @see org.tinytlf.ITextEngine
	 */
	public class TextEngine extends Styleable implements ITextEngine
	{
		[Inject]
		public var decorator:ITextDecorator;
		
		[Inject]
		public var decorationMap:ITextDecorationMap;
		
		[Inject]
		public var injector:Injector;
		
//		[Inject]
//		public var layout:ITextLayout;
//		
//		[Inject]
//		public var styler:ITextStyler;
//		
//		[Inject]
//		public var virtualizer:IVirtualizer;
		
		public function set configuration(engineConfiguration:Function):void
		{
			engineConfiguration(this);
		}
		
		private var _caretIndex:int = 0;
		
		// A unique identifier for the caret index during
		// decoration, since ints are passed by value.
		private const caretWrapper:Object = {caretIndex: 0};
		
		public function get caretIndex():int
		{
			return _caretIndex;
		}
		
		public function set caretIndex(index:int):void
		{
			if(index === _caretIndex)
				return;
			
			_caretIndex = index = Math.max(index, 0);
			
			//Don't draw the caretIndex if we don't have a caret decoration.
			if(!decorationMap.hasMapping('caret'))
				return;
			
			caretWrapper.caretIndex = _caretIndex;
			
			decorator.decorate(caretWrapper,
							   {
								   caret: true,
								   selectionColor: getStyle('caretColor'),
								   selectionAlpha: getStyle('caretAlpha')
							   },
							   TextDecorator.CARET_LAYER, true);
			
			invalidateDecorations();
		}
		
		private var _scrollPosition:Number = 0;
		
		public function get scrollPosition():Number
		{
			return _scrollPosition;
		}
		
		public function set scrollPosition(value:Number):void
		{
			if(value === _scrollPosition)
				return;
			
			if(rendering)
				return;
			
			_scrollPosition = value;
//			_scrollPosition = Math.min(Math.max(value, 0), virtualizer.size);
			invalidate();
		}
		
		private var _selection:Point = new Point(NaN, NaN);
		
		public function get selection():Point
		{
			return _selection;
		}
		
		public function select(startIndex:Number = NaN, endIndex:Number = NaN):void
		{
			//super fast inline isNaN checks
			if(startIndex != startIndex || endIndex != endIndex)
			{
				selection.x = NaN;
				selection.y = NaN;
				decorator.undecorate(selection, "selection");
				return;
			}
			
			var temp:Point = new Point(startIndex, endIndex);
			
			//  Normalize the inputs.
			startIndex = Math.max(Math.min(temp.x, temp.y), 0);
			endIndex = Math.max(Math.max(temp.x, temp.y), 0);
			
			if(startIndex == selection.x && endIndex == selection.y)
				return;
			
			selection.x = startIndex;
			selection.y = endIndex;
			
			//Don't draw selection if we don't have a selection decoration.
			if(!decorationMap.hasMapping('selection'))
				return;
			
			decorator.decorate(selection,
							   {
								   selection: true,
								   selectionColor: getStyle('selectionColor'),
								   selectionAlpha: getStyle('selectionAlpha')
							   },
							   TextDecorator.SELECTION_LAYER, true);
			
			invalidateDecorations();
		}
		
		private const shape:Shape = new Shape();
		
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
			shape.addEventListener(Event.ENTER_FRAME, onRender);
		}
		
		protected function onRender(event:Event):void
		{
			render();
		}
		
		protected var rendering:Boolean = false;
		
		public function render():void
		{
			shape.removeEventListener(Event.ENTER_FRAME, onRender);
			
			rendering = true;
			
			if(invalidateLinesFlag)
				renderLines();
			invalidateLinesFlag = false;
			
			if(invalidateDecorationsFlag)
				renderDecorations();
			invalidateDecorationsFlag = false;
			
			rendering = false;
		}
		
		protected function renderLines():void
		{
			// If we have selection decorations and are re-rendering the lines,
			// re-render the decorations so selection doesn't get out of sync.
			if(selection.x == selection.x && selection.y == selection.y)
				invalidateDecorationsFlag = true;
		
			
			
			
//			blockFactory.preRender();
//			layout.render();
		}
		
		protected function renderDecorations():void
		{
//			layout.resetShapes();
			decorator.render();
		}
	}
}

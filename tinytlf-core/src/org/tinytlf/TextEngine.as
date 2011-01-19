/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf
{
	import flash.display.Stage;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.tinytlf.analytics.*;
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
		
		private var _analytics:ITextEngineAnalytics;
		public function get analytics():ITextEngineAnalytics
		{
			if(!_analytics)
				analytics = new TextEngineAnalytics();
			
			return _analytics;
		}
		
		public function set analytics(textAnalytics:ITextEngineAnalytics):void
		{
			if(textAnalytics === _analytics)
				return;
			
			_analytics = textAnalytics;
			_analytics.engine = this;
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
		
		private var _caretIndex:int = 0;
		
		// A unique identifier for the caret index during
		// decoration, since ints are passed by value.
		private const caretWrapper:Object = {caretIndex:0};
		
		public function get caretIndex():int
		{
			return _caretIndex;
		}
		
		public function set caretIndex(index:int):void
		{
			if(index === _caretIndex)
				return;
			
			_caretIndex = Math.max(Math.min(index, analytics.contentLength), 0);
			
			//Don't draw the caretIndex if we don't have a caret decoration.
			if(!decor.hasDecoration('caret'))
				return;
			
			caretWrapper.caretIndex = _caretIndex;
			
			decor.decorate(caretWrapper,
				{
					caret:true, 
					selectionColor:styler.getStyle('caretColor'),
					selectionAlpha:styler.getStyle('caretAlpha')
				}, 
				TextDecor.CARET_LAYER, null, true);
			
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
			
			_scrollPosition = Math.min(Math.max(value, 0), analytics.pixelLength);
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
				decor.undecorate(selection, "selection");
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
			if(!decor.hasDecoration('selection'))
				return;
			
			decor.decorate(selection, 
				{
					selection:true, 
					selectionColor:styler.getStyle('selectionColor'),
					selectionAlpha:styler.getStyle('selectionAlpha')
				}, 
				TextDecor.SELECTION_LAYER, null, true);
			
			invalidateDecorations();
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
			
			_stage.addEventListener(Event.ENTER_FRAME, onRender);
			_stage.addEventListener(Event.RENDER, onRender);
			_stage.invalidate();
		}
		
		protected function onRender(event:Event):void
		{
			if(!_stage)
				return;
			
			_stage.removeEventListener(Event.ENTER_FRAME, onRender);
			_stage.removeEventListener(Event.RENDER, onRender);
			render();
		}
		
		protected var rendering:Boolean = false;
		
		public function render():void
		{
			if(_stage)
			{
				_stage.removeEventListener(Event.ENTER_FRAME, onRender);
				_stage.removeEventListener(Event.RENDER, onRender);
			}
			
			rendering = true;
			
			if(invalidateLinesFlag)
				renderLines();
			invalidateLinesFlag = false;
			
			if(invalidateDecorationsFlag)
				renderDecorations();
			invalidateDecorationsFlag = false;
			
			rendering = false;
		}
		
		protected var blocks:Vector.<TextBlock>;
		
		protected function renderLines():void
		{
			if(selection.x == selection.x && selection.y == selection.y)
			{
				invalidateDecorationsFlag = true;
			}
			
			layout.render();
		}
		
		protected function renderDecorations():void
		{
			layout.resetShapes();
			decor.render();
		}
	}
}

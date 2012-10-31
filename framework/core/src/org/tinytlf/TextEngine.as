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
	import org.tinytlf.html.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.box.*;
	import org.tinytlf.layout.box.region.Region;
	
	[Event(name = "render", type = "flash.events.Event")]
	[Event(name = "renderLines", type = "flash.events.Event")]
	[Event(name = "renderDecorations", type = "flash.events.Event")]
	
	/**
	 * @inherit
	 */
	public class TextEngine extends EventDispatcher implements ITextEngine
	{
		[Inject]
		public var decorator:ITextDecorator;
		
		[Inject]
		public var decorationMap:ITextDecorationMap;
		
		[Inject]
		public var css:CSS;
		
		[Inject(name='<Box>')]
		public var boxes:Array;
		
		[Inject(name='<Sprite>')]
		public var containers:Array;
		
		[Inject]
		public var observables:Observables;
		
		// A unique identifier for the caret index during
		// decoration, since ints are passed by value.
		private const caretWrapper:Object = {caretIndex: 0};
		
		private var _caretIndex:int = 0;
		public function get caretIndex():int
		{
			return _caretIndex;
		}
		
		public function set caretIndex(index:int):void
		{
			if(index === _caretIndex)
				return;
			
			_caretIndex = Math.max(index, 0);
			
			//Don't draw the caretIndex if we don't have a caret decoration.
			if(!decorationMap.hasMapping('caret'))
				return;
			
			caretWrapper.caretIndex = _caretIndex;
			
			decorator.decorate(caretWrapper, {
								   caret: true,
								   selectionColor: css.getStyle('caretColor'),
								   selectionAlpha: css.getStyle('caretAlpha')
							   },
							   TextDecorator.CARET_LAYER, true);
			
			invalidateDecorations();
		}
		
		[Inject("layout")]
		public var llv:Virtualizer;
		
		private const _scrollPosition:Point = new Point();
		public function get scroll():Point
		{
			return _scrollPosition;
		}
		
		public function set scroll(value:Point):void
		{
			boxes.forEach(function(box:Box, ...args):void {
				value.x = Math.min(Math.max(value.x, 0), box.width);
			});
			value.y = Math.min(Math.max(value.y, 0), llv.size);
			
			if(!value || value.x == _scrollPosition.x && value.y == scroll.y)
				return;
			
			_scrollPosition.x = value.x;
			_scrollPosition.y = value.y
			invalidate();
		}
		
		private var _selection:Point = new Point(NaN, NaN);
		
		public function get selection():Point
		{
			return _selection.clone();
		}
		
		public function select(startIndex:Number = NaN, endIndex:Number = NaN):void
		{
			// super fast inline isNaN checks
			if(startIndex != startIndex || endIndex != endIndex)
			{
				_selection.x = NaN;
				_selection.y = NaN;
				decorator.undecorate(_selection, "selection");
				return;
			}
			
			const temp:Point = new Point(startIndex, endIndex);
			
			// Normalize the inputs.
			startIndex = Math.max(Math.min(temp.x, temp.y), 0);
			endIndex = Math.max(Math.max(temp.x, temp.y), 0);
			
			if(startIndex == _selection.x && endIndex == _selection.y)
				return;
			
			_selection.x = startIndex;
			_selection.y = endIndex;
			
			//// TEMP
			boxes.forEach(function(box:Box, ...args):void {
				box.getSelectionRects(startIndex, endIndex);
			});
			////
			
			//Don't draw selection if we don't have a selection decoration.
			if(!decorationMap.hasMapping('selection'))
				return;
			
			decorator.decorate(_selection, {
								   selection: true,
								   selectionColor: css.getStyle('selectionColor'),
								   selectionAlpha: css.getStyle('selectionAlpha')
							   }, 
							   TextDecorator.SELECTION_LAYER, true);
			
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
		
		protected const shape:Shape = new Shape();
		
		protected function invalidateStage():void
		{
			if(shape.hasEventListener(Event.ENTER_FRAME))
				return;
			
			shape.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
				shape.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				render();
				invalidateLinesFlag = false;
				invalidateDecorationsFlag = false;
			});
		}
		
		public function render():void
		{
			if(invalidateLinesFlag)
			{
//				const t:Number = getTimer();
				renderLines();
//				trace('line render time:', getTimer() - t);
			}
			if(invalidateDecorationsFlag)
			{
//				const t:Number = getTimer();
				renderDecorations();
//				trace('decoration render time:', getTimer() - t);
			}
			
			dispatchEvent(new Event(Event.RENDER));
		}
		
		protected function renderLines():void
		{
			// If we have selection decorations and are re-rendering the lines,
			// re-render the decorations so selection doesn't get out of sync.
			if(_selection.x == _selection.x && _selection.y == _selection.y)
				invalidateDecorationsFlag = true;
			
			boxes.forEach(function(box:Box, i:int, ... args):void {
				if(i >= containers.length) {
					throw new Error('You need as many Sprites as you have Regions.');
				}
				
				const container:Sprite = containers[i];
				
				box.scroll = scroll.clone();
				
				box.parse();
				
				box.render().
					forEach(function(child:DisplayObject, ... args):void {
						container.addChild(child);
					});
				
				observables.register(container);
				
				const scrollRect:Rectangle = box.scrollRect;
				container.scrollRect = scrollRect;
				
				const g:Graphics = container.graphics;
				g.clear();
				g.beginFill(0x00, 0);
				g.drawRect(scrollRect.x, scrollRect.y, scrollRect.width, scrollRect.height);
				g.endFill();
			});
			
			dispatchEvent(new Event(Event.RENDER + 'Lines'));
		}
		
		protected function renderDecorations():void
		{
			decorator.render();
			dispatchEvent(new Event(Event.RENDER + 'Decorations'));
		}
	}
}

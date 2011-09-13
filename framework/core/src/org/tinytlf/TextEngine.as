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
	import org.tinytlf.layout.sector.*;
	
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
		
		[Inject('<TextPane>')]
		public var panes:Array;
		
		[Inject('<Sprite>')]
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
			
			_caretIndex = index = Math.max(index, 0);
			
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
		
		private var _scrollPosition:Number = 0;
		public function get scrollPosition():Number
		{
			return _scrollPosition;
		}
		
		public function set scrollPosition(value:Number):void
		{
			value = Math.min(Math.max(value, 0), llv.size);
			
			if(value == _scrollPosition)
				return;
			
			_scrollPosition = value;
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
			
			decorator.decorate(selection, {
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
				renderLines();
			if(invalidateDecorationsFlag)
				renderDecorations();
			
			dispatchEvent(new Event(Event.RENDER));
		}
		
		protected function renderLines():void
		{
			// If we have selection decorations and are re-rendering the lines,
			// re-render the decorations so selection doesn't get out of sync.
			if(selection.x == selection.x && selection.y == selection.y)
				invalidateDecorationsFlag = true;
			
			var sectors:Array;
			var scrollY:Number = scrollPosition;
			
			panes.forEach(function(pane:TextPane, i:int, ... args):void {
				if(i >= containers.length) {
					throw new Error('You need as many Sprites as you have TextPanes.');
				}
				
				if(sectors) {
					pane.textSectors = sectors;
				}
				
				const container:Sprite = containers[i];
				
				pane.scrollPosition = scrollY;
				pane.render().
					forEach(function(line:TextLine, ... args):void {
						container.addChild(line);
					});
				
				observables.register(container);
				container.scrollRect = new Rectangle(0, scrollY, pane.width, pane.height);
				
				const g:Graphics = container.graphics;
				g.clear();
				g.beginFill(0x00, 0);
				g.drawRect(0, scrollY, pane.width, pane.height);
				g.endFill();
				
				sectors = pane.leftoverSectors;
				scrollY += pane.textHeight;
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

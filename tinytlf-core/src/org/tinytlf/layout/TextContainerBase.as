/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.layout
{
	import flash.display.*;
	import flash.text.engine.*;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.conversion.ITextBlockFactory;
	
	public class TextContainerBase implements ITextContainer
	{
		public function TextContainerBase(container:Sprite, 
										  explicitWidth:Number = NaN, 
										  explicitHeight:Number = NaN)
		{
			this.target = container;
			
			_explicitWidth = explicitWidth;
			_explicitHeight = explicitHeight;
		}
		
		public function layout(block:TextBlock, line:TextLine):TextLine
		{
			return null;
		}
		
		protected function createTextLine(block:TextBlock, previousLine:TextLine):TextLine
		{
			return null;
		}
		
		protected var _target:Sprite;
		
		public function get target():Sprite
		{
			return _target;
		}
		
		public function set target(doc:Sprite):void
		{
			if(doc == _target)
				return;
			
			_target = doc;
			
			foreground = Sprite(target.addChild(fgShapes || new Sprite()));
			lines = Sprite(target.addChild(lines || new Sprite()));
			background = Sprite(target.addChildAt(bgShapes || new Sprite(), 0));
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
		
		private var bgShapes:Sprite;
		
		public function get background():Sprite
		{
			return bgShapes;
		}
		
		public function set background(shapesContainer:Sprite):void
		{
			if(shapesContainer === bgShapes)
				return;
			
			bgShapes = shapesContainer;
		}
		
		private var fgShapes:Sprite;
		
		public function get foreground():Sprite
		{
			return fgShapes;
		}
		
		public function set foreground(shapesContainer:Sprite):void
		{
			if(shapesContainer === fgShapes)
				return;
			
			fgShapes = shapesContainer;
			
			if(fgShapes)
			{
				// Don't let foreground shapes get in the way of interacting
				// with the TextLines.
				fgShapes.mouseEnabled = false;
				//But maybe we do want children to receive mouse events?
				//fgShapes.mouseChildren = false;
			}
		}
		
		private var lineContainer:Sprite;
		
		protected function get lines():Sprite
		{
			return lineContainer;
		}
		
		protected function set lines(container:Sprite):void
		{
			if(container === lineContainer)
				return;
			
			lineContainer = container;
			
			if(lineContainer)
			{
				lineContainer.mouseEnabled = true;
				lineContainer.mouseChildren = false;
			}
		}
		
		protected var _explicitHeight:Number = NaN;
		
		public function get explicitHeight():Number
		{
			return _explicitHeight;
		}
		
		public function set explicitHeight(value:Number):void
		{
			if(value === _explicitHeight)
				return;
			
			_explicitHeight = value;
			invalidateVisibleLines();
			engine.invalidate();
		}
		
		protected var _explicitWidth:Number = NaN;
		
		public function get explicitWidth():Number
		{
			return _explicitWidth;
		}
		
		public function set explicitWidth(value:Number):void
		{
			if(value === _explicitWidth)
				return;
			
			_explicitWidth = value;
			invalidateVisibleLines();
			engine.invalidate();
		}
		
		protected var height:Number = 0;
		
		public function get measuredHeight():Number
		{
			return height;
		}
		
		public function set measuredHeight(value:Number):void
		{
			if(value === height)
				return;
			
			height = value;
		}
		
		protected var width:Number = 0;
		
		public function get measuredWidth():Number
		{
			return width;
		}
		
		public function set measuredWidth(value:Number):void
		{
			if(value === width)
				return;
			
			width = value;
		}
		
		protected var tHeight:Number = 0;
		
		public function get totalHeight():Number
		{
			return tHeight;
		}
		
		public function set totalHeight(value:Number):void
		{
			if(value === tHeight)
				return;
			
			tHeight = value;
		}
		
		protected var tWidth:Number = 0;
		
		public function get totalWidth():Number
		{
			return tWidth;
		}
		
		public function set totalWidth(value:Number):void
		{
			if(value === tWidth)
				return;
			
			tWidth = value;
		}
		
		private var _scrollable:Boolean = true;
		public function get scrollable():Boolean
		{
			return _scrollable;
		}
		
		public function set scrollable(value:Boolean):void
		{
			if(value == _scrollable)
				return;
			
			_scrollable = value;
			if(engine)
				engine.invalidate();
		}
		
		protected var orphanLines:Vector.<TextLine> = new <TextLine>[];
		protected var visibleLines:Vector.<TextLine> = new <TextLine>[];
		
		public function hasLine(line:TextLine):Boolean
		{
			return visibleLines.indexOf(line) != -1;
		}
		
		public function preLayout():void
		{
			var lines:Vector.<TextLine> = visibleLines.concat();
			var n:int = lines.length;
			var l:TextLine;
			
			// Parse through and look for invalid lines.
			for(var i:int = 0; i < n; i += 1)
			{
				l = lines[i];
				
				if(l.validity === TextLineValidity.VALID)
					continue;
				
				orphanLines.unshift(l);
				removeLineFromTarget(l);
			}
		}
		
		public function postLayout():void
		{
			var visibleBlocks:Dictionary = engine.analytics.cachedBlocks;
			var n:int = visibleLines.length;
			var line:TextLine;
			
			for(var i:int = 0; i < n; i += 1)
			{
				line = visibleLines[i];
				if(line.textBlock in visibleBlocks)
					continue;
				
				orphanLines.push(line);
			}
			
			n = orphanLines.length;
			for(i = 0; i < n; i += 1)
			{
				line = orphanLines[i];
				unregisterLine(line);
				removeLineFromTarget(line);
			}
		}
		
		public function resetShapes():void
		{
			clearShapeContainer(foreground);
			clearShapeContainer(background);
		}
		
		private function clearShapeContainer(container:Sprite):void
		{
			if(!container)
				return;
			
			container.graphics.clear();
			var n:int = container.numChildren;
			var child:DisplayObject;
			
			for(var i:int = 0; i < n; ++i)
			{
				child = container.getChildAt(i);
				if(child is Shape)
				{
					Shape(child).graphics.clear();
				}
				else if(child is Sprite)
				{
					Sprite(child).graphics.clear();
					while(Sprite(child).numChildren)
						Sprite(child).removeChildAt(0);
				}
				
			}
		}
		
		protected function registerLine(line:TextLine):void
		{
			if(!hasLine(line))
				visibleLines.push(line);
			
			line.userData = engine;
			engine.interactor.getMirror(line);
		}
		
		protected function unregisterLine(line:TextLine):void
		{
			line.userData = null;
			
			var i:int = visibleLines.indexOf(line);
			if(i != -1)
				visibleLines.splice(i, 1);
		}
		
		protected function addLineToTarget(line:TextLine, index:int = 0):TextLine
		{
			if(lines.contains(line))
				return line;
			
//			index ||= target.numChildren > 1 ? target.numChildren - 1 : 1;
			
			return TextLine(lines.addChildAt(line, index));
		}
		
		protected function removeLineFromTarget(line:TextLine):TextLine
		{
			if(!lines.contains(line))
				return line;
			
			return TextLine(lines.removeChild(line));
		}
		
		protected function getLineIndexFromTarget(line:TextLine):int
		{
			if(!target.contains(line))
				return -1;
			
			return target.getChildIndex(line);
		}
		
		protected function invalidateVisibleLines():void
		{
			var n:int = visibleLines.length;
			for(var i:int = 0; i < n; ++i)
			{
				visibleLines[i].validity = TextLineValidity.INVALID;
			}
			
			totalHeight = 0;
			totalWidth = 0;
		}
		
		protected function getRecycledLine(previousLine:TextLine):TextLine
		{
			if(orphanLines.length == 0)
				return null;
			
			var line:TextLine = previousLine;
			
			while(line === previousLine)
				line = orphanLines.pop();
			
			return line;
		}
	}
}

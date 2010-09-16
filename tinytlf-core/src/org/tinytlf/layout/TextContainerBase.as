/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	
	public class TextContainerBase implements ITextContainer
	{
		public function TextContainerBase(container:Sprite, explicitWidth:Number = NaN, explicitHeight:Number = NaN)
		{
			this.target = container;
			
			_explicitWidth = explicitWidth;
			_explicitHeight = explicitHeight;
		}
		
		public function layout(block:TextBlock, line:TextLine):TextLine
		{
			return null;
		}
		
		public function recreateTextLine(line:TextLine):TextLine
		{
			var hasFocus:Boolean = line.stage.focus === line;
			
			var x:Number = line.x;
			var y:Number = line.y;
			var index:int = getLineIndexFromTarget(line);
			
			unregisterLine(line);
			removeLineFromTarget(line);
			
			var block:TextBlock = line.textBlock;
			
			line = block.createTextLine(line.previousLine, line.specifiedWidth, 0.0, true);
			
			line.x = x;
			line.y = y;
			
			registerLine(line);
			addLineToTarget(line, index);
			
			if(hasFocus)
				target.stage.focus = line;
			
			return line;
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
				fgShapes.mouseChildren = false;
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
			engine.invalidate();
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
		
		public function clear():void
		{
			for(var line:* in lines)
			{
				unregisterLine(line);
				removeLineFromTarget(line);
			}
		}
		
		public function cleanupLines(from:TextBlock):void
		{
			var blockLines:Dictionary = new Dictionary(true);
			var line:TextLine = from.firstLine;
			while(line)
			{
				blockLines[line] = true;
				line = line.nextLine;
			}
			
			for(var obj:* in lines)
			{
				line = TextLine(obj);
				if(line.textBlock == from && !(line in blockLines))
				{
					unregisterLine(line);
					removeLineFromTarget(line);
				}
			}
		}
		
		protected var lines:Dictionary = new Dictionary(false);
		
		public function hasLine(line:TextLine):Boolean
		{
			return (line in lines)
		}
		
		public function postLayout():void
		{
		}
		
		public function resetShapes():void
		{
			if(foreground)
				clearShapeContainer(foreground);
			if(background)
				clearShapeContainer(background);
		}
		
		private function clearShapeContainer(container:Sprite):void
		{
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
			lines[line] = true;
			line.userData = engine;
			line.doubleClickEnabled = true;
			engine.interactor.getMirror(line);
		}
		
		protected function unregisterLine(line:TextLine):void
		{
			line.userData = null;
			
			delete lines[line];
		}
		
		protected function addLineToTarget(line:TextLine, index:int = 0):TextLine
		{
			index ||= target.numChildren > 1 ? target.numChildren - 1 : 1;
			return TextLine(target.addChildAt(line, index));
		}
		
		protected function removeLineFromTarget(line:TextLine):TextLine
		{
			return TextLine(target.removeChild(line));
		}
		
		protected function getLineIndexFromTarget(line:TextLine):int
		{
			return target.getChildIndex(line);
		}
	}
}


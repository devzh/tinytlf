/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.descriptions.TextAlign;
	import org.tinytlf.layout.properties.LayoutProperties;
	
	public class TextContainerBase implements ITextContainer
	{
		public function TextContainerBase(container:Sprite, explicitWidth:Number = NaN, explicitHeight:Number = NaN)
		{
			this.target = container;
			
			_explicitWidth = explicitWidth;
			_explicitHeight = explicitHeight;
		}
		
		protected var layoutPosition:Point = new Point();
		
		public function layout(block:TextBlock, line:TextLine):TextLine
		{
			setupLayoutPosition(block);
			
			line = createAndLayoutLine(block, line);
			while (line)
			{
				if (checkTargetConstraints())
					return line;
				
				line = createAndLayoutLine(block, line);
			}
			
			positionPostLayout(block);
			
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
			
			if (hasFocus)
				target.stage.focus = line;
			
			return line;
		}
		
		protected function setupLayoutPosition(block:TextBlock):void
		{
			var props:LayoutProperties = getLayoutProperties(block);
			
			layoutPosition.x = 0;
			layoutPosition.y = height;
			
			if (block.firstLine == null)
			{
				layoutPosition.x = props.textIndent;
				layoutPosition.y += props.paddingTop;
			}
		}
		
		protected function positionPostLayout(block:TextBlock):void
		{
			var props:LayoutProperties = getLayoutProperties(block);
			
			height = layoutPosition.y + props.paddingBottom;
		}
		
		protected function createAndLayoutLine(block:TextBlock, previousLine:TextLine):TextLine
		{
			var line:TextLine = createTextLine(block, previousLine);
			
			if (!line)
				return null;
			
			registerLine(line);
			
			addLineToTarget(line);
			layoutTextLine(line);
			
			return line;
		}
		
		protected function createTextLine(block:TextBlock, previousLine:TextLine):TextLine
		{
			return block.createTextLine(previousLine, getLineSize(block, previousLine), 0.0, true);
		}
		
		protected function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			var props:LayoutProperties = getLayoutProperties(block);
			var w:Number = getTotalSize(block);
			
			if (previousLine == null)
			{
				w -= props.textIndent;
			}
			
			return w - props.paddingLeft - props.paddingRight;
		}
		
		protected function layoutTextLine(line:TextLine):void
		{
			layoutX(line);
			layoutY(line);
		}
		
		protected function layoutX(line:TextLine):void
		{
			var props:LayoutProperties = getLayoutProperties(line.textBlock);
			var w:Number = getTotalSize(line.textBlock);
			
			var lineWidth:Number = line.width;
			if (lineWidth > width)
				width = lineWidth;
			
			var x:Number = 0;
			
			if (!line.previousLine)
				x += props.textIndent;
			
			switch (props.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					x += props.paddingLeft;
					break;
				case TextAlign.CENTER:
					x = (w - lineWidth) * 0.5;
					break;
				case TextAlign.RIGHT:
					x = w - lineWidth + props.paddingRight;
					break;
			}
			
			line.x = x;
			layoutPosition.x = x;
		}
		
		protected function layoutY(line:TextLine):void
		{
			var props:LayoutProperties = getLayoutProperties(line.textBlock);
			
			layoutPosition.y += line.ascent;
			line.y = layoutPosition.y;
			layoutPosition.y += line.descent + props.leading;
		}
		
		protected function checkTargetConstraints():Boolean
		{
			if (isNaN(explicitHeight))
				return false;
			
			return layoutPosition.y > explicitHeight;
		}
		
		protected var _target:Sprite;
		
		public function get target():Sprite
		{
			return _target;
		}
		
		public function set target(doc:Sprite):void
		{
			if (doc == _target)
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
			if (textEngine == _engine)
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
			if (shapesContainer === bgShapes)
				return;
			
			var children:Vector.<DisplayObject> = storeChildren(fgShapes);
			if (bgShapes && target.contains(bgShapes))
				target.removeChild(bgShapes);
			
			bgShapes = shapesContainer;
			
			if (bgShapes)
				while (children.length)
					bgShapes.addChild(children.shift());
		}
		
		private var fgShapes:Sprite;
		
		public function get foreground():Sprite
		{
			return fgShapes;
		}
		
		public function set foreground(shapesContainer:Sprite):void
		{
			if (shapesContainer === fgShapes)
				return;
			
			var children:Vector.<DisplayObject> = storeChildren(fgShapes);
			if (fgShapes && target.contains(fgShapes))
				target.removeChild(fgShapes);
			
			fgShapes = shapesContainer;
			
			if (fgShapes)
			{
				while (children.length)
					fgShapes.addChild(children.shift());
				
				fgShapes.mouseEnabled = false;
				fgShapes.mouseChildren = false;
			}
		}
		
		private function storeChildren(container:DisplayObjectContainer):Vector.<DisplayObject>
		{
			if (!container)
				return new <DisplayObject>[];
			
			var children:Vector.<DisplayObject> = new <DisplayObject>[];
			while (container.numChildren)
				children.push(container.removeChildAt(0));
			
			return children;
		}
		
		protected var _explicitHeight:Number = NaN;
		
		public function get explicitHeight():Number
		{
			return _explicitHeight;
		}
		
		public function set explicitHeight(value:Number):void
		{
			if (value === _explicitHeight)
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
			if (value === _explicitWidth)
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
			for (var line:* in lines)
			{
				unregisterLine(line);
				removeLineFromTarget(line);
			}
		}
		
		public function cleanupLines(from:TextBlock):void
		{
			var blockLines:Dictionary = new Dictionary(true);
			var line:TextLine = from.firstLine;
			while (line)
			{
				blockLines[line] = true;
				line = line.nextLine;
			}
			
			for (var obj:* in lines)
			{
				line = TextLine(obj);
				if (line.textBlock == from && !(line in blockLines))
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
			layoutPosition.x = 0;
			layoutPosition.y = 0;
		}
		
		public function resetShapes():void
		{
			if(foreground)
			{
				foreground.graphics.clear();
				while (foreground.numChildren)
					foreground.removeChildAt(0);
			}
			if(background)
			{
				background.graphics.clear();
				while (background.numChildren)
					background.removeChildAt(0);
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
		
		protected function getLayoutProperties(element:*):LayoutProperties
		{
			if (element is TextBlock)
			{
				if (TextBlock(element).userData is LayoutProperties)
					return LayoutProperties(TextBlock(element).userData);
				
				return TextBlock(element).userData = new LayoutProperties(null, TextBlock(element));
			}
			
			return new LayoutProperties();
		}
		
		protected function getTotalSize(block:TextBlock):Number
		{
			var props:LayoutProperties = getLayoutProperties(block);
			return isNaN(props.width) ? isNaN(explicitWidth) ? 1000000 : explicitWidth : props.width
		}
	}
}


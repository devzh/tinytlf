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
	
	public class TextContainerBase implements ITextContainer
	{
		public function TextContainerBase(container:DisplayObjectContainer, explicitWidth:Number = NaN, explicitHeight:Number = NaN)
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
			while(line)
			{
				if(checkTargetConstraints())
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
			
			if(block.firstLine == null)
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
			
			if(!line)
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
			layoutPosition.y += line.descent + props.lineHeight;
		}
		
		protected function checkTargetConstraints():Boolean
		{
			if(isNaN(explicitHeight))
				return false;
			
			return layoutPosition.y > explicitHeight;
		}
		
		protected var _target:DisplayObjectContainer;
		
		public function get target():DisplayObjectContainer
		{
			return _target;
		}
		
		public function set target(doc:DisplayObjectContainer):void
		{
			if (doc == _target)
				return;
			
			_target = doc;
			
			shapes = Sprite(target.addChild(new Sprite()));
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
		
		private var _shapes:Sprite;
		
		public function get shapes():Sprite
		{
			return _shapes;
		}
		
		public function set shapes(shapesContainer:Sprite):void
		{
			if (shapesContainer === _shapes)
				return;
			
			var children:Array = [];
			if (shapes)
			{
				while (shapes.numChildren)
					children.push(shapes.removeChildAt(0));
				if (shapes.parent && shapes.parent.contains(shapes))
					shapes.parent.removeChild(shapes);
			}
			
			_shapes = shapesContainer;
			
			if (shapes)
				while (children.length)
					shapes.addChild(children.shift());
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
			if (!shapes)
				return;
			
			shapes.graphics.clear();
			
			while (shapes.numChildren)
				shapes.removeChildAt(0);
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
			index ||= target.numChildren;
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
		
		protected function getLayoutProperties(block:TextBlock):LayoutProperties
		{
			if(block.userData is LayoutProperties)
				return LayoutProperties(block.userData);
			
			return block.userData = new LayoutProperties(null, block);
		}
		
		protected function getTotalSize(block:TextBlock):Number
		{
			var props:LayoutProperties = getLayoutProperties(block);
			return isNaN(props.width) ? isNaN(explicitWidth) ? 1000000 : explicitWidth : props.width
		}
	}
}


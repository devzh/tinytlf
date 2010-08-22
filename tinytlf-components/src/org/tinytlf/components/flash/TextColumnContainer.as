package org.tinytlf.components.flash
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.ITextContainer;
	import org.tinytlf.layout.TextContainerBase;
	
	/**
	 * TextColumnContainer is a Sprite which conveniently implements 
	 * ITextContainer, and composites in a TextContainerBase for the 
	 * implementation. Since it's a Sprite, it's easy to use in component style
	 * layouts without also having to manage and update an external 
	 * ITextContainer.
	 */
	public class TextColumnContainer extends Sprite implements ITextContainer
	{
		public function TextColumnContainer()
		{
			super();
			container = new TextContainerBase(this, 100);
		}
		
		
		private var _height:Number = 0;
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height(value:Number):void
		{
			if(height === value)
				return;
			
			_height = value;
			container.explicitHeight = Math.max(value - 1, 0);
		}
		
		private var _width:Number = 0;
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width(value:Number):void
		{
			if(width === value)
				return;
			
			_width = value;
			container.explicitWidth = Math.max(value - 1, 0);
		}
		
		private var container:ITextContainer;
		
		public function get engine():ITextEngine
		{
			return container.engine;
		}
		
		public function set engine(textEngine:ITextEngine):void
		{
			container.engine = textEngine;
		}
		
		public function get target():DisplayObjectContainer
		{
			return this;
		}
		
		public function set target(textContainer:DisplayObjectContainer):void
		{
			//do nothing
		}
		
		public function get shapes():Sprite
		{
			return container.shapes;
		}
		
		public function set shapes(shapesContainer:Sprite):void
		{
			container.shapes = shapesContainer;
		}
		
		public function get explicitWidth():Number
		{
			return container.explicitWidth;
		}
		
		public function set explicitWidth(value:Number):void
		{
			container.explicitWidth = value;
		}
		
		public function get explicitHeight():Number
		{
			return container.explicitHeight;
		}
		
		public function set explicitHeight(value:Number):void
		{
			container.explicitHeight = value;
		}
		
		public function get measuredWidth():Number
		{
			return container.measuredWidth;
		}
		
		public function get measuredHeight():Number
		{
			return container.measuredHeight;
		}
		
		public function clear():void
		{
			container.clear();
		}
		
		public function resetShapes():void
		{
			container.resetShapes();
		}
		
		public function prepForLayout():void
		{
			container.prepForLayout();
		}
		
		public function cleanupLines(fromBlock:TextBlock):void
		{
			container.cleanupLines(fromBlock);
		}
		
		public function layout(block:TextBlock, line:TextLine):TextLine
		{
			return container.layout(block, line);
		}
		
		public function recreateTextLine(line:TextLine):TextLine
		{
			return container.recreateTextLine(line);
		}
		
		public function hasLine(line:TextLine):Boolean
		{
			return container.hasLine(line);
		}
	}
}
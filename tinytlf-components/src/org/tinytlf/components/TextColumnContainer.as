package org.tinytlf.components
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.engine.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.constraints.*;
	import org.tinytlf.layout.orientation.*;
	
	[Event(name="initScrollBar", type="flash.events.Event")]
	
	/**
	 * TextColumnContainer is a Sprite which conveniently implements
	 * ITextContainer, and composites in a TextContainerBase for the
	 * implementation. Since it's a Sprite, it's easy to use in component style
	 * layouts without also having to manage and update an external
	 * ITextContainer.
	 */
	public class TextColumnContainer extends Sprite implements IConstraintTextContainer
	{
		public function TextColumnContainer()
		{
			super();
			
			focusRect = false;
			
			container = new ConstraintTextContainer(this, 100);
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
			
			_height = Math.max(value, 1);
			explicitHeight = value;
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
			
			_width = Math.max(value, 1);
			explicitWidth = _width;
		}
		
		private var container:IConstraintTextContainer;
		
		public function get engine():ITextEngine
		{
			return container.engine;
		}
		
		public function set engine(textEngine:ITextEngine):void
		{
			container.engine = textEngine;
		}
		
		public function get target():Sprite
		{
			return this;
		}
		
		public function set target(textContainer:Sprite):void
		{
			//do nothing
		}
		
		public function get background():Sprite
		{
			return container.background;
		}
		
		public function set background(shapesContainer:Sprite):void
		{
			container.background = shapesContainer;
		}
		
		public function get foreground():Sprite
		{
			return container.foreground;
		}
		
		public function set foreground(shapesContainer:Sprite):void
		{
			container.foreground = shapesContainer;
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
		
		public function set measuredWidth(value:Number):void
		{
			container.measuredWidth = value;
		}
		
		public function get measuredHeight():Number
		{
			return container.measuredHeight;
		}
		
		public function set measuredHeight(value:Number):void
		{
			container.measuredHeight = value;
		}
		
		public function get totalWidth():Number
		{
			return container.totalWidth;
		}
		
		public function set totalWidth(value:Number):void
		{
			container.totalWidth = value;
		}
		
		public function get totalHeight():Number
		{
			return container.totalHeight;
		}
		
		public function set totalHeight(value:Number):void
		{
			container.totalHeight = value;
		}
		
		public function get scrollable():Boolean
		{
			return container.scrollable;
		}
		
		public function set scrollable(value:Boolean):void
		{
			container.scrollable = value;
		}
		
		public function resetShapes():void
		{
			container.resetShapes();
		}
		
		public function preLayout():void
		{
			container.preLayout();
		}
		
		public function postLayout():void
		{
			container.postLayout();
			
			if(scrollable && measuredHeight > explicitHeight)
			{
				dispatchEvent(new Event('initScrollBar', true, true));
			}
			
			drawBackground();
		}
		
		public function layout(block:TextBlock, line:TextLine):TextLine
		{
			return container.layout(block, line);
		}
		
		public function hasLine(line:TextLine):Boolean
		{
			return container.hasLine(line);
		}
		
		public function get majorDirection():IMajorOrientation
		{
			return container.majorDirection;
		}
		
		public function set majorDirection(delegate:IMajorOrientation):void
		{
			container.majorDirection = delegate;
		}
		
		public function get minorDirection():IMinorOrientation
		{
			return container.minorDirection;
		}
		
		public function set minorDirection(delegate:IMinorOrientation):void
		{
			container.minorDirection = delegate;
		}
		
		public function set constraintFactory(factory:IConstraintFactory):void
		{
			container.constraintFactory = factory;
		}
		
		public function get constraintFactory():IConstraintFactory
		{
			return container.constraintFactory;
		}
		
		public function get constraints():Vector.<ITextConstraint>
		{
			return container.constraints;
		}
		
		public function addConstraint(constraint:ITextConstraint):void
		{
			container.addConstraint(constraint);
		}
		
		public function getConstraint(element:*):ITextConstraint
		{
			return container.getConstraint(element);
		}
		
		public function removeConstraint(constraint:ITextConstraint):void
		{
			container.removeConstraint(constraint);
		}
		
		private function drawBackground():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0x00, 0.1);
			g.drawRect(0, 0, 
				explicitWidth || measuredWidth || width, 
				explicitHeight || measuredHeight || height);
		}
	}
}
package org.tinytlf.layout.direction
{
	import flash.geom.Point;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.FlowLayoutElement;
	import org.tinytlf.layout.IFlowLayout;
	import org.tinytlf.layout.IFlowLayoutElement;
	import org.tinytlf.layout.ILayoutElementFactory;
	import org.tinytlf.layout.properties.TextAlign;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class DirectionDelegateBase implements IFlowDirectionDelegate
	{
		public function DirectionDelegateBase(target:IFlowLayout)
		{
			this.target = target;
			elementFactory = new LayoutElementFactory();
		}
		
		/**
		 * Checks to see if we've laid out lines within the boundaries of our
		 * target container. Returns true if we're outside bounds, false if we aren't.
		 */
		public function checkTargetConstraints():Boolean
		{
			var elements:Vector.<IFlowLayoutElement> = layout.elements;
			
			if(!elements.length)
				return false;
			
			// Return true if the last IFlowLayoutElement is a 
			// ContainerTerminator, which causes tinytlf to stop laying out in 
			// this container and move on to the next one.
			return (elements[elements.length - 1].element.userData === TextLineUtil.getSingletonMarker('containerTerminator'));
		}
		
		public function prepForTextBlock(block:TextBlock):void
		{
		}
		
		protected var layoutPosition:Point = new Point();
		
		public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			var props:LayoutProperties = getLayoutProperties(block);
			var w:Number = getTotalSize(block);
			
			if (previousLine == null)
			{
				w -= props.textIndent;
			}
			
			return w - props.paddingLeft - props.paddingRight;
		}
		
		public function layoutLine(latestLine:TextLine):void
		{
			layoutX(latestLine);
			layoutY(latestLine);
		}
		
		
		/**
		 * Called when an element can potentially be added to the list of
		 * IFlowLayoutElements. Override this to respect more types of layout
		 * elements.
		 */
		public function registerFlowElement(line:TextLine, atomIndex:int):Boolean
		{
			var element:IFlowLayoutElement;
			var contentElement:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
			if(contentElement.userData === TextLineUtil.getSingletonMarker('listItemTerminator'))
			{
				handleListItemTermination();
			}
			else
			{
				element = elementFactory.getLayoutElement(line, atomIndex);
				element.textLine = line;
				layout.elements.push(element);
			}
			
			return (contentElement.userData === TextLineUtil.getSingletonMarker('containerTerminator'))
		}
		
		protected var layout:IFlowLayout;
		
		public function set target(flowLayout:IFlowLayout):void
		{
			if(flowLayout === layout)
				return;
			
			layout = flowLayout;
		}
		
		public function get target():IFlowLayout
		{
			return layout;
		}
		
		private var _elementFactory:ILayoutElementFactory;
		
		public function set elementFactory(factory:ILayoutElementFactory):void
		{
			if(factory === _elementFactory)
				return;
			
			_elementFactory = factory;
		}
		
		public function get elementFactory():ILayoutElementFactory
		{
			return _elementFactory;
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
			// A double nested ternary... it's so beautiful! what does it mean?! Ohhhh...
			return isNaN(props.width) ? isNaN(layout.explicitWidth) ? 1000000 : layout.explicitWidth : props.width;
		}
		
		protected function layoutX(line:TextLine):void
		{
			var props:LayoutProperties = getLayoutProperties(line.textBlock);
			var w:Number = getTotalSize(line.textBlock);
			
			var lineWidth:Number = line.width;
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
		
		
		/**
		 * When we get to the end of list item, traverse backwards in the
		 * LayoutElement list to the first LIST_ITEM element and remove it.
		 * This ensures we stop flowing around the bullet graphic.
		 */
		protected function handleListItemTermination():void
		{
			var elements:Vector.<IFlowLayoutElement> = layout.elements;
			for(var i:int = elements.length - 1; i >= 0; --i)
			{
				if(elements[i].element.userData === TextLineUtil.getSingletonMarker('listItem'))
				{
					removeLayoutElement(elements[i]);
					break;
				}
			}
		}
		
		protected function removeLayoutElement(element:IFlowLayoutElement):void
		{
			var elements:Vector.<IFlowLayoutElement> = layout.elements;
			elements.splice(elements.indexOf(element), 1);
		}
	}
}


import flash.text.engine.ContentElement;
import flash.text.engine.TextLine;

import org.tinytlf.layout.FlowLayoutElement;
import org.tinytlf.layout.IFlowLayoutElement;
import org.tinytlf.layout.ILayoutElementFactory;
import org.tinytlf.util.fte.TextLineUtil;

internal class LayoutElementFactory implements ILayoutElementFactory
{
	public function getLayoutElement(line:TextLine, atomIndex:int):IFlowLayoutElement
	{
		var element:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
		return new FlowLayoutElement(element, line);
	}
}

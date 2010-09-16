package org.tinytlf.layout
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.TextLine;
	
	public class FlowLayoutElement implements IFlowLayoutElement
	{
		public function FlowLayoutElement(element:ContentElement, line:TextLine = null)
		{
			if(element is GraphicElement)
			{
				var graphic:DisplayObject = GraphicElement(element).graphic;
				this.line ||= (graphic.parent as TextLine);
				rect = graphic.getBounds(line);
				rect.x = Math.round(rect.x);
				rect.y = Math.round(rect.y);
				rect.width = Math.round(rect.width);
				rect.height = Math.round(rect.height);
			}
			else
			{
				rect = new Rectangle();
			}
			
			this.element = element;
		}
		
		protected var rect:Rectangle;
		
		private var _element:ContentElement;
		public function get element():ContentElement
		{
			return _element;
		}
		
		public function set element(value:ContentElement):void
		{
			if(value === _element)
				return;
			
			_element = value;
		}
		
		private var line:TextLine;
		public function get textLine():TextLine
		{
			return line;
		}
		
		public function set textLine(theLine:TextLine):void
		{
			if(theLine === line)
				return;
			
			line = theLine;
		}
		
		public function get x():Number
		{
			return rect.x + textLine.x;
		}
		
		public function set x(value:Number):void
		{
			rect.x = value;
		}
		
		public function get y():Number
		{
			return rect.y + textLine.y;
		}
		
		public function set y(value:Number):void
		{
			rect.y = value;
		}
		
		public function get width():Number
		{
			return rect.width;
		}
		
		public function get height():Number
		{
			return rect.height;
		}
		
		public function containsX(checkX:Number):Boolean
		{
			return checkX >= x && checkX < (x + width);
		}
		
		public function containsY(checkY:Number):Boolean
		{
			return checkY >= y && checkY < (y + height);
		}
	}
}
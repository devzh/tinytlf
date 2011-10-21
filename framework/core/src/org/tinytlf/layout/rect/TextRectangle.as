package org.tinytlf.layout.rect
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.util.*;
	
	public class TextRectangle extends Styleable
	{
		[Inject]
		public var injector:Injector;
		
		public function dispose():void
		{
		}
		
		private var dom:IDOMNode;
		public function get domNode():IDOMNode
		{
			return dom;
		}
		
		public function set domNode(node:IDOMNode):void
		{
			if(dom == node)
				return;
			
			dom = node;
			injector.injectInto(dom);
			mergeWith(dom);
			invalidate();
		}
		
		protected var invalid:Boolean = true;
		public function get invalidated():Boolean
		{
			return invalid;
		}
		
		public function invalidate():void
		{
			invalid = true;
		}
		
		protected const parseCache:Array = [];
		public function get parsedRectangleCache():Array
		{
			return parseCache.concat();
		}
		
		public function parse():Array /*<TextRectangle>*/
		{
			if(invalidated)
			{
				parseCache.length = 0;
				parseCache.push.apply(null, internalParse());
			}
			
			return parsedRectangleCache;
		}
		
		protected function internalParse():Array /*<TextRectangle>*/
		{
			return [this];
		}
		
		protected function injectInto(dom:IDOMNode, recurse:Boolean = false):void
		{
			for(var i:int, n:int = dom.numChildren; i < n; ++i)
			{
				const child:IDOMNode = dom.getChildAt(i);
				injector.injectInto(child);
				if(recurse)
					injectInto(child, recurse);
			}
		}
		
		public function render():Array
		{
			progression.alignment = getAlignmentForProgression(textAlign, blockProgression);
			invalid = false;
			return children;
		}
		
		public function getSelectionRects(start:int, end:int):Array /*<Rectangle>*/
		{
			const rects:Array = [];
			kids.forEach(function(child:DisplayObject, ...args):void {
				rects.push(child.getBounds(child));
			});
			return rects;
		}
		
		public function addChild(child:DisplayObject):DisplayObject
		{
			kids.push(child);
			return child;
		}
		
		public function removeChild(child:DisplayObject):DisplayObject
		{
			const i:int = kids.indexOf(child);
			if(i != -1)
				kids.splice(1, i);
			return child;
		}
		
		private var _progression:IProgression = new TTBProgression();
		public function get progression():IProgression
		{
			return _progression;
		}
		
		public function set progression(p:IProgression):void
		{
			_progression = p;
		}
		
		private var leadingValue:Number = 0;
		public function get leading():Number
		{
			return leadingValue;
		}
		
		public function set leading(value:Number):void
		{
			if(value == leadingValue)
				return;
			
			leadingValue = value;
			invalidate();
		}
		
		private var paddingLeftValue:Number = 0;
		public function get paddingLeft():Number
		{
			return paddingLeftValue;
		}
		
		public function set paddingLeft(value:Number):void
		{
			if(value == paddingLeftValue)
				return;
			
			paddingLeftValue = value;
			invalidate();
		}
		
		private var paddingRightValue:Number = 0;
		public function get paddingRight():Number
		{
			return paddingRightValue;
		}
		
		public function set paddingRight(value:Number):void
		{
			if(value == paddingRightValue)
				return;
			
			paddingRightValue = value;
			invalidate();
		}
		
		private var paddingTopValue:Number = 0;
		public function get paddingTop():Number
		{
			return paddingTopValue;
		}
		
		public function set paddingTop(value:Number):void
		{
			if(value == paddingTopValue)
				return;
			
			paddingTopValue = value;
			invalidate();
		}
		
		private var paddingBottomValue:Number = 0;
		public function get paddingBottom():Number
		{
			return paddingBottomValue;
		}
		
		public function set paddingBottom(value:Number):void
		{
			if(value == paddingBottomValue)
				return;
			
			paddingBottomValue = value;
			invalidate();
		}
		
		protected var bProgression:String = TextBlockProgression.TTB;
		public function get blockProgression():String
		{
			return bProgression;
		}
		
		public function set blockProgression(value:String):void
		{
			if(!TextBlockProgression.isValid(value))
				value = TextBlockProgression.TTB;
			
			if(value == blockProgression)
				return;
			
			bProgression = value;
			switch(blockProgression)
			{
				case TextBlockProgression.TTB:
					progression = new TTBProgression();
					break;
				case TextBlockProgression.LTR:
					progression = new LTRProgression();
					break;
				case TextBlockProgression.RTL:
					progression = new RTLProgression();
					break;
			}
			
			invalidate();
		}
		
		private var align:String = TextAlign.LEFT;
		public function get textAlign():String
		{
			return align;
		}
		
		public function set textAlign(value:String):void
		{
			if(!TextAlign.isValid(value))
				value = TextAlign.LEFT;
			
			if(value == align)
				return;
			
			align = value;
			
			invalidate();
		}
		
		protected const kids:Array = [];
		public function get children():Array
		{
			return kids.concat();
		}
		
		protected var th:Number = 0;
		public function get textHeight():Number
		{
			return th;
		}
		
		protected var tw:Number = 0;
		public function get textWidth():Number
		{
			return tw;
		}
		
		/*
		* TextSector component methods.
		*/
		
		private var w:Number = NaN;
		
		[PercentProxy("percentWidth")]
		
		public function get width():Number
		{
			return w || 0;
		}
		
		public function set width(value:Number):void
		{
			if(value == w)
				return;
			
			w = value;
			invalidate();
		}
		
		private var h:Number = NaN;
		
		[PercentProxy("percentHeight")]
		
		public function get height():Number
		{
			return h || 0;
		}
		
		public function set height(value:Number):void
		{
			if(value == h)
				return;
			
			h = value;
			invalidate();
		}
		
		private var pw:Number = NaN;
		public function get percentWidth():Number
		{
			return pw;
		}
		
		public function set percentWidth(value:Number):void
		{
			if(value == pw)
				return;
			
			pw = value;
			invalidate();
		}
		
		private var ph:Number = NaN;
		public function get percentHeight():Number
		{
			return ph;
		}
		
		public function set percentHeight(value:Number):void
		{
			if(value == ph)
				return;
			
			ph = value;
			invalidate();
		}
		
		protected var xValue:Number = 0;
		public function get x():Number
		{
			return xValue;
		}
		
		public function set x(value:Number):void
		{
			if(value == xValue)
				return;
			
			if(parseCache.length > 1)
			{
				const thisRect:TextRectangle = this;
				parseCache.forEach(function(rect:TextRectangle, ... args):void {
					if(rect == thisRect)
						return;
					rect.x += value - x;
				});
			}
			else
			{
				invalidate();
			}
			
			xValue = value;
		}
		
		protected var yValue:Number = 0;
		public function get y():Number
		{
			return yValue;
		}
		
		public function set y(value:Number):void
		{
			if(value == yValue)
				return;
			
			if(parseCache.length > 1)
			{
				const thisRect:TextRectangle = this;
				parseCache.forEach(function(rect:TextRectangle, ... args):void {
					if(rect == thisRect)
						return;
					rect.y += value - y;
				});
			}
			else
			{
				invalidate();
			}
			
			yValue = value;
		}
	}
}

package org.tinytlf.layout.sector
{
	import flash.display.DisplayObject;
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.util.*;
	
	public class TextRectangle extends Styleable
	{
		[Inject]
		public var injector:Injector;
		
		protected var progressor:IProgressor = new TTBProgressor();
		protected var aligner:IAligner = new LeftAligner();
		
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
		public function parse():Array /*<TextRectangle>*/
		{
			if(invalidated)
			{
				parseCache.length = 0;
				parseCache.push.apply(null, internalParse());
			}
			
			return parseCache;
		}
		
		protected function internalParse():Array /*<TextRectangle>*/
		{
			return [this];
		}
		
		protected function injectInto(children:Array, recurse:Boolean = false):void
		{
			children.forEach(function(child:IDOMNode, ... args):void {
				injector.injectInto(child);
				
				if(recurse)
				{
					injectInto(child.children, recurse);
				}
			});
		}
		
		public function render():Array
		{
			invalid = false;
			return children;
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
		
		protected var blockProgression:String = TextBlockProgression.TTB;
		public function get progression():String
		{
			return blockProgression;
		}
		
		public function set progression(value:String):void
		{
			if(!TextBlockProgression.isValid(value))
				value = TextBlockProgression.TTB;
			
			if(value == blockProgression)
				return;
			
			blockProgression = value;
			switch(blockProgression)
			{
				case TextBlockProgression.BTT:
					progressor = new BTTProgressor();
					break;
				case TextBlockProgression.TTB:
					progressor = new TTBProgressor();
					break;
				case TextBlockProgression.LTR:
					progressor = new LTRProgressor();
					break;
				case TextBlockProgression.RTL:
					progressor = new RTLProgressor();
					break;
			}
			
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
		
		private var xValue:Number = 0;
		public function get x():Number
		{
			return xValue;
		}
		
		public function set x(value:Number):void
		{
			if(value == xValue)
				return;
			
			xValue = value;
			invalidate();
		}
		
		private var yValue:Number = 0;
		public function get y():Number
		{
			return yValue;
		}
		
		public function set y(value:Number):void
		{
			if(value == yValue)
				return;
			
			yValue = value;
			invalidate();
		}
	}
}

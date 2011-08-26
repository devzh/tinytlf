package org.tinytlf.layout.sector
{
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.tinytlf.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.util.*;
	
	use namespace flash_proxy;
	
	public class TextRectangle extends Styleable
	{
		protected var progressor:IProgressor = new TTBProgressor();
		protected var aligner:IAligner = new LeftAligner();
		
		public function dispose():void
		{
			lines.forEach(function(line:TextLine, ... args):void {
				TextLineUtil.checkIn(line);
			});
			lines.length = 0;
		}
		
		public function render():Array
		{
			return textLines;
		}
		
		protected var invalidated:Boolean = true;
		public function get invalid():Boolean
		{
			return invalidated;
		}
		
		public function invalidate():void
		{
			invalidated = true;
			lines.forEach(function(line:TextLine, ... args):void {
				line.validity = TextLineValidity.INVALID;
			});
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
		
		protected var lines:Array = [];
		public function get textLines():Array
		{
			return lines.concat();
		}
		
		/*
		* Text manipulation and metrics methods.
		*/
		
		public function indexToLine(index:int):TextLine
		{
			return null;
//			return lines.filter(function(l:TextLine, ... args):Boolean {
//				return (index >= l.textBlockBeginIndex && (index - l.textBlockBeginIndex) < l.atomCount);
//			})[0] as TextLine;
		}
		
		public function indexToElement(index:int):ContentElement
		{
			return null;
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
	}
}

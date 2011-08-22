package org.tinytlf.layout
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.engine.*;
	
	import org.tinytlf.*;
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.util.*;
	
	public final class TextSector extends Styleable
	{
		private var progressor:IBlockProgressor = new TTBProgressor();
		private var aligner:IBlockAligner = new LeftAligner();
		private var renderer:IBlockRenderer = new StandardBlockRenderer(aligner, progressor);
		private var layout:IBlockLayout = new StandardBlockLayout(aligner, progressor);
		
		public function render():void
		{
			if(!invalid)
				return;
			
			th = 0;
			tw = 0;
			
			if(textBlock)
			{
				if(textAlign == TextAlign.JUSTIFY)
					setupBlockJustifier(textBlock);
				
				textBlock.bidiLevel = direction == TextDirection.LTR ? 0 : 1;
				
				// Do the magic.
				lines = layout.layout(renderer.render(textBlock, this), this)
					.map(function(line:TextLine, ... args):TextLine {
						line.x += x;
						line.y += y;
						return line;
					});
			}
			
			tw = progressor.getTotalHorizontalSize(this, lines);
			th = progressor.getTotalVerticalSize(this, lines);
		}
		
		/*
		 * TextRegion linked list impl.
		 */
		private var prev:TextSector;
		public function get previousRegion():TextSector
		{
			return prev;
		}
		
		public function set previousRegion(value:TextSector):void
		{
			if(value == prev)
				return;
			
			prev = value;
		}
		
		private var next:TextSector;
		
		public function get nextRegion():TextSector
		{
			return next;
		}
		
		public function set nextRegion(value:TextSector):void
		{
			if(next == value)
				return;
			
			next = value;
		}
		
		/*
		 * Text manipulation and metrics methods.
		 */
		
		public function indexToLine(index:int):TextLine
		{
			return lines.filter(function(l:TextLine, ... args):Boolean {
				return (index >= l.textBlockBeginIndex && (index - l.textBlockBeginIndex) < l.atomCount);
			})[0] as TextLine;
		}
		
		public function indexToElement(index:int):ContentElement
		{
			if(!textBlock)
				return null;
			
			return ContentElementUtil.getLeaf(textBlock.content, index);
		}
		
		private var lines:Array = [];
		public function get textLines():Array
		{
			return lines.concat();
		}
		
		private var th:Number = 0;
		public function get textHeight():Number
		{
			return th;
		}
		
		private var tw:Number = 0;
		public function get textWidth():Number
		{
			return tw;
		}
		
		/*
		 * TextRegion component methods.
		 */
		
		private var w:Number = NaN;
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
		
		/*
		 * Formatting properties.
		 */
		private var direction:String = TextDirection.LTR;
		public function get textDirection():String
		{
			return direction;
		}
		
		public function set textDirection(value:String):void
		{
			if(!TextDirection.isValid(value))
				value = TextDirection.LTR;
			
			if(value == direction)
				return;
			
			direction = value;
			invalidate();
		}
		
		private var localValue:String = 'en';
		public function get locale():String
		{
			return localValue;
		}
		
		public function set locale(value:String):void
		{
			if(value == localValue)
				return;
			
			localValue = value;
			invalidate();
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
		
		private var blockProgression:String = TextBlockProgression.TTB;
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
			
			renderer.progressor = progressor;
			layout.progressor = progressor;
			
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
			
			switch(value)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					aligner = new LeftAligner();
					break;
				case TextAlign.RIGHT:
					aligner = new RightAligner();
					break;
				case TextAlign.CENTER:
					aligner = new CenterAligner();
					break;
			}
			
			renderer.aligner = aligner;
			layout.aligner = aligner;
			
			invalidate();
		}
		
		private var block:TextBlock;
		public function get textBlock():TextBlock
		{
			return block;
		}
		
		public function set textBlock(value:TextBlock):void
		{
			if(value == block)
				return;
			
			block = value;
			invalidate();
		}
		
		private var indent:Number = 0;
		public function get textIndent():Number
		{
			return indent;
		}
		
		public function set textIndent(value:Number):void
		{
			if(value == indent)
				return;
			
			indent = value;
			invalidate();
		}
		
		private var invalid:Boolean = true;
		private function invalidate():void
		{
			invalid = true;
			lines.forEach(function(line:TextLine, ... args):void {
				line.validity = TextLineValidity.INVALID;
			});
		}
		
		private function setupBlockJustifier(block:TextBlock):void
		{
			const justification:String = textAlign == TextAlign.JUSTIFY ?
				LineJustification.ALL_BUT_LAST : LineJustification.UNJUSTIFIED;
			
			const justifier:TextJustifier = TextJustifier.getJustifierForLocale(locale);
			justifier.lineJustification = justification;
			
			if(!block.textJustifier ||
				block.textJustifier.lineJustification != justification ||
				block.textJustifier.locale != locale)
			{
				applyTo(justifier);
				block.textJustifier = justifier;
			}
		}
	}
}

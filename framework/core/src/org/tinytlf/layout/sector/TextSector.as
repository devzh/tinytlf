package org.tinytlf.layout.sector
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.tinytlf.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.util.*;
	
	public dynamic class TextSector extends TextRectangle
	{
		private var renderer:ISectorRenderer = new StandardSectorRenderer(aligner, progressor);
		private var layout:ISectorLayout = new StandardSectorLayout(aligner, progressor);
		
		public function TextSector()
		{
			super();
			
			renderer.aligner = layout.aligner = aligner;
			renderer.progressor = layout.progressor = progressor;
		}
		
		override public function render():Array
		{
			if(!invalid)
				return [];
			
			th = 0;
			tw = 0;
			
			if(textBlock)
			{
				if(textAlign == TextAlign.JUSTIFY)
					setupBlockJustifier(textBlock);
				
				textBlock.bidiLevel = direction == TextDirection.LTR ? 0 : 1;
				
				// Do the magic.
				kids = layout.layout(renderer.render(textBlock, this), this)
					.map(function(line:TextLine, ... args):TextLine {
						line.x += x;
						line.y += y;
						return line;
					});
			}
			
			tw = progressor.getTotalHorizontalSize(this);
			th = progressor.getTotalVerticalSize(this);
			
			invalidated = false;
			
			return children;
		}
		
		/*
		 * TextSector linked list impl.
		 */
		private var prev:TextSector;
		public function get previousSector():TextSector
		{
			return prev;
		}
		
		public function set previousSector(value:TextSector):void
		{
			if(value == prev)
				return;
			
			prev = value;
		}
		
		private var next:TextSector;
		
		public function get nextSector():TextSector
		{
			return next;
		}
		
		public function set nextSector(value:TextSector):void
		{
			if(next == value)
				return;
			
			next = value;
		}
		
		/*
		 * TextSector component properties and methods.
		 */
		
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
		
		override public function set progression(value:String):void
		{
			super.progression = value;
			
			renderer.progressor = progressor;
			layout.progressor = progressor;
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

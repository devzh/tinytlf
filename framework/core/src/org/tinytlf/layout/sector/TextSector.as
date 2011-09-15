package org.tinytlf.layout.sector
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.content.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.util.*;
	
	public class TextSector extends TextRectangle
	{
		[Inject]
		public var cefm:IContentElementFactoryMap;
		
		private var renderer:ISectorRenderer = new StandardSectorRenderer(aligner, progressor);
		private var layout:ISectorLayout = new StandardSectorLayout(aligner, progressor);
		
		public function TextSector()
		{
			super();
			
			renderer.aligner = layout.aligner = aligner;
			renderer.progressor = layout.progressor = progressor;
		}
		
		override public function dispose():void
		{
			invalidate();
			
			kids.length = 0;
			
			if(!block)
				return;
			
			if(block.firstLine)
				block.releaseLines(block.firstLine, block.lastLine);
			block.releaseLineCreationData();
			
			TextBlockUtil.checkIn(block);
			block = null;
		}
		
		private var block:TextBlock;
		
		override protected function internalParse():Array
		{
			if(block)
				TextBlockUtil.checkIn(block);
			
			injectInto(domNode.children, true);
			
			if(domNode.content == null)
			{
				domNode.content = cefm.instantiate(domNode.name).create(domNode);
			}
			
			block = TextBlockUtil.checkOut();
			block.content = domNode.content;
			
			trace('parsing content for:', block.content.rawText);
			
			return super.internalParse();
		}
		
		override public function invalidate():void
		{
			kids.forEach(function(line:TextLine, ... args):void {
				TextLineUtil.checkIn(TextLineUtil.cleanLine(line));
			});
			super.invalidate();
		}
		
		override public function render():Array
		{
			if(block && (invalid || TextBlockUtil.isInvalid(block)))
			{
				th = 0;
				tw = 0;
				
				if(textAlign == TextAlign.JUSTIFY)
					setupBlockJustifier(block);
				
				block.bidiLevel = direction == TextDirection.LTR ? 0 : 1;
				
				kids.forEach(function(line:TextLine, ... args):void {
					if(line.parent) line.parent.removeChild(line);
				});
				kids.length = 0;
				
				// Do the magic.
				kids.push.apply(null, layout.layout(renderer.render(block, this), this)
								.map(function(line:TextLine, ... args):TextLine {
									line.x += x;
									line.y += y;
									return line;
								}));
				
				tw = progressor.getTotalHorizontalSize(this);
				th = progressor.getTotalVerticalSize(this);
			}
			
			invalid = false;
			
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

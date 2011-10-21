package org.tinytlf.layout.rect
{
	import flash.geom.*;
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.rect.*;
	
	public dynamic class TextPaneRow extends Array
	{
		public function TextPaneRow(... args)
		{
			super();
			
			if(args.length == 1 && args[0] is int || args[0] is uint)
				length = args[0];
			else
				push.apply(null, args);
		}
		
		private var blockProgression:String = TextBlockProgression.TTB;
		
		public function set progression(value:String):void
		{
			blockProgression = TextBlockProgression.isValid(value) ? value : TextBlockProgression.TTB;
		}
		
		public var startRectangleIndex:int = 0;
		public var x:Number = 0;
		public var y:Number = 0;
		
		public function get progressionSize():Number
		{
			var s:Number = 0;
			forEach(function(rect:TextRectangle, ... args):void {
				if(blockProgression == TextBlockProgression.LTR || blockProgression == TextBlockProgression.RTL)
					s += (rect.width || rect.textWidth);
				else if(blockProgression == TextBlockProgression.TTB)
					s += (rect.height || rect.textHeight);
			});
			return Math.ceil(s);
		}
		
		public function get layoutSize():Number
		{
			var s:Number = 0;
			forEach(function(rect:TextRectangle, ... args):void {
				if(blockProgression == TextBlockProgression.LTR || blockProgression == TextBlockProgression.RTL)
					s += (rect.height || rect.textHeight);
				else if(blockProgression == TextBlockProgression.TTB)
					s += (rect.width || rect.textWidth);
			});
			return Math.ceil(s);
		}
		
		public function pushRectangle(... rects):uint
		{
			const prop:String = blockProgression == TextBlockProgression.TTB ? 'x' : 'y';
			
			rects.forEach(function(rect:TextRectangle, ... args):void {
				rect[prop] += layoutSize;
				push(rect);
			});
			
			return length;
		}
	}
}
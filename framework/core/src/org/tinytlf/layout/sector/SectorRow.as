package org.tinytlf.layout.sector
{
	import flash.geom.Point;
	
	import org.tinytlf.layout.*;
	
	public dynamic class SectorRow extends Array
	{
		public function SectorRow(... args)
		{
			super();
			
			if(args.length == 1 && args[0] is int || args[0] is uint)
				length = args[0];
			else
				push.apply(null, args);
		}
		
		private var progression:String = TextBlockProgression.TTB;
		
		public function set blockProgression(value:String):void
		{
			progression = TextBlockProgression.isValid(value) ? value : TextBlockProgression.TTB;
		}
		
		public var x:Number = 0;
		public var y:Number = 0;
		
		public function get progressionSize():Number
		{
			var s:Number = 0;
			forEach(function(sector:TextRectangle, ... args):void {
				if(progression == TextBlockProgression.LTR || progression == TextBlockProgression.RTL)
					s += (sector.width || sector.textWidth);
				else if(progression == TextBlockProgression.TTB || progression == TextBlockProgression.BTT)
					s += (sector.height || sector.textHeight);
			});
			return Math.ceil(s);
		}
		
		public function get layoutSize():Number
		{
			var s:Number = 0;
			forEach(function(sector:TextRectangle, ... args):void {
				if(progression == TextBlockProgression.LTR || progression == TextBlockProgression.RTL)
					s += (sector.height || sector.textHeight);
				else if(progression == TextBlockProgression.TTB || progression == TextBlockProgression.BTT)
					s += (sector.width || sector.textWidth);
			});
			return Math.ceil(s);
		}
		
		public function pushRectangle(... rects):uint
		{
			const prop:String = (progression == TextBlockProgression.TTB ||
				progression == TextBlockProgression.BTT) ? 'x' : 'y';
			
			rects.forEach(function(rect:TextRectangle, ... args):void {
				rect[prop] += layoutSize;
				push(rect);
			});
			
			return length;
		}
	}
}

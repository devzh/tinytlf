package org.tinytlf.layout.sector
{
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
		
		public function get size():Number
		{
			var s:Number = 0;
			forEach(function(sector:TextSector, ... args):void {
				if(progression == TextBlockProgression.LTR || progression == TextBlockProgression.RTL)
					s += (sector.width || sector.textWidth);
				else if(progression == TextBlockProgression.TTB || progression == TextBlockProgression.BTT)
					s += (sector.height || sector.textHeight);
			});
			return Math.ceil(s);
		}
	}
}

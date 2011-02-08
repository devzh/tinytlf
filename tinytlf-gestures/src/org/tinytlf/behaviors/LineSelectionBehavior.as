package org.tinytlf.behaviors
{
	import flash.geom.Point;
	import flash.text.engine.*;
	
	import org.tinytlf.util.TinytlfUtil;

	public class LineSelectionBehavior extends MouseSelectionBehavior
	{
		[Event("mouseDown")]
		override public function downAction():void
		{
			super.downAction();
			
			engine.select(anchor.x, anchor.y);
		}
		
		override protected function getAnchor():Point
		{
			var start:int = TinytlfUtil.atomIndexToGlobalIndex(engine, line, 0);
			var end:int = start + line.atomCount;
			
			return new Point(start, end);
		}
	}
}
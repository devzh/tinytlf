package org.tinytlf.behaviors
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextLineUtil;

	public class WordSelectionBehavior extends MouseSelectionBehavior
	{
		[Event("mouseDown")]
		override public function downAction():void
		{
			super.downAction();
			
			engine.caretIndex = anchor.y;
			engine.select(anchor.x, anchor.y);
		}
		
		override protected function getAnchor():Point
		{
			var m:MouseEvent = MouseEvent(finalEvent);
			var atomIndex:int = TextLineUtil.getAtomIndexAtPoint(line, new Point(m.stageX, m.stageY));
			var begin:int = TextLineUtil.getAtomWordBoundary(line, atomIndex);
			var end:int = TextLineUtil.getAtomWordBoundary(line, atomIndex, false);
			
			return new Point(TinytlfUtil.atomIndexToGlobalIndex(engine, line, begin),
							TinytlfUtil.atomIndexToGlobalIndex(engine, line, end));
		}
	}
}
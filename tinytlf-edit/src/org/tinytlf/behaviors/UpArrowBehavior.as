package org.tinytlf.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextLineUtil;

	public class UpArrowBehavior extends KeySelectionBehaviorBase
	{
		public function UpArrowBehavior()
		{
			super();
		}
		
		override protected function getAnchor():Point
		{
			var newCaret:int = caret;
			var atomIndex:int = TinytlfUtil.globalIndexToAtomIndex(engine, line, caret);
			var bounds:Rectangle = TinytlfUtil.globalIndexToAtomBounds(engine, caret);
			
			if(!bounds)
				return null;
			
			var l:TextLine = line;
			
			if(l.previousLine)
			{
				l = l.previousLine;
				var pt:Point = l.localToGlobal(new Point(bounds.x, 1));
				newCaret = TinytlfUtil.atomIndexToGlobalIndex(
					engine, l, 
					TextLineUtil.getAtomIndexAtPoint(l, pt)
				);
			}
			else
			{
				newCaret = TinytlfUtil.atomIndexToGlobalIndex(engine, l, -1);
			}
			
			return new Point(newCaret, 0);
		}
	}
}
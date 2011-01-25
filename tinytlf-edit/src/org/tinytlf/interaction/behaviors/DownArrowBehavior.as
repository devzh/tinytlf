package org.tinytlf.interaction.behaviors
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextLineUtil;

	public class DownArrowBehavior extends KeySelectionBehaviorBase
	{
		public function DownArrowBehavior()
		{
			super();
		}
		
		
		override protected function getAnchor():Point
		{
			var newCaret:int = caret;
			var atomIndex:int = TinytlfUtil.globalIndexToAtomIndex(engine, line, caret);
			var bounds:Rectangle = TinytlfUtil.globalIndexToAtomBounds(engine, caret);
			
			var l:TextLine = line;
			
			if(l.nextLine)
			{
				l = l.nextLine;
				var pt:Point = l.localToGlobal(new Point(bounds.x, 1));
				newCaret = TinytlfUtil.atomIndexToGlobalIndex(
					engine, l, 
					TextLineUtil.getAtomIndexAtPoint(l, pt)
				);
			}
			else
			{
				newCaret = TinytlfUtil.atomIndexToGlobalIndex(engine, l, l.atomCount);
			}
			
			return new Point(newCaret, 0);
		}
	}
}
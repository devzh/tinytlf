package org.tinytlf.interaction.behaviors.selection.mouse
{
	import flash.geom.Point;

	public class ParagraphSelectionBehavior extends MouseSelectionBehavior
	{
		[Event("mouseDown")]
		override public function downAction():void
		{
			super.downAction();
			
			engine.select(anchor.x, anchor.y);
		}
		
		override protected function getAnchor():Point
		{
			var begin:int = engine.getBlockPosition(line.textBlock);
			var end:int = begin + engine.getBlockSize(line.textBlock) - 1;
			return new Point(begin, end);
		}
	}
}
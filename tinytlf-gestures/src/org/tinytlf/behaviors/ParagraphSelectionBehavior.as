package org.tinytlf.behaviors
{
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.analytics.IVirtualizer;

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
			var textBlockVirtualizer:IVirtualizer = engine.layout.textBlockVirtualizer;
			var contentVirtualizer:IVirtualizer = engine.blockFactory.contentVirtualizer;
			var block:TextBlock = line.textBlock;
			var begin:int = contentVirtualizer.getItemStart(block);
			var end:int = begin + contentVirtualizer.getItemSize(block);
			return new Point(begin, end);
		}
	}
}
package org.tinytlf.behaviors
{
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.analytics.ITextEngineAnalytics;

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
			var a:ITextEngineAnalytics = engine.analytics;
			var block:TextBlock = line.textBlock;
			var begin:int = a.blockContentStart(block);
			var end:int = begin + a.blockContentSize(block);
			return new Point(begin, end);
		}
	}
}
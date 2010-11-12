package org.tinytlf.interaction.behaviors.selection.keyboard
{
	import flash.geom.Point;
	import flash.text.engine.TextBlock;

	public class SelectAllBehavior extends KeyboardSelectionBehavior
	{
		override protected function getAnchor():Point
		{
			return new Point(0, engine.analytics.contentLength);
		}
	}
}
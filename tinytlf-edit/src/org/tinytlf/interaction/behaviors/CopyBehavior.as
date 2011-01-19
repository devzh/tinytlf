package org.tinytlf.interaction.behaviors
{
	import flash.geom.Point;
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.analytics.ITextEngineAnalytics;
	import org.tinytlf.util.fte.ContentElementUtil;
	import org.tinytlf.util.fte.TextBlockUtil;

	public class CopyBehavior extends MultiGestureBehavior
	{
		public function CopyBehavior()
		{
			super();
		}
		
		[Event("copy")]
		public function copy():void
		{
			var selection:Point = engine.selection;
		}
	}
}
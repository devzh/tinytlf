package org.tinytlf.behaviors
{
	import org.tinytlf.analytics.IVirtualizer;

	public class SelectAllBehavior extends SelectionBehaviorBase
	{
		[Event("keyDown")]
		override public function downAction():void
		{
			var contentVirtualizer:IVirtualizer = engine.blockFactory.contentVirtualizer;
			engine.select(0, contentVirtualizer.size);
		}
	}
}
package org.tinytlf.behaviors
{
	public class SelectAllBehavior extends SelectionBehaviorBase
	{
		[Event("keyDown")]
		override public function downAction():void
		{
			engine.select(0, engine.analytics.contentLength);
		}
	}
}
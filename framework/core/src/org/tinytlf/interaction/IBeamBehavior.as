package org.tinytlf.interaction
{
	import flash.events.*;
	import flash.ui.*;
	
	import raix.reactive.IObservable;
	
	[Inject]
	public class IBeamBehavior
	{
		public function IBeamBehavior(obs:Observables)
		{
			const subscribeMove:Function = function():void {
				obs.move.take(1).
					subscribe(function(me:MouseEvent):void {
						Mouse.cursor = MouseCursor.IBEAM;
					});
			};
			subscribeMove();
			obs.rollOut.
				subscribe(function(me:MouseEvent):void {
					Mouse.cursor = MouseCursor.AUTO;
					subscribeMove();
				});
		}
	}
}

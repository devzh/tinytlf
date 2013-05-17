package org.tinytlf.events
{
	import raix.reactive.Cancelable;
	import raix.reactive.ICancelable;
	import raix.reactive.IObservable;
	import raix.reactive.IObserver;
	import raix.reactive.Observable;
	
	import starling.events.EventDispatcher;

	/**
	 * Creates a sequence of events from a Starling EventDispatcher. 
	 * @param eventDispatcher The EventDispatcher that dispatches the event
	 * @param eventType The valueClass of event dispatched by eventDispatcher. Event will be used if this argument is null.
	 * @param useCapture Whether to pass useCapture when subscribing to and unsubscribing from the event
	 * @param priority The priority of the event
	 * @param targetingOnly Whether to cancel the event at the targeting phase, or allow it to bubble back up the display list.
	 * This only applies if the event is actually processed in the "targeting" phase, so events handled during the bubbling phase
	 * won't be affected, even if the IObservable was created with <code>targetingOnly == true</code>
	 * @return An observable sequence of eventType, or Event if eventType is null
	 */
	public function fromStarlingEvent(eventDispatcher:EventDispatcher, eventType:String):IObservable
	{
		if (eventDispatcher == null) throw new ArgumentError("eventDispatcher cannot be null");
		
		return Observable.createWithCancelable(function(observer : IObserver) : ICancelable {
			eventDispatcher.addEventListener(eventType, observer.onNext);
			
			return Cancelable.create(function():void {
				eventDispatcher.removeEventListener(eventType, observer.onNext);
			});
		});
	}
}

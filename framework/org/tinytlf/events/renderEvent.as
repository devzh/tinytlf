package org.tinytlf.events
{
	import starling.events.Event;

	/**
	 * @author ptaylor
	 */
	public function renderEvent(rendered:Boolean):Event {
		return new Event(renderEventType, false, rendered);
	}
}
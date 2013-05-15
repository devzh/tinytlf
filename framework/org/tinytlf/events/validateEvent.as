package org.tinytlf.events
{
	import starling.events.Event;

	/**
	 * @author ptaylor
	 */
	public function validateEvent(rendered:Boolean):Event {
		return new Event(validateEventType, true, rendered);
	}
}
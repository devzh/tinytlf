package org.tinytlf.interaction
{
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	
	public class EventMirrorMap extends FactoryMap
	{
		public function EventMirrorMap(factory:* = null)
		{
			super(factory);
		}
		
		override public function instantiate(value:*):*
		{
			return super.instantiate((value is DOMNode) ? value.nodeName : value);
		}
	}
}

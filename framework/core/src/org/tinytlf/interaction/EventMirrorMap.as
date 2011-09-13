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
			if(value is DOMNode)
			{
				injector.mapValue(IDOMNode, value);
				injector.mapValue(DOMNode, value);
				const item:* = super.instantiate(IDOMNode(value).name);
				injector.unmap(IDOMNode);
				injector.unmap(DOMNode);
				
				return item;
			}
			
			return super.instantiate(value);
		}
	}
}

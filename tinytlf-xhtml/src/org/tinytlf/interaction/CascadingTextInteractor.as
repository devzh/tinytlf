package org.tinytlf.interaction
{
	import flash.events.EventDispatcher;
	
	import org.tinytlf.conversion.IHTMLNode;
	
	public class CascadingTextInteractor extends GestureInteractor
	{
		public function CascadingTextInteractor()
		{
			super();
		}
		
		override public function getMirror(element:* = null):EventDispatcher
		{
			if(element is XML)
			{
				var mirror:EventDispatcher;
				var node:IHTMLNode = element as IHTMLNode;
				while(node)
				{
					mirror = super.getMirror(node.name);
					
					if(mirror)
						return mirror;
					
					node = node.parent;
				}
				
				return null;
			}
			
			return super.getMirror(element);
		}
	}
}
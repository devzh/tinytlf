package org.tinytlf.interaction
{
	import flash.events.EventDispatcher;
	
	import org.tinytlf.model.ITLFNode;
	
	public class CascadingTextInteractor extends EditInteractor
	{
		public function CascadingTextInteractor()
		{
			super();
		}
		
		override public function getMirror(element:* = null):EventDispatcher
		{
			if(element is ITLFNode)
			{
				var mirror:EventDispatcher;
				var node:ITLFNode = element as ITLFNode;
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
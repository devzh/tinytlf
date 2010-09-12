package org.tinytlf.interaction.xhtml
{
	import flash.events.EventDispatcher;
	
	import org.tinytlf.interaction.GestureInteractor;
	import org.tinytlf.layout.model.factories.xhtml.XMLDescription;
	
	public class CascadingTextInteractor extends GestureInteractor
	{
		public function CascadingTextInteractor()
		{
			super();
		}
		
		override public function getMirror(element:* = null):EventDispatcher
		{
			if (element is Array)
			{
				var mirror:EventDispatcher;
				var copy:Vector.<XMLDescription> = Vector.<XMLDescription>(element);
				for(var i:int = copy.length - 1; i > -1; --i)
				{
					mirror = super.getMirror(copy[i].name);
					if(mirror)
						return mirror;
				}
				
				return null;
			}
			
			return super.getMirror(element);
		}
	}
}
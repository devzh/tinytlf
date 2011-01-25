package org.tinytlf.interaction
{
	import flash.events.EventDispatcher;
	
	import org.tinytlf.layout.factories.XMLModel;
	
	public class CascadingTextInteractor extends GestureInteractor
	{
		public function CascadingTextInteractor()
		{
			super();
		}
		
		override public function getMirror(element:* = null):EventDispatcher
		{
			if(element is Array)
			{
				var mirror:EventDispatcher;
				var copy:Vector.<XMLModel> = Vector.<XMLModel>(element);
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
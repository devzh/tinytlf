package org.tinytlf.interaction
{
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.tinytlf.layout.factories.XMLDescription;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.XMLUtil;
	
	public class AnchorInteractor extends CSSInteractor
	{
		override protected function onMouseUp(event:MouseEvent):void
		{
			var info:EventLineInfo = EventLineInfo.getInfo(event, this);
			if (!info)
				return;
			
			var tree:Vector.<XMLDescription> = (info.element.userData as Vector.<XMLDescription>);
			if (!tree || !tree.length)
				return;
			
			var link:Object = tree.concat().pop();
			var href:String = link.href;
			
			if (TinytlfUtil.isBitSet(mouseState, DOWN))
			{
				//If there's an href, launch the URL. Otherwise, dispatch an event from this TextLine.
				if (href && /event:/i.test(href) == false)
					navigateToURL(new URLRequest(href), link['target'] || '_blank');
				else
					info.line.dispatchEvent(new TextEvent(TextEvent.LINK, true, false, href.substr(6) || info.element.text));
			}
			
			super.onMouseUp(event);
		}
	}
}
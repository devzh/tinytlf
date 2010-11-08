package org.tinytlf.interaction
{
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.tinytlf.layout.factories.XMLModel;
	
	public class AnchorMirror extends CSSMirror
	{
		[Event("mouseUp")]
		override public function up():void
		{
			if(cssState != ACTIVE)
				return super.up();
			
			var props:Object = resolveCSSProperties(NORMAL);
			
			if(!props.hasOwnProperty('href'))
				return;
			
			var href:String = props.href;
			
			//If there's an href, launch the URL. Otherwise, dispatch an event from this TextLine.
			if(/event:/i.test(href))
			{
				line.dispatchEvent(new TextEvent(TextEvent.LINK, true, false,
					href.substr(href.indexOf('event:') + 6) || content.text));
			}
			else
			{
				navigateToURL(new URLRequest(href), props['target'] || '_blank');
			}
			
			super.up();
		}
	}
}
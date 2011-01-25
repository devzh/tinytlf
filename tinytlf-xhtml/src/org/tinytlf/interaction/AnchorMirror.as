package org.tinytlf.interaction
{
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	
	public class AnchorMirror extends CSSMirror
	{
		[Event("mouseUp")]
		override public function up():void
		{
			if(cssState != ACTIVE)
				return super.up();
			
			var request:URLRequest = getURLRequest();
			
			//If there's an href, launch the URL. 
			if(request)
			{
				var props:Object = resolveCSSProperties(NORMAL);
				navigateToURL(request, props['target'] || '_blank');
			}
			else
			{
				//Otherwise, try to dispatch an event from the line.
				var href:String = getLink();
				if(href.indexOf('event:') == 0)
				{
					line.dispatchEvent(new TextEvent(TextEvent.LINK, true, false, 
						href.substr(6) || content.text));
				}
			}
			
			super.up();
		}
		
		[Event("rollOver")]
		[Event("mouseOver")]
		override public function over(event:MouseEvent):void
		{
			super.over(event);
			
			applyLink();
		}
		
		[Event("rollOut")]
		[Event("mouseOut")]
		override public function out(event:MouseEvent):void
		{
			super.out(event);
			
			unapplyLink();
		}
		
		[Event("mouseMove")]
		override public function move():void
		{
			if(cssState == HOVER)
				applyLink();
			else if(cssState == VISITED || cssState == NORMAL)
				unapplyLink();
		}
		
		private function applyLink():void
		{
			var menu:ContextMenu = line.contextMenu;
			menu.link = getURLRequest();
		}
		
		private function unapplyLink():void
		{
			var menu:ContextMenu = line.contextMenu;
			menu.link = null;
			menu.clipboardMenu = true;
		}
		
		private function getURLRequest():URLRequest
		{
			var href:String = getLink();
			
			if(/event:/i.test(href) == false)
				return new URLRequest(href);
			
			return null;
		}
		
		private function getLink():String
		{
			var props:Object = resolveCSSProperties(NORMAL);
			
			if(!props.hasOwnProperty('href'))
				return '';
			
			return props.href;
		}
	}
}
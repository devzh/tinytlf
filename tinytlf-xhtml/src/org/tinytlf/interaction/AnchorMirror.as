package org.tinytlf.interaction
{
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	
	import org.tinytlf.conversion.IHTMLNode;
	
	public class AnchorMirror extends CSSMirror
	{
		[Event("mouseUp")]
		override public function up():void
		{
			if(cssState != ACTIVE)
				return super.up();
			
			var request:URLRequest = getURLRequest();
			var node:IHTMLNode = content.userData as IHTMLNode;
			
			//If there's an href, launch the URL. 
			if(request)
			{
				navigateToURL(request, node['target'] || '_blank');
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
			
			if(menu)
				menu.link = getURLRequest();
		}
		
		private function unapplyLink():void
		{
			var menu:ContextMenu = line.contextMenu;
			
			if(!menu) return;
			
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
			var node:IHTMLNode = content.userData as IHTMLNode;
			return node['href'];
		}
	}
}
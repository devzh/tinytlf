package org.tinytlf.html
{
	import flash.events.*;
	import flash.text.engine.*;
	import flash.utils.flash_proxy;
	
	import org.tinytlf.*;
	
	use namespace flash_proxy;
	
	public interface IDOMNode extends IStyleable
	{
		function getChildAt(index:int):IDOMNode;
		function get numChildren():int;
		function get parentNode():IDOMNode;
		
		function get content():ContentElement;
		function set content(ce:ContentElement):void;
		function get contentSize():int;
		
		function set mirror(eventMirror:*):void;
		
		function get cssInheritanceChain():String;
		function get nodeName():String;
		function get nodeValue():String;
	}
}
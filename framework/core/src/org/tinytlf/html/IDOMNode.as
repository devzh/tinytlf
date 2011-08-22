package org.tinytlf.html
{
	import flash.events.*;
	import flash.text.engine.*;

	public interface IDOMNode
	{
		function get children():Vector.<IDOMNode>;
		
		function get inheritance():String;
		
		function get name():String;
		
		function get parent():IDOMNode;
		
		function get text():String;
		
		function get content():ContentElement;
		function set content(ce:ContentElement):void;
		function get mirror():EventDispatcher;
	}
}
package org.tinytlf.html
{
	import flash.events.*;
	import flash.text.engine.*;
	
	import org.tinytlf.*;

	public interface IDOMNode extends IStyleable
	{
		function get children():Array;
		
		function get inheritance():String;
		
		function get name():String;
		
		function get parent():IDOMNode;
		
		function get text():String;
		
		function get content():ContentElement;
		function set content(ce:ContentElement):void;
		function set mirror(eventMirror:*):void;
	}
}
package org.tinytlf.conversion
{
	import org.tinytlf.styles.IStyleAware;

	public interface IHTMLNode extends IStyleAware
	{
		function get name():String;
		function get children():XMLList;
		function get text():String;
		function get inheritanceList():String;
		
		function get parent():IHTMLNode;
		function set parent(value:IHTMLNode):void;
	}
}
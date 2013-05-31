package org.tinytlf
{
	public interface TTLFBlockContainer extends TTLFBlock
	{
		function get children():Array;
		function set layout(value:TTLFLayout):void;
		function set start(value:*):void;
	}
}
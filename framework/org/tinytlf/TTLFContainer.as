package org.tinytlf
{
	public interface TTLFContainer extends TTLFBlock
	{
		function get children():Array;
		function set children(value:Array):void;
	}
}
package org.tinytlf
{
	public interface TTLFStyleProxy
	{
		function get borders():Edge;
		function get constraints():Edge;
		function get margins():Edge;
		function get padding():Edge;
		
		function getStyle(style:String):*;
		function setStyle(style:String, value:*):TTLFStyleProxy;
		function hasStyle(style:String):Boolean;
		
		function constrain(width:Number, height:Number):Edge;
		function displayed(...values):Boolean;
		function floated(...values):Boolean;
		function positioned(...values):Boolean;
		function overflowed(...values):Boolean;
	}
}
package org.tinytlf
{
	import flash.geom.Rectangle;

	public interface TTLFBlock
	{
		function get index():int;
		
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get bounds():Rectangle;
		
		function getStyle(style:String):*;
		function setStyle(style:String, value:*):TTLFBlock;
		function hasStyle(style:String):Boolean;
		
		function update(value:XML, viewport:Rectangle):Boolean;
	}
}
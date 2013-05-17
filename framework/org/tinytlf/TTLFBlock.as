package org.tinytlf
{
	import flash.geom.Rectangle;

	public interface TTLFBlock
	{
		function get bounds():Rectangle;
		function set content(value:*):void;
		function get index():int;
		
		function move(x:Number, y:Number):void;
		function size(width:Number, height:Number):void;
		function scroll(x:Number, y:Number):void;
		
		function isInvalid(flag:String = null):Boolean;
		
		function getStyle(style:String):*;
		function setStyle(style:String, value:*):TTLFBlock;
		function hasStyle(style:String):Boolean;
	}
}
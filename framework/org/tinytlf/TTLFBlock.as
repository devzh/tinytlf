package org.tinytlf
{
	import flash.geom.Rectangle;
	
	import raix.reactive.IObservable;

	public interface TTLFBlock extends TTLFStyleProxy
	{
		function get bounds():Rectangle;
		
		function get x():Number;
		function get y():Number;
		function get width():Number;
		function get height():Number;
		
		function get index():int;
		
		function set content(value:*):void;
		
		function move(x:Number, y:Number):TTLFBlock;
		function size(width:Number, height:Number):TTLFBlock;
		function refresh():IObservable;
	}
}
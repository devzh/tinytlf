package org.tinytlf
{
	import feathers.core.IFeathersControl;
	
	import flash.geom.Rectangle;

	public interface TTLFBlock extends IFeathersControl
	{
		function set content(value:*):void;
		
		function get index():int;
		
		function set viewport(value:Rectangle):void;
		
		function isInvalid(flag:String = null):Boolean;
		
		function getStyle(style:String):*;
		function setStyle(style:String, value:*):TTLFBlock;
		function hasStyle(style:String):Boolean;
	}
}
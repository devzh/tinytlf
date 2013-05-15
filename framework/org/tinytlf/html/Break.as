package org.tinytlf.html
{
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.events.validateEvent;
	
	public class Break extends FeathersControl implements TTLFBlock
	{
		public function Break()
		{
			super();
		}
		
		public function set content(value:*):void
		{
		}
		
		public function get index():int
		{
			return 0;
		}
		
		public function set viewport(value:Rectangle):void
		{
			setSizeInternal(value.width, 1, false);
		}
		
		public function getStyle(style:String):*
		{
			return null;
		}
		
		public function setStyle(style:String, value:*):TTLFBlock
		{
			return null;
		}
		
		public function hasStyle(style:String):Boolean
		{
			return false;
		}
		
		override public function isInvalid(flag:String=null):Boolean {
			return false;
		}
	}
}
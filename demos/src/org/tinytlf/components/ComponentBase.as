package org.tinytlf.components
{
	import flash.display.Sprite;
	
	[Exclude(name="$width", kind="property")]
	[Exclude(name="$height", kind="property")]
	
	public class ComponentBase extends Sprite
	{
		public function ComponentBase()
		{
			super();
		}
		
		private var _width:Number = 0;
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function get $width():Number
		{
			return super.width;
		}
		
		public function set $width(value:Number):void
		{
			super.width = value;
		}
		
		private var _height:Number = 0;
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function get $height():Number
		{
			return super.height;
		}
		
		public function set $height(value:Number):void
		{
			super.height = value;
		}
	}
}
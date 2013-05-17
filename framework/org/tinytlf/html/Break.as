package org.tinytlf.html
{
	import feathers.core.FeathersControl;
	
	import org.tinytlf.TTLFBlock;
	
	public class Break extends FeathersControl implements TTLFBlock
	{
		public function Break()
		{
			super();
		}
		
		private var node:XML;
		public function set content(value:*):void
		{
			if(value is XML) {
				node = value;
				_index = node.childIndex();
			}
		}
		
		private var _index:int = 0;
		public function get index():int
		{
			return _index;
		}
		
		public function move(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function size(width:Number, height:Number):void
		{
			setSizeInternal(width, height, false);
		}
		
		public function scroll(x:Number, y:Number):void {}
		
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
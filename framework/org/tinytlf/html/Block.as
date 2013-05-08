package org.tinytlf.html
{
	import asx.array.forEach;
	import asx.array.map;
	import asx.array.range;
	
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.fn.mergeAttributes;
	
	import starling.display.Sprite;
	
	import trxcllnt.Store;
	
	internal class Block extends Sprite implements TTLFBlock
	{
		public function Block(value:XML)
		{
			super();
			
			node = value;
			_index = value.childIndex();
		}
		
		private var node:XML = <_/>;
		
		protected var newChildrenInView:Boolean = true;
		public function get children():Array {
			return map(range(0, numChildren), getChildAt);
		}
		
		public function set children(value:Array):void {
			removeChildren();
			forEach(value, addChild);
		}
		
		protected var _index:int = 0;
		public function get index():int {
			return _index;
		}
		
		public function update(value:XML, viewport:Rectangle):TTLFBlock {
			node = value;
			_index = value.childIndex();
			mergeAttributes(styles, value);
			return this;
		}
		
		protected const styles:Store = new Store();
		
		public function hasStyle(style:String):Boolean {
			return styles.hasOwnProperty(style);
		}
		
		public function getStyle(style:String):* {
			return styles[style];
		}
		
		public function setStyle(style:String, value:*):TTLFBlock {
			styles[style] = value;
			return this;
		}
		
		protected function areNewChildrenInView(oldViewport:Rectangle, newViewport:Rectangle):Boolean {
			return true;
		}
	}
}
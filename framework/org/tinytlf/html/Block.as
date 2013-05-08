package org.tinytlf.html
{
	import asx.array.forEach;
	import asx.array.map;
	import asx.array.range;
	import asx.fn.I;
	import asx.fn.ifElse;
	import asx.fn.not;
	import asx.fn.sequence;
	import asx.fn.setProperty;
	
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	
	import starling.display.Sprite;
	
	import trxcllnt.Store;
	
	internal class Block extends Sprite implements TTLFBlock
	{
		public function Block(node:XML)
		{
			super();
			
			_index = node.childIndex();
		}
		
		protected var newChildrenInView:Boolean = true;
		public function get children():Array {
			return map(range(0, numChildren), getChildAt);
		}
		
		public function set children(value:Array):void {
			removeChildren();
			forEach(value, addChild);
		}
		
		private var _index:int = 0;
		public function get index():int {
			return _index;
		}
		
		public function update(value:XML, viewport:Rectangle):TTLFBlock {
			_index = value.childIndex();
			return this;
		}
		
		private const styles:Store = new Store();
		
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
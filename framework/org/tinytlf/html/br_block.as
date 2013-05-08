package org.tinytlf.html
{
	import org.tinytlf.TTLFBlock;


	/**
	 * @author ptaylor
	 */
	public function br_block(value:XML):TTLFBlock {
		return new Break(value);
	}
}
import flash.geom.Rectangle;

import org.tinytlf.TTLFBlock;

import starling.display.DisplayObject;

internal class Break extends DisplayObject implements TTLFBlock {
	
	public function Break(node:XML) {
		_index = node.childIndex();
	}
	
	private const rect:Rectangle = new Rectangle();
	public function get viewport():Rectangle {
		return rect;
	}
	
	public function set viewport(value:Rectangle):void {}
	
	private var _index:int = 0;
	
	public function get index():int {
		return _index;
	}
	
	public function set index(value:int):void {
		_index = value;
	}
	
	public function update(node:XML, constraint:Rectangle):TTLFBlock {
		_index = node.childIndex();
		return this;
	}
	
	public function getStyle(style:String):* {
		return null;
	}
	
	public function setStyle(style:String, value:*):TTLFBlock {
		return this;
	}
}
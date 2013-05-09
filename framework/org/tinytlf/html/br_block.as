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

import starling.display.Sprite;

internal class Break extends Sprite implements TTLFBlock {
	
	public function Break(node:XML) {
		_index = node.childIndex();
	}
	
	private var _index:int = 0;
	
	public function get index():int {
		return _index;
	}
	
	public function set index(value:int):void {
		_index = value;
	}
	
	private const rect:Rectangle = new Rectangle(0, 0, 1, 1);
	override public function get bounds():Rectangle {
		return rect;
	}
	
	public function update(node:XML, viewport:Rectangle):Boolean {
		_index = node.childIndex();
		rect.width = viewport.width;
		return true;
	}
	
	public function hasStyle(style:String):Boolean {
		return false;
	}
	
	public function getStyle(style:String):* {
		return null;
	}
	
	public function setStyle(style:String, value:*):TTLFBlock {
		return this;
	}
}
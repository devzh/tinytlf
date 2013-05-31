package org.tinytlf.block
{
	import asx.array.anyOf;
	import asx.array.forEach;
	import asx.array.map;
	import asx.array.range;
	import asx.fn.areEqual;
	import asx.fn.getProperty;
	import asx.fn.partial;
	import asx.object.merge;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tinytlf.CSS;
	import org.tinytlf.Edge;
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.TTLFStyleProxy;
	import org.tinytlf.events.fromStarlingEvent;
	import org.tinytlf.events.renderEvent;
	import org.tinytlf.events.renderEventType;
	import org.tinytlf.xml.mergeAttributes;
	import org.tinytlf.xml.readKey;
	import org.tinytlf.xml.wrapTextNodes;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;
	
	import trxcllnt.Store;
	
	public class Block extends FeathersControl implements TTLFBlock
	{
		protected static const emptyPoint:Point = new Point();
		protected static const emptyRect:Rectangle = new Rectangle();
		
		public function Block()
		{
			super();
		}
		
		protected const styles:Store = new Store();
		
		public function hasStyle(style:String):Boolean {
			return styles.hasOwnProperty(style);
		}
		
		public function getStyle(style:String):* {
			return styles[style];
		}
		
		public function setStyle(style:String, value:*):TTLFStyleProxy {
			styles[style] = value;
			return this;
		}
		
		[Inject]
		public var css:CSS;
		
		protected var window:TTLFBlock;
		private var node:XML = <_/>;
		
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
		
		private var _content:* = null;
		
		public function get content():* {
			return _content;
		}
		
		public function set content(value:*):void {
			if(_content == value) return;
			
			_content = value;
			invalidate('content');
			
			if(value is XML) {
				const node:XML = wrapTextNodes(value);
				
				_index = node.childIndex();
				
				// Merge the styles from the global CSS rules.
				merge(styles, css.lookup(readKey(node)));
				
				// Merge the attributes on the XML node.
				mergeAttributes(styles, node);
				
				// Merge the inline styles on the XML node.
				if(hasStyle('style')) {
					const inline:CSS = new CSS('inline-node-styles {' + getStyle('style') + '}');
					merge(styles, inline.lookup('inline-node-styles'));
				}
			}
			
			if(hasStyle('width')) actualWidth = Math.max(getStyle('width'), 0);
			if(hasStyle('height')) actualHeight = Math.max(getStyle('height'), 0);
		}
		
		public function move(x:Number, y:Number):TTLFBlock {
			this.x = x;
			this.y = y;
			return this;
		}
		
		public function size(width:Number, height:Number):TTLFBlock {
			setSizeInternal(width, height, false);
			return this;
		}
		
		public function refresh():IObservable {
			return isInvalid() == false ?
				Observable.value(true) :
				fromStarlingEvent(this, renderEventType).map(getProperty('data'));
		}
		
		override protected function draw():void {
			dispatchEvent(renderEvent(true));
		}
		
		public function get innerBounds():Rectangle {
			
			const area:Rectangle = bounds;
			
			area.x = paddingLeft;
			area.y = paddingTop;
			area.width -= (paddingLeft + paddingRight);
			area.bottom -= (paddingTop + paddingBottom);
			
			return area;
		}
		
		////
		// Style convenience methods.
		////
		
		public function get top():Number {
			return getStyle('top') || 0;
		}
		
		public function get right():Number {
			return getStyle('right') || 0;
		}
		
		public function get bottom():Number {
			return getStyle('bottom') || 0;
		}
		
		public function get left():Number {
			return getStyle('left') || 0;
		}
		
		public function get borderTop():Number {
			return getStyle('borderTop') || getStyle('border') || 0;
		}
		
		public function get borderRight():Number {
			return getStyle('borderRight') || getStyle('border') || 0;
		}
		
		public function get borderBottom():Number {
			return getStyle('borderBottom') || getStyle('border') || 0;
		}
		
		public function get borderLeft():Number {
			return getStyle('borderLeft') || getStyle('border') || 0;
		}
		
		public function get marginTop():Number {
			return getStyle('marginTop') || getStyle('margin') || 0;
		}
		
		public function get marginRight():Number {
			return getStyle('marginRight') || getStyle('margin') || 0;
		}
		
		public function get marginBottom():Number {
			return getStyle('marginBottom') || getStyle('margin') || 0;
		}
		
		public function get marginLeft():Number {
			return getStyle('marginLeft') || getStyle('margin') || 0;
		}
		
		public function get paddingTop():Number {
			return getStyle('paddingTop') || getStyle('padding') || 0;
		}
		
		public function get paddingRight():Number {
			return getStyle('paddingRight') || getStyle('padding') || 0;
		}
		
		public function get paddingBottom():Number {
			return getStyle('paddingBottom') || getStyle('padding') || 0;
		}
		
		public function get paddingLeft():Number {
			return getStyle('paddingLeft') || getStyle('padding') || 0;
		}
		
		public function get requiredWidth():Number {
			return getStyle('width');
		}
		
		public function get requiredHeight():Number {
			return getStyle('height');
		}
		
		public function get minWidth():Number {
			return getStyle('minWidth') || 0;
		}
		
		public function get maxWidth():Number {
			return getStyle('maxWidth') || int.MAX_VALUE;
		}
		
		public function get minHeight():Number {
			return getStyle('minHeight') || 0;
		}
		
		public function get maxHeight():Number {
			return getStyle('maxHeight') || int.MAX_VALUE;
		}
		
		public function get display():String {
			return getStyle('display') || 'block';
		}
		
		public function get float():String {
			return getStyle('float') || 'none';
		}
		
		public function get position():String {
			return getStyle('position') || 'static';
		}
		
		public function get overflow():String {
			return getStyle('overflow') || 'visible';
		}
		
		private const constrainHelper:Edge = new Edge();
		public function constrain(width:Number, height:Number):Edge {
			return constrainHelper.setTo(0, 0, 
				Math.max(Math.min(requiredWidth || width, maxWidth), minWidth), 
				Math.max(Math.min(requiredHeight || height, maxHeight), minHeight)
			);
		}
		
		public function displayed(...values):Boolean {
			return anyOf(values, partial(areEqual, float));
		}
		
		public function floated(...values):Boolean {
			return anyOf(values, partial(areEqual, float));
		}
		
		public function positioned(...values):Boolean {
			return anyOf(values, partial(areEqual, position));
		}
		
		public function overflowed(...values):Boolean {
			return anyOf(values, partial(areEqual, overflow));
		}
		
		private const borderHelper:Edge = new Edge();
		public function get borders():Edge {
			return borderHelper.setTo(borderTop, borderRight, borderBottom, borderLeft);
		}
		
		private const constraintHelper:Edge = new Edge();
		public function get constraints():Edge {
			return constraintHelper.setTo(top, right, bottom, left);
		}
		
		private const marginHelper:Edge = new Edge();
		public function get margins():Edge {
			return marginHelper.setTo(marginTop, marginRight, marginBottom, marginLeft);
		}
		
		private const paddingHelper:Edge = new Edge();
		public function get padding():Edge {
			return paddingHelper.setTo(paddingTop, paddingRight, paddingBottom, paddingLeft);
		}
	}
}



package org.tinytlf.html
{
	import asx.array.forEach;
	import asx.array.map;
	import asx.array.range;
	import asx.object.merge;
	
	import feathers.core.FeathersControl;
	
	import flash.geom.Rectangle;
	
	import org.tinytlf.CSS;
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.events.validateEvent;
	import org.tinytlf.xml.mergeAttributes;
	import org.tinytlf.xml.readKey;
	import org.tinytlf.xml.wrapTextNodes;
	
	import trxcllnt.Store;
	
	public class Block extends FeathersControl implements TTLFBlock
	{
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
		
		public function setStyle(style:String, value:*):TTLFBlock {
			styles[style] = value;
			return this;
		}
		
		[Inject]
		public var css:CSS;
		
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
		}
		
		private var _viewport:Rectangle = emptyRect;
		
		public function get viewport():Rectangle {
			return _viewport;
		}
		
		public function set viewport(value:Rectangle):void {
			if(viewport.equals(value)) return;
			
			_viewport = value.clone();
		}
		
		override public function setSize(width:Number, height:Number):void {
			setSizeInternal(width, height, false);
		}
		
		override protected function draw():void {
			super.draw();
			
			dispatchEvent(validateEvent(true));
		}
	}
}
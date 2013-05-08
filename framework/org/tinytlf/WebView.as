package org.tinytlf
{
	import asx.array.forEach;
	import asx.events.once;
	import asx.fn.aritize;
	import asx.fn.memoize;
	import asx.fn.partial;
	import asx.fn.sequence;
	import asx.fn.setProperty;
	import asx.object.newInstance_;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	
	import org.tinytlf.fn.readKey;
	import org.tinytlf.fn.toName;
	import org.tinytlf.fn.toXML;
	import org.tinytlf.html.Container;
	import org.tinytlf.html.Paragraph;
	import org.tinytlf.html.TableCell;
	import org.tinytlf.html.br_block;
	import org.tinytlf.html.br_inline;
	import org.tinytlf.html.span;
	import org.tinytlf.html.text;
	
	import spark.core.IViewport;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class WebView extends UIComponent implements IViewport
	{
		public function WebView()
		{
			super();
			
			const containerUIFactory:Function = memoize(sequence(
				partial(newInstance_, Container),
				setProperty('createChild', invokeBlockParser)
			), readKey);
			
			const tableCellUIFactory:Function = memoize(sequence(
				partial(newInstance_, TableCell),
				setProperty('createChild', invokeBlockParser)
			), readKey);
			
			const paragraphUIFactory:Function = memoize(sequence(
				partial(newInstance_, Paragraph),
				setProperty('createElement', invokeInlineParser)
			), readKey);
			
			const brBlockUIFactory:Function = memoize(br_block, readKey);
			
			const factoryFactory:Function = function(factory:Function):Function {
				return function(node:XML):TTLFBlock {
					return TTLFBlock(factory(node));
				};
			};
			
			const containerFactory:Function = factoryFactory(containerUIFactory);
			const tableCellFactory:Function = factoryFactory(tableCellUIFactory);
			const paragraphFactory:Function = factoryFactory(paragraphUIFactory);
			const brBlockFactory:Function = factoryFactory(brBlockUIFactory);
			const spanFactory:Function = partial(span, invokeInlineParser);
			
			addBlockParser(containerFactory, 'html', 'body', 'article', 'div',
				'footer', 'header', 'section', 'table', 'tbody', 'tr').
			addBlockParser(tableCellFactory, 'td').
			
			addBlockParser(paragraphFactory, 'p', 'span', 'text').
			
			addInlineParser(spanFactory, 'span').
			addInlineParser(text, 'text').
			
			// TODO: write a head and style parser
			addBlockParser(brBlockFactory, 'head', 'style', 'colgroup', 'object').
			
			addBlockParser(brBlockFactory, 'br').
			addInlineParser(br_inline, 'br');
		}
		
//		private const _css:CSS = new CSS();
//		
//		public function get css():* {
//			return _css;
//		}
//		
//		public function set css(value:*):void {
//			_css.inject(value);
//		}
		
		private var _html:XML = <html/>;
		private var htmlChanged:Boolean = false;
		
		public function get html():XML {
			return _html;
		}
		
		public function set html(value:*):void {
			_html = toXML(value);
			htmlChanged = true;
			invalidateDisplayList();
		}
		
		private var context:Starling;
		private var window:Container;
		
		private function createContext(...args):void {
			const global:Point = localToGlobal(new Point());
			context = new Starling(Sprite, stage, new Rectangle(global.x, global.y, width, height));
			context.supportHighResolutions = true;
			context.addEventListener(starling.events.Event.ROOT_CREATED, aritize(invalidateDisplayList, 0));
			context.start();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			if(stage) createContext();
			else once(this, flash.events.Event.ADDED_TO_STAGE, createContext);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			
			super.updateDisplayList(w, h);
			
			if(context == null) return;
			
			const global:Point = localToGlobal(new Point());
			const stage3DViewport:Rectangle = context.viewPort;
			
			if( stage3DViewport.x != global.x || stage3DViewport.y != global.y) {
				context.viewPort = new Rectangle(global.x, global.y, w, h);
			}
			
			const root:Sprite = context.root as Sprite;
			
			if(root == null) return;
			
			if(window == null) {
				root.addChild(window = new Container(html));
				window.createChild = invokeBlockParser;
				viewportChanged = true;
				htmlChanged = true;
			}
			
			if(htmlChanged || viewportChanged || w != window.width) {
				window.x = -hsp;
				window.y = -vsp;
				
				window.clipRect = null;
				
				window.update(html, new Rectangle(hsp, vsp, w, h + 100));
				
				const clip:Rectangle = new Rectangle(hsp, vsp, window.width, window.height);
				
				if(cWidth != clip.width)
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'contentWidth', cWidth, cWidth = clip.width));
				
				if(cHeight != clip.height)
					dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'contentHeight', cHeight, cHeight = clip.height));
				
				window.clipRect = clip;
			}
			
			viewportChanged = false;
			htmlChanged = false;
		}
		
		private var cWidth:Number = 0;
		public function get contentWidth():Number {
			return cWidth;
		}
		
		private var cHeight:Number = 0;
		public function get contentHeight():Number {
			return cHeight;
		}
		
		private var viewportChanged:Boolean = false;
		
		private var hsp:Number = 0;
		public function get horizontalScrollPosition():Number {
			return hsp;
		}
		
		public function set horizontalScrollPosition(value:Number):void {
			if(value == hsp) return;
//			if(value >= cWidth - width) return;
			
			hsp = value;
			viewportChanged = true;
			invalidateDisplayList();
		}
		
		private var vsp:Number = 0;
		public function get verticalScrollPosition():Number {
			return vsp;
		}
		
		public function set verticalScrollPosition(value:Number):void {
			if(value == vsp) return;
//			if(value >= cHeight - height) return;
			
			vsp = value;
			viewportChanged = true;
			invalidateDisplayList();
		}
		
		public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number {
			return 10;
		}
		
		public function getVerticalScrollPositionDelta(navigationUnit:uint):Number {
			return 10;
		}
		
		public function get clipAndEnableScrolling():Boolean {
			return true;
		}
		
		public function set clipAndEnableScrolling(value:Boolean):void {}
		
		private const blockParsers:Object = {};
		private const inlineParsers:Object = {};
		private const uiParsers:Object = {};
		
		public function addBlockParser(value:Function, ...names):WebView {
			return addValue.apply(null, [blockParsers, value].concat(names));
		}
		
		public function addInlineParser(value:Function, ...names):WebView {
			return addValue.apply(null, [inlineParsers, value].concat(names));
		}
		
		public function addUIParser(value:Function, ...names):WebView {
			return addValue.apply(null, [uiParsers, value].concat(names));
		}
		
		public function invokeBlockParser(node:XML):TTLFBlock {
			return getBlockParser(readKey(node))(node);
		}
		
		public function invokeInlineParser(node:XML):ContentElement {
			return getInlineParser(readKey(node))(node);
		}
		
		public function invokeUIParser(node:XML):TTLFBlock {
			return getUIParser(readKey(node))(node);
		}
		
		public function getBlockParser(key:String):Function {
			return getValue(blockParsers, key) || getValue(blockParsers, 'div');
		}
		
		public function getInlineParser(key:String):Function {
			return getValue(inlineParsers, key) || getValue(inlineParsers, 'span');
		}
		
		public function getUIParser(key:String):Function {
			return getValue(uiParsers, key);
		}
		
		private function addValue(dictionary:Object, value:*, ...names):WebView {
			forEach(names, function(name:String):void { dictionary[name] = value; });
			return this;
		}
		
		private function getValue(dictionary:Object, key:String):Function {
			const name:String = toName(key);
			return dictionary.hasOwnProperty(name) ? dictionary[name] : null;
		}
	}
}

package org.tinytlf
{
	import asx.array.forEach;
	import asx.events.once;
	import asx.fn.K;
	import asx.fn.aritize;
	import asx.fn.memoize;
	import asx.fn.partial;
	import asx.fn.sequence;
	import asx.fn.setProperty;
	import asx.object.newInstance;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	
	import org.tinytlf.events.renderEventType;
	import org.tinytlf.html.Break;
	import org.tinytlf.html.Container;
	import org.tinytlf.html.PerfParagraph;
	import org.tinytlf.html.TableCell;
	import org.tinytlf.html.TableRow;
	import org.tinytlf.html.br_inline;
	import org.tinytlf.html.span;
	import org.tinytlf.html.style;
	import org.tinytlf.html.text;
	import org.tinytlf.xml.readKey;
	import org.tinytlf.xml.toName;
	import org.tinytlf.xml.toXML;
	
	import spark.core.IViewport;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class WebView extends UIComponent implements IViewport
	{
		public function WebView()
		{
			super();
			
			const classFactory:Function = function(type:Class):Function {
				return aritize(partial(newInstance, type), 0)
			};
			
			const factoryFactory:Function = function(factory:Function):Function {
				return function(node:XML):TTLFBlock {
					return TTLFBlock(factory(node));
				};
			};
			
			const containerUIFactory:Function = memoize(sequence(
				classFactory(Container),
				setProperty('css', _css),
				setProperty('createChild', invokeBlockParser)
			), readKey);
			
			const tableCellUIFactory:Function = memoize(sequence(
				classFactory(TableCell),
				setProperty('css', _css),
				setProperty('createChild', invokeBlockParser)
			), readKey);
			
			const tableRowUIFactory:Function = memoize(sequence(
				classFactory(TableRow),
				setProperty('css', _css),
				setProperty('createChild', invokeBlockParser)
			), readKey);
			
			const paragraphUIFactory:Function = memoize(sequence(
				// classFactory(Paragraph),
				classFactory(PerfParagraph),
				setProperty('css', _css),
				setProperty('createElement', invokeInlineParser)
			), readKey);
			
			const brBlockUIFactory:Function = memoize(classFactory(Break), readKey);
			
			const containerFactory:Function = factoryFactory(containerUIFactory);
			const tableCellFactory:Function = factoryFactory(tableCellUIFactory);
			const tableRowFactory:Function = factoryFactory(tableRowUIFactory);
			const paragraphFactory:Function = factoryFactory(paragraphUIFactory);
			const brBlockFactory:Function = factoryFactory(brBlockUIFactory);
			const styleFactory:Function = partial(style, _css);
			const spanFactory:Function = partial(span, _css, invokeInlineParser);
			const textFactory:Function = partial(text, _css);
			
			addBlockParser(containerFactory, 'html', 'body', 'article', 'div',
				'footer', 'header', 'section', 'table', 'tbody').
			
			addBlockParser(tableRowFactory, 'tr').
			addBlockParser(tableCellFactory, 'td').
			
			addBlockParser(styleFactory, 'style').
			
			addBlockParser(paragraphFactory, 'p', 'span', 'text').
			
			addInlineParser(spanFactory, 'span').
			addInlineParser(textFactory, 'text').
			
			// TODO: write head and style parsers
			addBlockParser(K(null), 'head', 'colgroup', 'img', 'object').
//			addBlockParser(brBlockFactory, 'head', 'colgroup', 'object').
			
			addBlockParser(brBlockFactory, 'br').
			addInlineParser(br_inline, 'br');
		}
		
		private const _css:CSS = new CSS();
		
		public function get css():* {
			return _css;
		}
		
		public function set css(value:*):void {
			_css.inject(value);
			tryRenderBuffer = true;
		}
		
		private var _html:XML = <html/>;
		private var htmlChanged:Boolean = false;
		
		public function get html():XML {
			return _html;
		}
		
		public function set html(value:*):void {
			_html = toXML(value);
			htmlChanged = true;
			tryRenderBuffer = true;
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
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			
			super.updateDisplayList(w, h);
			
			if(context == null) {
				if(w == 0 || h == 0) return;
				
				if(stage) createContext();
				else {
					once(this, flash.events.Event.ADDED_TO_STAGE, createContext);
					return;
				}
			}
			
			const global:Point = localToGlobal(new Point());
			const stage3DViewport:Rectangle = context.viewPort;
			
			if(stage3DViewport.x != global.x || stage3DViewport.y != global.y) {
				context.viewPort = new Rectangle(global.x, global.y, w, h);
			}
			
			const root:Sprite = context.root as Sprite;
			
			if(root == null) return;
			
			if(window == null) {
				root.addChild(window = new Container());
				window.css = _css;
				window.createChild = invokeBlockParser;
				viewportChanged = true;
				htmlChanged = true;
			}
			
			if(w != cWidth) {
				tryRenderBuffer = true;
				viewportChanged = true;
			}
			
			// Shouldn't try to make the viewport render more content, just
			// update the scrolling-related properties.
			if(viewportChanged) {
				window.move(-hsp, -vsp);
				window.clipRect = new Rectangle(hsp, vsp, w, h);
			}
			
			if(htmlChanged || (viewportChanged && tryRenderBuffer && !isRendering)) {
				
				// Temp
				cWidth = w;
				
				isRendering = true;
				tryRenderBuffer = false;
				
				if(htmlChanged) window.content = html;
				
				window.clipRect = null;
				window.size(w, h + buffer);
				window.scroll(hsp, vsp);
				
				const listener:Function = function(...args):void {
					
					window.removeEventListener(renderEventType, listener);
					
					const clip:Rectangle = new Rectangle(hsp, vsp, window.width, window.height);
					
					// Temporarily disable this, I think there's a bug in the HRTree
					// that's preventing it from updating the MBR for the window.
					// 
					// if(cWidth != clip.width)
					//	dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'contentWidth', cWidth, cWidth = clip.width));
					
					if(cHeight != window.height) {
						dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'contentHeight', cHeight, cHeight = window.height));
					}
					
					window.clipRect = clip;
					
					isRendering = false;
				};
				
				window.addEventListener(renderEventType, listener);
			}
			
			viewportChanged = false;
			htmlChanged = false;
		}
		
		private var tryRenderBuffer:Boolean = true;
		private var isRendering:Boolean = false;
		private var buffer:Number = 500;
		public function get renderBuffer():Number {
			return buffer;
		}
		
		public function set renderBuffer(value:Number):void {
			if(value == buffer) return;
			
			buffer = value;
			invalidateDisplayList();
			viewportChanged = true;
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
			tryRenderBuffer = (hsp + width >= cWidth);
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
			
			tryRenderBuffer = (vsp + height >= cHeight);
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

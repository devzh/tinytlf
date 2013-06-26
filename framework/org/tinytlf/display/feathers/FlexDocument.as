package org.tinytlf.display.feathers
{
	import asx.events.once;
	import asx.fn.I;
	import asx.fn.apply;
	import asx.fn.callProperty;
	import asx.fn.getProperty;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	
	import spark.core.IViewport;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	
	[Event(name='documentCreated', type='flash.events.Event')]
	[Event(name='documentRendered', type='flash.events.Event')]
	
	public class FlexDocument extends UIComponent implements IViewport
	{
		public function FlexDocument()
		{
			super();
		}
		
		include '../documentMixin.as';
		
		public const window:Sprite = new Sprite();
		public var context:Starling;
		
		private function createContext(...args):void {
			const global:Point = localToGlobal(new Point());
			context = new Starling(Sprite, stage, new Rectangle(global.x, global.y, width, height));
			context.supportHighResolutions = true;
			context.addEventListener(starling.events.Event.ROOT_CREATED, rootCreated);
			context.start();
		}
		
		private function rootCreated():void {
			
			window.name = 'window';
			DisplayObjectContainer(context.root).addChild(window);
			
			mapFeathersUIs(window, mapUI);
			
			invalidateDisplayList();
		}
		
		private var _contentWidth:Number = 0;
		public function get contentWidth():Number {
			return _contentWidth;
		}
		
		private var _contentHeight:Number = 0;
		public function get contentHeight():Number {
			return _contentHeight;
		}
		
		private var viewportChanged:Boolean = true;
		
		private var hsp:Number = 0;
		public function get horizontalScrollPosition():Number {
			return hsp;
		}
		
		public function set horizontalScrollPosition(value:Number):void {
			if(value == hsp) return;
			
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
		
		protected function renderHTML(html:XML, css:String = ''):void {
			
			disengage();
			
			const g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, 0);
			g.drawRect(0, 0, unscaledWidth - 1, unscaledHeight);
			g.endFill();
			
			// asynchronous = false;
			
			const renderObservable:IObservable = engage(html);
			
			renderSubscription.cancel();
			renderSubscription = renderObservable.
				groupBy(getProperty('name')).
				mapMany(callProperty('scan', function(prev:DisplayObject, next:DisplayObject):DisplayObject {
					if(prev == window) return next;
					
					if(prev == next) return next;
					
					const parent:DisplayObjectContainer = prev.parent;
					if(parent && parent.contains(prev))
						parent.removeChild(prev);
					
					return next;
				})).
				subscribe(
					I,
					function():void { trace('render subscription completed.'); },
					function(e:Error):void { trace('render subscription error\n', e.getStackTrace()); }
				);
			
			injectCSS(documentElement, css);
			
			const start:Point = new Point(horizontalScrollPosition, verticalScrollPosition);
			
			const formatUpdates:IObservable = format(start, unscaledWidth, int.MAX_VALUE);
			
			const t:Number = getTimer();
			
			formatSubscription.cancel();
			formatSubscription = formatUpdates.subscribe(apply(function(element:Element, finished:Boolean):void {
					
					if(_contentWidth != element.width) {
						const contentWidthEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(
							this,
							'contentWidth', _contentWidth,
							_contentWidth = element.width
						);
						
						dispatchEvent(contentWidthEvent);
					}
					
					if(_contentHeight != element.height) {
						const contentHeightEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(
							this,
							'contentHeight', _contentHeight,
							_contentHeight = element.height
						);
						
						dispatchEvent(contentHeightEvent);
					}
				}),
				function():void {
					documentRendered = true;
					dispatchEvent(new flash.events.Event('documentRendered'));
					trace('format subscription completed in', (getTimer() - t), 'ms');
				},
				function(e:Error):void {
					trace('format subscription error\n', e.getStackTrace());
				});
			
			dispatchEvent(new flash.events.Event('documentCreated'));
		}
		
		protected function injectCSS(element:Element, css:String = ''):void {
			
			clearCSSPredicates(element);
			
			injectCSSPredicates(element, new defaultCSS().toString());
			
			if(css) injectCSSPredicates(element, css);
			
			// Apply the CSS predicates for the new document Element.
			applyCSSPredicates(element, null, element);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(context == null) {
				if(unscaledWidth == 0 || unscaledHeight == 0) return;
				
				if(stage) createContext();
				else {
					once(this, flash.events.Event.ADDED_TO_STAGE, createContext);
					return;
				}
			}
			
			const global:Point = localToGlobal(new Point());
			const stage3DViewport:Rectangle = context.viewPort;
			
			if(stage3DViewport.x != global.x || stage3DViewport.y != global.y) {
				context.viewPort = new Rectangle(global.x, global.y, unscaledWidth, unscaledHeight);
			}
			
			if(unscaledWidth != contentWidth) {
				viewportChanged = true;
			}
			
			if(htmlChanged || cssChanged || viewportChanged) {
				window.x = -Math.ceil(horizontalScrollPosition);
				window.y = -Math.ceil(verticalScrollPosition);
				window.clipRect = new Rectangle(
					Math.ceil(horizontalScrollPosition),
					Math.ceil(verticalScrollPosition),
					Math.ceil(unscaledWidth),
					Math.ceil(unscaledHeight)
				);
			}
			
			if(documentRendered) {
				cssChanged = false;
				htmlChanged = false;
				viewportChanged = false;
				return;
			}
			
			if(htmlChanged || cssChanged) {
				renderHTML(html, css);
			}
			
			cssChanged = false;
			htmlChanged = false;
			viewportChanged = false;
		}
	}
}
package org.tinytlf
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.swiftsuspenders.reflection.*;
	import org.tinytlf.content.*;
	import org.tinytlf.decoration.*;
	import org.tinytlf.html.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.rect.*;
	import org.tinytlf.layout.rect.sector.*;
	import org.tinytlf.style.*;
	import org.tinytlf.util.*;
	
	public class TextEngineInjector extends Injector
	{
		public function TextEngineInjector(engine:ITextEngine)
		{
			super();
			
			map(ITextEngine).toValue(engine);
			
			mapInjections();
			injectMappings();
			
			mapEventMirrors();
			mapCEFs();
			mapTRFs();
		}
		
		protected function mapInjections():void
		{
			map(Injector).toValue(this);
			map(Reflector).toValue(new DescribeTypeJSONReflector());
			
			map(IEventMirrorMap).toValue(new EventMirrorMap());
			map(IContentElementFactoryMap).toValue(new FactoryMap());
			map(ITextRectangleFactoryMap).toValue(new FactoryMap());
			map(ITextDecorationMap).toValue(new FactoryMap());
			map(IElementFormatFactory).toValue(new DOMEFFactory());
			map(ITextDecorator).toValue(new TextDecorator());
			map(CSS).toValue(new CSS());
			map(Observables).toValue(new Observables());
			
			map(Array, '<Sprite>').toValue([new Sprite()]);
			map(Array, '<TextPane>').toValue([]);
			
			map(MouseSelectionBehavior).toSingleton(MouseSelectionBehavior);
			
			// When someone asks for a vanilla Virtualizer,
			// assume they want the one we use for layout.
			const v:Virtualizer = new Virtualizer();
			map(Virtualizer).toValue(v);
			map(Virtualizer, 'layout').toValue(v);
			
			// Create a virtualizer to store IDOMNodes in.
			// This instance is used to lookup elements by caret index
			// for operations like copying text.
			map(Virtualizer, 'content').toValue(new Virtualizer());
		}
		
		protected function injectMappings():void
		{
			injectInto(getInstance(ITextEngine));
			injectInto(getInstance(IEventMirrorMap));
			injectInto(getInstance(IContentElementFactoryMap));
			injectInto(getInstance(ITextDecorationMap));
			injectInto(getInstance(ITextRectangleFactoryMap));
			injectInto(getInstance(IElementFormatFactory));
			injectInto(getInstance(ITextDecorator));
			injectInto(getInstance(Observables));
			injectInto(getInstance(Virtualizer, 'layout'));
			injectInto(getInstance(Virtualizer, 'content'));
			
			map(IDOMNode).toValue(new DOMNode(<_/>));
			injectInto(getInstance(MouseSelectionBehavior));
			unmap(IDOMNode);
			
			// Start off with at least one TextPane.
			const panes:Array = getInstance(Array, '<TextPane>');
			panes.push(instantiateUnmapped(TextPane));
		}
		
		protected function mapEventMirrors():void
		{
			const emm:IEventMirrorMap = getInstance(IEventMirrorMap);
			emm.mapFactory('a', AnchorMirror);
		}
		
		protected function mapCEFs():void
		{
			const cefm:IContentElementFactoryMap = getInstance(IContentElementFactoryMap);
			
			cefm.defaultFactory = new ClosureCEF();
			cefm.mapFactory('br', new ClosureCEF(function(dom:IDOMNode):ContentElement {
				return ContentElementUtil.lineBreakAfter(ContentElementUtil.getLineBreakGraphic());
			}));
		}
		
		protected function mapTRFs():void
		{
			const trfm:ITextRectangleFactoryMap = getInstance(ITextRectangleFactoryMap);
			const engine:ITextEngine = getInstance(ITextEngine);
			const injector:Injector = this;
			const cllv:Virtualizer = getInstance(Virtualizer, 'content');
			
			trfm.defaultFactory = new ClosureTRF(injector, function(dom:IDOMNode):Array {
				const sector:TextSector = injector.instantiateUnmapped(TextSector);
				sector.domNode = dom;
				sector.width = 0;
				sector.percentWidth = 100;
				sector.percentHeight = 100;
				
				cllv.add(sector, dom.contentSize);
				return [sector];
			});
			
			const passThrough:Function = function(dom:IDOMNode):Array {
				const rects:Array = [];
				for(var i:int = 0, n:int = dom.numChildren; i < n; ++i) {
					const child:IDOMNode = dom.getChildAt(i);
					rects.push.apply(null, trfm.instantiate(child.nodeName)['create'](child));
				}
				return rects;
			};
			
			trfm.mapFactory('ol', new ClosureTRF(injector, passThrough));
			trfm.mapFactory('ul', new ClosureTRF(injector, passThrough));
			trfm.mapFactory('center', new ClosureTRF(injector, passThrough));
			
			const injectIntoDOMNode:Function = function(dom:IDOMNode, recurse:Boolean = false):void {
				for(var i:int, n:int = dom.numChildren; i < n; ++i) {
					const child:IDOMNode = dom.getChildAt(i);
					injector.injectInto(child);
					if(recurse)
						injectIntoDOMNode(child, recurse);
				}
			};
			
			const containerTRF:ITextRectangleFactory = new ClosureTRF(injector,
				// create
				function(dom:IDOMNode, rect:TextRectangle):Array {
					rect.domNode = dom;
					return [rect];
				},
				// parse
				function(rect:TextRectangle):Array {
					injectIntoDOMNode(rect.domNode);
					return [rect].concat(new ClosureTRF(injector, passThrough).create(rect.domNode));
				},
				// render
				function(rect:TextRectangle):Array {
					return rect.children;
				}
			); 
			
			trfm.mapFactory('body', containerTRF);
			trfm.mapFactory('div', containerTRF);
			
			trfm.mapFactory('hr', new ClosureTRF(injector, function(dom:IDOMNode, rect:TextRectangle):Array {
				dom.mergeWith(rect);
				rect.percentWidth = 100;
				rect.percentHeight = 100;
				rect.height ||= 1;
				rect.paddingLeft ||= 2;
				rect.paddingRight ||= 2;
				const s:Sprite = new Sprite();
				s.graphics.beginFill(0x00, 0.1);
				s.graphics.drawRect(0, 0, rect.width || 1, rect.height || 1);
				s.graphics.endFill();
				rect.addChild(s);
				
				cllv.add(rect, 1);
				return [rect];
			},
			null,
			function(rect:TextRectangle):void {
				const s:Sprite = rect.children[0];
				s.width = rect.width - rect.paddingLeft - rect.paddingRight;
				s.height = rect.height;
				s.x = rect.x;
				s.y = rect.y;
			}));
			
			trfm.mapFactory('br', new ClosureTRF(injector, function(dom:IDOMNode):Array {
				const rect:TextRectangle = injector.instantiateUnmapped(TextRectangle);
				rect.mergeWith(dom);
				rect.percentWidth = 100;
				rect.percentHeight = 100;
				rect.height = dom['fontSize'] || dom['height'];
				
				cllv.add(rect, 1);
				return [rect];
			}));
			
			trfm.mapFactory('img', new ClosureTRF(injector, function(dom:IDOMNode, rect:TextRectangle):Array {
				rect.mergeWith(dom);
				rect.width = 0;
				rect.height = 0;
				rect.percentWidth = 100;
				rect.percentHeight = 100;
				const loader:Loader = new Loader();
				loader.load(new URLRequest(dom.getStyle('src')));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
					dom.applyTo(loader);
					rect.addChild(loader);
					engine.invalidate();
				});
				cllv.add(rect, 1);
				return [rect];
			}, null, function(rect:TextRectangle):void {
				const kids:Array = rect.children;
				if(kids.length == 0)
					return;
				const loader:Loader = kids[0];
				rect.progression.position(rect, loader);
				rect.width = Math.max(rect.width, loader.width);
				rect.height = Math.max(rect.height, loader.height);
			}));
			
			trfm.mapFactory('table', new ClosureTRF(injector, function(dom:IDOMNode):Array {
				const sector:TextSector = injector.instantiateUnmapped(TextSector);
				sector.domNode = new DOMNode(<body><h2>[Table Here]</h2><br/><h5>(Tables aren't supported yet.)</h5></body>);
				sector.width = 0;
				sector.percentWidth = 100;
				sector.percentHeight = 100;
				sector.textAlign = TextAlign.CENTER;
				
				cllv.add(sector, dom.contentSize);
				return [sector];
			}));
			
//			trfm.mapFactory('table', new ClosureTRF(injector, function(dom:IDOMNode, rect:TextRectangle):Array {
////				rect.domNode = dom;
//				rect.mergeWith(dom);
//				rect.width = 0;
//				rect.height = 0;
//				rect.percentWidth = 100;
//				rect.percentHeight = 100;
//				const s:Sprite = new Sprite();
//				s.graphics.beginFill(0x00, 0.1);
//				s.graphics.drawRect(0, 0, rect.width || 1, rect.height || 1);
//				s.graphics.endFill();
//				rect.addChild(s);
//				
//				cllv.add(rect, dom.contentSize);
//				return [rect];
//			},
//			null,
//			function(rect:TextRectangle):void {
//				rect.width ||= 100;
//				rect.height ||= 100;
//				
//				const s:Sprite = rect.children[0];
//				s.width = rect.width;
//				s.height = rect.height;
//				s.x = rect.x;
//				s.y = rect.y;
//			}));
		}
	}
}

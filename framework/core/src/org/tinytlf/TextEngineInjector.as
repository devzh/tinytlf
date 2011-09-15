package org.tinytlf
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.content.*;
	import org.tinytlf.decoration.*;
	import org.tinytlf.html.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	import org.tinytlf.style.*;
	import org.tinytlf.util.*;
	
	public class TextEngineInjector extends Injector
	{
		public function TextEngineInjector(engine:ITextEngine)
		{
			super();
			
			mapValue(ITextEngine, engine);
			mapInjections();
			injectMappings();
			
			mapCEFs();
			mapTSFs();
		}
		
		protected function mapInjections():void
		{
			mapValue(Injector, this);
			mapValue(Reflector, new Reflector());
			
			mapValue(IEventMirrorMap, new EventMirrorMap());
			mapValue(IContentElementFactoryMap, new FactoryMap());
			mapValue(ITextSectorFactoryMap, new FactoryMap());
			mapValue(ITextDecorationMap, new FactoryMap());
			mapValue(IElementFormatFactory, new DOMEFFactory());
			mapValue(ITextDecorator, new TextDecorator());
			mapValue(CSS, new CSS());
			mapValue(Observables, new Observables());
			
			mapValue(Array, [new Sprite()], '<Sprite>');
			mapValue(Array, [], '<TextPane>');
			
			// When someone asks for a vanilla Virtualizer,
			// assume they want the one we use for layout.
			const v:Virtualizer = new Virtualizer();
			mapValue(Virtualizer, v);
			mapValue(Virtualizer, v, 'layout');
			
			// Create a virtualizer to store ContentElements into.
			// This instance is used to lookup elements by caret index
			// for operations like copying text.
			mapValue(Virtualizer, new Virtualizer(), 'content');
		}
		
		protected function injectMappings():void
		{
			injectInto(getInstance(ITextEngine));
			injectInto(getInstance(IEventMirrorMap));
			injectInto(getInstance(IContentElementFactoryMap));
			injectInto(getInstance(ITextDecorationMap));
			injectInto(getInstance(ITextSectorFactoryMap));
			injectInto(getInstance(IElementFormatFactory));
			injectInto(getInstance(ITextDecorator));
			injectInto(getInstance(Observables));
			injectInto(getInstance(Virtualizer, 'layout'));
			injectInto(getInstance(Virtualizer, 'content'));
			
			// Instantiate UI behaviors.
			instantiate(IBeamBehavior);
			
			// Start off with at least one TextPane.
			const panes:Array = getInstance(Array, '<TextPane>');
			panes.push(instantiate(TextPane));
		}
		
		protected function mapCEFs():void
		{
			const cefm:IContentElementFactoryMap = getInstance(IContentElementFactoryMap);
			
			cefm.defaultFactory = new ClosureCEF();
			cefm.mapFactory('br', new ClosureCEF(function(dom:IDOMNode):ContentElement {
				return ContentElementUtil.lineBreakAfter(ContentElementUtil.getLineBreakGraphic());
			}));
		}
		
		protected function mapTSFs():void
		{
			const tsfm:ITextSectorFactoryMap = getInstance(ITextSectorFactoryMap);
			const engine:ITextEngine = getInstance(ITextEngine);
			const injector:Injector = this;
			
			tsfm.defaultFactory = new ClosureTSF(function(dom:IDOMNode):Array {
				const sector:TextSector = injector.instantiate(TextSector);
				sector.domNode = dom;
				sector.width = 0;
				sector.percentWidth = 100;
				return [sector];
			});
			
			const passThrough:Function = function(dom:IDOMNode):Array {
				const rects:Array = [];
				dom.children.forEach(function(child:IDOMNode, ... args):void {
					rects.push.apply(null, tsfm.instantiate(child.name).create(child));
				});
				return rects;
			};
			
			tsfm.mapFactory('ol', new ClosureTSF(passThrough));
			tsfm.mapFactory('ul', new ClosureTSF(passThrough));
			tsfm.mapFactory('body', new ClosureTSF(passThrough));
			
			tsfm.mapFactory('div', DivTSF);
			
			tsfm.mapFactory('hr', new ClosureTSF(function(dom:IDOMNode, rect:TextRectangle):Array {
				dom.mergeWith(rect);
				rect.percentWidth = 100;
				rect.height ||= 1;
				rect.paddingLeft ||= 2;
				rect.paddingRight ||= 2;
				const s:Sprite = new Sprite();
				s.graphics.beginFill(0x00, 0.1);
				s.graphics.drawRect(0, 0, rect.width || 1, rect.height || 1);
				s.graphics.endFill();
				rect.addChild(s);
				return [rect];
			}, null, function(rect:TextRectangle):void {
				const s:Sprite = rect.children[0];
				s.width = rect.width - rect.paddingLeft - rect.paddingRight;
				s.height = rect.height;
				s.x = rect.x;
				s.y = rect.y;
			}));
			
			tsfm.mapFactory('br', new ClosureTSF(function(dom:IDOMNode):Array {
				const rect:TextRectangle = injector.instantiate(TextRectangle);
				rect.mergeWith(dom);
				rect.height = dom['fontSize'] || dom['height'];
				return [rect];
			}));
			
			tsfm.mapFactory('img', new ClosureTSF(function(dom:IDOMNode, rect:TextRectangle):Array {
				rect.mergeWith(dom);
				const loader:Loader = new Loader();
				loader.load(new URLRequest(dom.getStyle('src')));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
					dom.applyTo(loader);
					rect.addChild(loader);
					engine.invalidate();
				});
				return [rect];
			}, null, function(rect:TextRectangle):void {
				const kids:Array = rect.children;
				if(kids.length == 0)
					return;
				const loader:Loader = kids[0];
				rect.width = loader.width;
				rect.height = loader.height;
				loader.x = rect.x;
				loader.y = rect.y;
			}));
			
			tsfm.mapFactory('table', new ClosureTSF(function(dom:IDOMNode, rect:TextRectangle):Array {
				dom.mergeWith(rect);
				rect.percentWidth = 100;
				const s:Sprite = new Sprite();
				s.graphics.beginFill(0x00, 0.1);
				s.graphics.drawRect(0, 0, rect.width || 1, rect.height || 1);
				s.graphics.endFill();
				rect.addChild(s);
				return [rect];
			}, null, function(rect:TextRectangle):void {
				rect.width ||= 100;
				rect.height ||= 100;
				const s:Sprite = rect.children[0];
				s.width = rect.width;
				s.height = rect.height;
				s.x = rect.x;
				s.y = rect.y;
			}));
		
		}
	}
}

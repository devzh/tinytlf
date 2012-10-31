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
	import org.tinytlf.layout.box.*;
	import org.tinytlf.layout.box.paragraph.*;
	import org.tinytlf.layout.box.region.Region;
	import org.tinytlf.style.*;
	import org.tinytlf.util.*;
	
	public class EditableTextEngineInjector extends Injector
	{
		override public function EditableTextEngineInjector(engine:ITextEngine)
		{
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
			map(IBoxFactoryMap).toValue(new FactoryMap());
			map(ITextDecorationMap).toValue(new FactoryMap());
			map(IElementFormatFactory).toValue(new DOMEFFactory());
			map(ITextDecorator).toValue(new TextDecorator());
			map(CSS).toValue(new CSS());
			map(Observables).toValue(new Observables());
			
			map(Array, '<Sprite>').toValue([new Sprite()]);
			map(Array, '<Box>').toValue([]);
			
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
			injectInto(getInstance(IBoxFactoryMap));
			injectInto(getInstance(IElementFormatFactory));
			injectInto(getInstance(ITextDecorator));
			injectInto(getInstance(Observables));
			injectInto(getInstance(Virtualizer, 'layout'));
			injectInto(getInstance(Virtualizer, 'content'));
			
			map(IDOMNode).toValue(new DOMNode(<_/>));
			injectInto(getInstance(MouseSelectionBehavior));
			unmap(IDOMNode);
			
			// Start off with at least one TextPane.
			const boxes:Array = getInstance(Array, '<Box>');
			boxes.push(instantiateUnmapped(Paragraph));
		}
		
		protected function mapEventMirrors():void
		{
		}
		
		protected function mapCEFs():void
		{
			const cefm:IContentElementFactoryMap = getInstance(IContentElementFactoryMap);
			cefm.defaultFactory = new ClosureCEF();
		}
		
		protected function mapTRFs():void
		{
			const bfm:IBoxFactoryMap = getInstance(IBoxFactoryMap);
			const engine:ITextEngine = getInstance(ITextEngine);
			const injector:Injector = this;
			const cllv:Virtualizer = getInstance(Virtualizer, 'content');
			
			bfm.defaultFactory = new ClosureBoxFactory(injector, function(dom:IDOMNode):Array {
				const paragraph:Paragraph = injector.instantiateUnmapped(Paragraph);
				paragraph.domNode = dom;
				paragraph.width = 0;
				paragraph.percentWidth = 100;
				paragraph.percentHeight = 100;
				
				cllv.add(paragraph, dom.contentSize);
				return [paragraph];
			});
		}
	}
}
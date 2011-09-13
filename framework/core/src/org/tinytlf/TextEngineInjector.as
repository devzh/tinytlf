package org.tinytlf
{
	import flash.display.*;
	import flash.events.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.content.*;
	import org.tinytlf.decoration.*;
	import org.tinytlf.html.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	import org.tinytlf.style.*;
	
	public class TextEngineInjector extends Injector
	{
		public function TextEngineInjector(engine:ITextEngine)
		{
			super();
			
			mapValue(ITextEngine, engine);
			mapInjections();
			injectMappings();
		}
		
		protected function mapInjections():void
		{
			mapValue(Injector, this);
			mapValue(Reflector, new Reflector());
			
			mapValue(IEventMirrorMap, new EventMirrorMap());
			mapValue(IContentElementFactoryMap, new FactoryMap(CEFactory));
			mapValue(ITextSectorFactoryMap, new FactoryMap(ParagraphTSF));
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
	}
}

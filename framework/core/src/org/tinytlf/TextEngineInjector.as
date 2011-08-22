package org.tinytlf
{
	import flash.events.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.content.*;
	import org.tinytlf.decoration.*;
	import org.tinytlf.html.CSS;
	import org.tinytlf.html.ParagraphTSF;
	import org.tinytlf.interaction.*;
	import org.tinytlf.layout.*;
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
			
			mapValue(IEventMirrorMap, new FactoryMap(EventDispatcher));
			mapValue(IContentElementFactoryMap, new FactoryMap(CEFactory));
			mapValue(ITextSectorFactoryMap, new FactoryMap(ParagraphTSF));
			mapValue(ITextDecorationMap, new FactoryMap());
			mapValue(IElementFormatFactory, new DOMEFFactory());
			mapValue(ITextDecorator, new TextDecorator());
			mapValue(CSS, new CSS());
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
		}
	}
}
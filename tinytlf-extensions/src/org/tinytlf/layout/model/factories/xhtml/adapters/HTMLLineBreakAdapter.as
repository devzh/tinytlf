package org.tinytlf.layout.model.factories.xhtml.adapters
{
	import flash.events.EventDispatcher;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextElement;
	
	import org.tinytlf.layout.model.factories.ContentElementFactory;
	
	public class HTMLLineBreakAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			return new TextElement('\n', new ElementFormat(), new EventDispatcher());
		}
	}
}
package org.tinytlf.layout.model.factories.xhtml.adapters
{
	import flash.events.EventDispatcher;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.model.factories.ContentElementFactory;
	
	public class HTMLHorizontalRuleAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			var graphic:GraphicElement = new GraphicElement(null, 0, 0, new ElementFormat(), new EventDispatcher());
			engine.decor.decorate(graphic, {horizontalRule:true});
			
			return new GroupElement(new <ContentElement>[
				new TextElement('\n', new ElementFormat()), 
				graphic/*,
				new TextElement('\n', new ElementFormat())*/
			]);
		}
	}
}
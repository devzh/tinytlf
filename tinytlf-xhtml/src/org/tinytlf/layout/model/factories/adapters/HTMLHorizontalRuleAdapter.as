package org.tinytlf.layout.model.factories.adapters
{
	import flash.events.EventDispatcher;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.model.factories.ContentElementFactory;
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class HTMLHorizontalRuleAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...context):ContentElement
		{
			var graphic:GraphicElement = new GraphicElement(null, 0, 0, new ElementFormat(), new EventDispatcher());
			engine.decor.decorate(graphic, {horizontalRule:true});
			return ContentElementUtil.lineBreakBefore(graphic);
		}
	}
}
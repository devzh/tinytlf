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
			var format:ElementFormat = getElementFormat(context);
			format.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			var graphic:GraphicElement = new GraphicElement(null, 1, format.fontSize, format, new EventDispatcher());
			engine.decor.decorate(graphic, {horizontalRule:true});
//			return ContentElementUtil.lineBreakBeforeAndAfter(graphic);
			return ContentElementUtil.lineBreakBefore(graphic);
		}
	}
}
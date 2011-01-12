package org.tinytlf.layout.factories
{
	import flash.display.*;
	import flash.events.EventDispatcher;
	import flash.text.engine.*;
	
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class HTMLHorizontalRuleAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...context):ContentElement
		{
			var graphic:GraphicElement = new GraphicElement(new Shape(), 0, 0, ef, new EventDispatcher());
			engine.decor.decorate(graphic, {horizontalRule:true});
			return ContentElementUtil.lineBreakBefore(graphic, 'lineBreak');
		}
	}
}
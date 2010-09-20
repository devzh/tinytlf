package org.tinytlf.layout.model.factories.adapters
{
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.TextElement;
	
	import org.tinytlf.layout.model.factories.ContentElementFactory;
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class HTMLLineBreakAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			return ContentElementUtil.lineBreakBefore(new GraphicElement(new Shape(), 0, 0, new ElementFormat()));
		}
	}
}
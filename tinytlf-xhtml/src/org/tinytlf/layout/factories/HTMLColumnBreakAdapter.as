package org.tinytlf.layout.factories
{
	import flash.display.Shape;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	
	import org.tinytlf.util.fte.ContentElementUtil;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class HTMLColumnBreakAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			var graphic:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
			graphic.userData = TextLineUtil.getSingletonMarker('containerTerminator');
			return ContentElementUtil.lineBreakBefore(graphic);
		}
	}
}
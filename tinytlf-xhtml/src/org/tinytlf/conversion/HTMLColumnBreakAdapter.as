package org.tinytlf.conversion
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class HTMLColumnBreakAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			var graphic:GraphicElement = new GraphicElement(new Shape(), 0, 0, ef);
			graphic.userData = 'containerTerminator';
			return ContentElementUtil.lineBreakBefore(graphic);
		}
	}
}
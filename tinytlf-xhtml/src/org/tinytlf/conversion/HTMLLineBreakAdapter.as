package org.tinytlf.conversion
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class HTMLLineBreakAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			return ContentElementUtil.lineBreakBefore(new GraphicElement(new Shape(), 0, 0, ef), 'lineBreak');
		}
	}
}
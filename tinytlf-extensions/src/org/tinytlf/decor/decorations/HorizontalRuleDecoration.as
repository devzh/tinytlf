package org.tinytlf.decor.decorations
{
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.decor.TextDecoration;
	import org.tinytlf.layout.ITextContainer;
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class HorizontalRuleDecoration extends StrikeThroughDecoration
	{
		public function HorizontalRuleDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override public function setup(layer:int = 0, ... parameters):Vector.<Rectangle>
		{
			var arg:* = parameters[0];
			if(arg is ContentElement)
			{
				var lines:Vector.<TextLine> = ContentElementUtil.getTextLines(ContentElement(arg));
				if(!lines.length)
					return new <Rectangle>[];
				
				var line:TextLine = lines[0];
				var rect:Rectangle = line.getBounds(line.parent);
				var container:ITextContainer;
				
				rect.width = line.specifiedWidth;
				
				rectToContainer[rect] = assureLayerExists(engine.layout.getContainerForLine(line), layer);
				
				return new <Rectangle>[rect];
			}
			else
				return super.setup.apply(null, [layer].concat(parameters));
		}
	}
}
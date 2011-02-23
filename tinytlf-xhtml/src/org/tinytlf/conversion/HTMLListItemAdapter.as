package org.tinytlf.conversion
{
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.text.engine.*;
	
	import org.tinytlf.model.ITLFNode;
	import org.tinytlf.util.fte.*;
	
	public class HTMLListItemAdapter extends TLFNodeElementFactory
	{
		override public function execute(data:Object, ... context:Array):ContentElement
		{
			var item:ContentElement = super.execute.apply(null, [data].concat(context));
			
			if(data is ITLFNode)
			{
				var styles:Object = engine.styler.describeElement(context);
				var outside:Boolean = styles.listStylePosition == 'outside';
				var marginLeft:Number = styles.marginLeft || 25;
				
				var graphic:GraphicElement = 
					new GraphicElement(new Shape(), marginLeft, 0, new ElementFormat());
				
				graphic.userData = outside ? 'listItemOutside' : 'listItemInside';
				
				var end:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
				end.userData = 'listItemTerminator';
				
				var box:Rectangle = item.elementFormat.getFontMetrics().emBox;
				engine.decor.decorate(graphic, {bullet: true, diameter: box.height * .25});
				
				return ContentElementUtil.lineBreakBeforeAndAfter(
					new GroupElement(new <ContentElement>[graphic, item, end]));
			}
			else
			{
				return item;
			}
		}
	}
}

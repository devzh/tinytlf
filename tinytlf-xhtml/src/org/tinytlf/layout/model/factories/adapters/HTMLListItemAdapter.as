package org.tinytlf.layout.model.factories.adapters
{
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBaseline;
	
	import org.tinytlf.util.fte.ContentElementUtil;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class HTMLListItemAdapter extends XMLElementAdapter
	{
		override public function execute(data:Object, ... context:Array):ContentElement
		{
			var item:ContentElement = super.execute.apply(null, [data].concat(context));
			
			if(data is XML)
			{
				var styles:Object = engine.styler.describeElement(context);
				var outside:Boolean = styles.listStylePosition == 'outside'
				var marginLeft:Number = styles.marginLeft || 25;
				
				var graphicFormat:ElementFormat = new ElementFormat();
				graphicFormat.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
				var graphic:GraphicElement = new GraphicElement(outside ? new TallShape(marginLeft) : new Shape(), marginLeft, 0, graphicFormat);
				
				var end:GraphicElement = new GraphicElement(new Shape(), 0, 0, graphicFormat.clone());
				
				var box:Rectangle = item.elementFormat.getFontMetrics().emBox;
				engine.decor.decorate(graphic, {bullet: true, diameter: box.height * .25});
				
				if(outside)
				{
					graphic.userData = TextLineUtil.getSingletonMarker('listItem');
					end.userData = TextLineUtil.getSingletonMarker('listItemTerminator');
					return ContentElementUtil.lineBreakBeforeAndAfter(new GroupElement(new <ContentElement>[graphic, item, end]));
				}
				
				return new GroupElement(new <ContentElement>[graphic, item, end]);
			}
			else
			{
				return item;
			}
		}
	}
}
import flash.display.Shape;

internal class TallShape extends Shape
{
	public function TallShape(width:Number)
	{
		graphics.beginFill(0x00, 0);
		graphics.drawRect(0, 0, width, 100000);
	}
}
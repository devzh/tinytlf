package org.tinytlf.layout.model.factories.adapters
{
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	
	import org.tinytlf.layout.model.factories.ILayoutFactoryMap;
	import org.tinytlf.layout.model.factories.XMLDescription;
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
				
				var graphic:GraphicElement = 
					new GraphicElement(new Shape(), 
						outside ? marginLeft : totalMargin(context), 0, new ElementFormat());
				
				var end:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
				
				var box:Rectangle = item.elementFormat.getFontMetrics().emBox;
				engine.decor.decorate(graphic, {bullet: true, diameter: box.height * .25});
				
				if(outside)
				{
					graphic.userData = TextLineUtil.getSingletonMarker('listItem');
					end.userData = TextLineUtil.getSingletonMarker('listItemTerminator');
					return ContentElementUtil.lineBreakBeforeAndAfter(
						new GroupElement(new <ContentElement>[graphic, item, end]));
				}
				
				return ContentElementUtil.lineBreakAfter(
					new GroupElement(new <ContentElement>[graphic, item, end]));
			}
			else
			{
				return item;
			}
		}
		
		private function totalMargin(context:Array):Number
		{
			var margin:Number = 0;
			var xml:XMLDescription;
			var copy:Array = context.concat();
			
			var factory:ILayoutFactoryMap = engine.layout.textBlockFactory;
			
			while(copy.length)
			{
				xml = copy.pop();
				if(factory.getElementFactory(xml.name) is HTMLListItemAdapter)
				{
					margin += xml.marginLeft || 25;
				}
			}
			
			return margin;
		}
	}
}

package org.tinytlf.layout.model.factories.adapters
{
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	
	import org.tinytlf.layout.Terminators;
	
	public class HTMLListItemAdapter extends XMLElementAdapter
	{
		override public function execute(data:Object, ... context:Array):ContentElement
		{
			var item:ContentElement = super.execute.apply(null, [data].concat(context));
			
			if(data is XML)
			{
				var styles:Object = engine.styler.describeElement(context);
				var box:Rectangle = item.elementFormat.getFontMetrics().emBox;
				var graphic:GraphicElement;
				
				if(styles.listStylePosition === 'outside')
				{
					graphic = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
				}
				else
				{
					graphic = new GraphicElement(new Shape(), styles.marginLeft || 25, 0, new ElementFormat());
				}
				
				engine.decor.decorate(graphic, {bullet: true, diameter: box.height * .25});
				return Terminators.terminateAfter(new GroupElement(new <ContentElement>[graphic, item]));
			}
			else
			{
				return item;
			}
		}
	}
}
